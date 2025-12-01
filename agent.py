import sqlite3
import logging
import os
from datetime import datetime, timedelta
from uuid import uuid4
from typing import Callable, List, Dict, Any, Optional
from dotenv import load_dotenv

#Genai libraries
from google.genai import types

#ADK libraries
from google.adk.agents import LlmAgent
from google.adk.models.google_llm import Gemini
from google.adk.sessions import InMemorySessionService
from google.adk.sessions import Session
from google.adk.runners import Runner
from google.adk.apps.app import App

# --- Logging Configuration ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler() # Log to console
    ]
)

# Load environment variables
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

# Get API keys from environment variables
GEMINI_API_KEY = os.getenv("GOOGLE_API_KEY")

# Set the Gemini API key in the environment
os.environ["GOOGLE_API_KEY"] = GEMINI_API_KEY

APP_NAME = "default"  # Application
USER_ID = "default"  # User
SESSION = "default"  # Session

MODEL_NAME = "gemini-2.5-flash-lite"

# Define helper functions
async def run_session( # type: ignore
    runner_instance: Runner,
    user_id: str,
    session: Session,
    user_query: str,
):
    """Runs a single query in a session and streams the response."""
    query_content = types.Content(role="user", parts=[types.Part(text=user_query)])

    print(f"\n🤖 AGENT: ", end="", flush=True)
    async for event in runner_instance.run_async(
        user_id=user_id, session_id=session.id, new_message=query_content
    ):
        if event.content and event.content.parts:
            text_part = event.content.parts[0].text
            if text_part and text_part != "None":
                print(text_part, end="", flush=True)
    print()  # For the newline after the streamed response

print("✅ Helper functions defined.")

retry_config = types.HttpRetryOptions(
    attempts=5,  # Maximum retry attempts
    exp_base=7,  # Delay multiplier
    initial_delay=1,
    http_status_codes=[429, 500, 503, 504],  # Retry on these HTTP errors
)


# Step 1: Create the LLM Agent
# --- AGENT LOGIC ---

def get_agent_instruction(user_id: str, user_role: str) -> str:
    """Generates the dynamic system instruction for the agent based on the current user."""
    return f"""You are a smart timesheet assistant.

Your primary role is to help users manage their timesheets using the available tools. You must adhere to the user's role and use the correct tool for their request.

**Current User Context:**
- User ID: {user_id}
- User Role: {user_role}

**ALWAYS use the provided User ID for the `user_id` or `manager_id` parameter in your tool calls.**

**Tool Guide:**
1.  **For ANY user asking to see their status, view history, or check their dashboard:**
    - Use `tool_view_queries`. This tool provides a summary including pending items, hours submitted this month, hours approved this month and manager's name.
    - After calling `tool_view_queries`, **ALWAYS respond to the user** with the information you retrieved.
2.  **For an `Employee` asking to submit, log, or add hours:**
    - Use `tool_submit_timesheet`. You must have the number of hours to proceed.
3.  **For a `Manager` asking to review, see pending items, or check approvals:**
    - This is the **FIRST** step of the approval process.
    - Use `tool_manager_approval`. This tool only *lists* pending timesheets and their IDs.
4.  **For a `Manager` asking to `approve` or `reject` a specific timesheet:**
    - This is the **SECOND** step of the approval process.
    - You MUST have a timesheet ID to do this. If you don't have one, use `tool_manager_approval` first to get a list.
    - Use `tool_update_timesheet_status` with the `timesheet_id` and the desired `new_status` ('Approved' or 'Rejected').

**Error Handling:**
- If a tool returns a status of "error", inform the user of the error message clearly."""

# --- TOOL 1: View/Read Only Queries (Employee Role) ---

def tool_view_queries(user_id: str) -> dict:
    """
    Provides read-only information for the employee dashboard.

    Args:
        user_id: The unique ID of the employee querying the data.

    Returns:
        Dictionary with status and dashboard information.
        Success: {"status": "success", "pending_count": int, "monthly_hours": float, "manager_name": str, "recent_submissions": list}
        Error: {"status": "error", "error_message": str}
    """
    logging.info(f"Executing tool: tool_view_queries for user_id: {user_id}")
    if not CONN:
        logging.error("tool_view_queries failed: Database connection not available.")
        return {"status": "error", "error_message": "Database connection not available"}

    try:
        pending_count = len(get_timesheets(user_id=user_id, status='Pending'))

        thirty_days_ago = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
        cursor = CONN.cursor()
        cursor.execute(
            """
            SELECT SUM(hours) FROM timesheets
            WHERE employeeId = ? AND status = 'Approved' AND date >= ?
            """,
            (user_id, thirty_days_ago)
        )

        monthly_hours_result = cursor.fetchone()
        monthly_hours = (monthly_hours_result[0] or 0.0) if monthly_hours_result else 0.0

        manager_name = get_user_name(CURRENT_PROFILE['reportsTo'])

        recent_sheets = get_timesheets(user_id=user_id, limit=3)

        result = {
            "status": "success",
            "pending_count": pending_count,
            "monthly_hours": round(monthly_hours, 1),
            "manager_name": manager_name,
            "recent_submissions": recent_sheets,
        }
        logging.info("tool_view_queries executed successfully.")
        return result
    except Exception as e:
        logging.error(f"tool_view_queries failed with exception: {e}", exc_info=True)
        return {
            "status": "error",
            "error_message": f"An error occurred while fetching dashboard data: {e}",
        }

# --- TOOL 2: Submit Timesheet (Employee Role) ---
def tool_submit_timesheet(user_id: str, hours: float, date: str = None, task: str = "Unspecified project work.") -> dict:
    """
    Allows the employee to submit a new timesheet entry.

    Args:
        user_id: The unique ID of the employee submitting the sheet.
        hours: The number of hours worked.
        date: The date of work in YYYY-MM-DD format. Defaults to today.
        task: A description of the task performed.

    Returns:
        Dictionary with status of the submission.
        Success: {"status": "success", "message": str, "timesheet_id": str}
        Error: {"status": "error", "error_message": str}
    """
    logging.info(f"Executing tool: tool_submit_timesheet for user_id: {user_id} with hours: {hours}")
    if not date:
        date = datetime.now().strftime('%Y-%m-%d')

    try:
        hours = float(hours)
        if not (0.5 <= hours <= 24):
            logging.warning(f"Invalid hours provided: {hours}. Must be between 0.5 and 24.")
            return {"status": "error", "error_message": "Hours must be between 0.5 and 24."}
        if not task:
            logging.warning("Empty task description provided.")
            return {"status": "error", "error_message": "Task description cannot be empty."}
    except ValueError as e:
        logging.error(f"Invalid tool arguments for tool_submit_timesheet: {e}", exc_info=True)
        return {"status": "error", "error_message": f"Invalid tool arguments: {e}"}

    if not CONN:
        logging.error("tool_submit_timesheet failed: Database connection not available.")
        return {"status": "error", "error_message": "Database connection not available"}

    try:
        new_sheet_id = str(uuid4())
        submitted_at = datetime.now().isoformat()
        manager_id = CURRENT_PROFILE.get('reportsTo', MANAGER_ID)
        cursor = CONN.cursor()
        cursor.execute("""
            INSERT INTO timesheets (id, employeeId, managerId, date, hours, task, status, submittedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (new_sheet_id, user_id, manager_id, date, hours, task, 'Pending', submitted_at))
        CONN.commit()
        result = {
            "status": "success",
            "message": f"Timesheet submitted for {date} ({hours} hours). Task: '{task}'. Awaiting manager approval.",
            "timesheet_id": new_sheet_id
        }
        logging.info(f"tool_submit_timesheet executed successfully. New timesheet ID: {new_sheet_id}")
        return result
    except Exception as e:
        logging.error(f"tool_submit_timesheet failed during DB operation: {e}", exc_info=True)
        return {"status": "error", "error_message": f"An error occurred during submission: {e}"}

# --- TOOL 3: Manager Approval (Manager Role) ---

def tool_manager_approval(manager_id: str) -> dict:
    """
    Allows a manager to view pending timesheets submitted by their direct reports.

    This tool is the first step in the approval process. It retrieves the list
    of items awaiting action. A separate tool would be used to perform the
    approval or rejection action itself.

    Args:
        manager_id: The unique ID of the manager performing the query.

    Returns:
        A dictionary containing the status and the list of pending timesheets.
        Success: {"status": "success", "pending_sheets": list}
        Error: {"status": "error", "error_message": str}
    """
    logging.info(f"Executing tool: tool_manager_approval for manager_id: {manager_id}")
    if CURRENT_PROFILE['role'] != 'Manager':
        logging.warning(f"Access denied for tool_manager_approval. User role is not 'Manager'.")
        return {
            "status": "error",
            "error_message": "ACCESS DENIED: You must have the 'Manager' role to perform approvals."
        }

    try:
        pending_sheets = get_timesheets(manager_id=manager_id, status='Pending')

        # Add employee name to each sheet for easier display
        for sheet in pending_sheets:
            sheet['employee_name'] = get_user_name(sheet['employeeId'])

        result = {
            "status": "success",
            "pending_sheets": pending_sheets
        }
        logging.info(f"tool_manager_approval executed successfully. Found {len(pending_sheets)} pending sheets.")
        return result
    except Exception as e:
        logging.error(f"tool_manager_approval failed with exception: {e}", exc_info=True)
        return {"status": "error", "error_message": f"An error occurred while fetching pending sheets: {e}"}

# --- TOOL 4: Update Timesheet Status (Manager Role) ---

def tool_update_timesheet_status(manager_id: str, timesheet_id: str, new_status: str) -> dict:
    """
    Allows a manager to approve or reject a pending timesheet.

    Args:
        manager_id: The unique ID of the manager performing the action.
        timesheet_id: The unique ID of the timesheet to be updated.
        new_status: The new status to set. Must be 'Approved' or 'Rejected'.

    Returns:
        A dictionary containing the status of the update operation.
        Success: {"status": "success", "message": str}
        Error: {"status": "error", "error_message": str}
    """
    logging.info(f"Executing tool: tool_update_timesheet_status for manager_id: {manager_id}, timesheet_id: {timesheet_id}, new_status: {new_status}")
    if CURRENT_PROFILE['role'] != 'Manager':
        logging.warning(f"Access denied for tool_update_timesheet_status. User role is not 'Manager'.")
        return {
            "status": "error",
            "error_message": "ACCESS DENIED: You must have the 'Manager' role to perform this action."
        }

    if new_status not in ['Approved', 'Rejected']:
        logging.warning(f"Invalid status '{new_status}' provided to tool_update_timesheet_status.")
        return {
            "status": "error",
            "error_message": f"Invalid status '{new_status}'. Must be 'Approved' or 'Rejected'."
        }

    if not CONN:
        logging.error("tool_update_timesheet_status failed: Database connection not available.")
        return {"status": "error", "error_message": "Database connection not available"}

    try:
        cursor = CONN.cursor()

        # Verify the timesheet exists and reports to this manager
        cursor.execute("SELECT managerId FROM timesheets WHERE id = ?", (timesheet_id,))
        result = cursor.fetchone()

        if not result:
            logging.warning(f"Timesheet with ID '{timesheet_id}' not found during update.")
            return { "status": "error", "error_message": f"Timesheet with ID '{timesheet_id}' not found." }

        sheet_manager_id = result[0]
        if sheet_manager_id != manager_id:
            logging.warning(f"Access denied: Manager '{manager_id}' attempted to update timesheet '{timesheet_id}' owned by manager '{sheet_manager_id}'.")
            return { "status": "error", "error_message": f"ACCESS DENIED: You are not the manager for timesheet '{timesheet_id}'." }

        # Update the status
        approved_at = datetime.now().isoformat()
        cursor.execute( """ UPDATE timesheets SET status = ?, approvedAt = ? WHERE id = ? """, (new_status, approved_at, timesheet_id) )
        CONN.commit()

        if cursor.rowcount > 0:
            result = { "status": "success", "message": f"Timesheet '{timesheet_id[:8]}...' has been {new_status}." }
            logging.info(f"tool_update_timesheet_status executed successfully for timesheet '{timesheet_id}'.")
            return result
        else:
            # This case is unlikely if the initial check passes, but good to have
            logging.error(f"Failed to update timesheet '{timesheet_id}' in the database, though it was found initially.")
            return { "status": "error", "error_message": f"Failed to update timesheet '{timesheet_id}'. It may have been deleted." }

    except Exception as e:
        logging.error(f"tool_update_timesheet_status failed with exception: {e}", exc_info=True)
        return {
            "status": "error",
            "error_message": f"An error occurred during the update process: {e}"
        }

# --- ADK INTEGRATION: Tool Manager and LLM Router ---

# 1. TOOL SCHEMA DEFINITIONS (The metadata the LLM uses)
TOOL_SCHEMAS: Dict[str, Dict[str, Any]] = {
    "tool_view_queries": {
        "function_ref": tool_view_queries,
        "description": "Retrieves the current user's timesheet dashboard information, including pending sheets, approved hours, and manager contact details. Use for any status or history query.",
        "parameters": {
            "type": "object",
            "properties": {
                "user_id": {"type": "string", "description": "The unique ID of the employee querying the data. (Mandatory)"}
            },
            "required": ["user_id"]
        }
    },
    "tool_submit_timesheet": {
        "function_ref": tool_submit_timesheet,
        "description": "Creates and submits a new timesheet entry for approval. Use for logging or adding hours.",
        "parameters": {
            "type": "object",
            "properties": {
                "user_id": {"type": "string", "description": "The unique ID of the employee submitting the sheet. (Mandatory)"},
                "hours": {"type": "number", "description": "The number of hours to submit (e.g., 8.0)."},
                "date": {"type": "string", "description": "The date of the submission in YYYY-MM-DD format. Defaults to today."},
                "task": {"type": "string", "description": "A description of the task performed. Defaults to 'Unspecified project work.'"}
            },
            "required": ["user_id", "hours"]
        }
    },
    "tool_manager_approval": {
        "function_ref": tool_manager_approval,
        "description": "Retrieves a list of pending timesheets for a manager to review. Requires Manager role.",
        "parameters": {
            "type": "object",
            "properties": {
                "manager_id": {"type": "string", "description": "The unique ID of the manager performing the approval. (Mandatory)"}
            },
            "required": ["manager_id"]
        }
    },
    "tool_update_timesheet_status": {
        "function_ref": tool_update_timesheet_status,
        "description": "Allows a manager to approve or reject a pending timesheet by its ID. Requires Manager role.",
        "parameters": {
            "type": "object",
            "properties": {
                "manager_id": {"type": "string", "description": "The unique ID of the manager performing the action. (Mandatory)"},
                "timesheet_id": {"type": "string", "description": "The unique ID of the timesheet to update. (Mandatory)"},
                "new_status": {"type": "string", "description": "The new status to set. Must be 'Approved' or 'Rejected'. (Mandatory)"}
            },
            "required": ["manager_id", "timesheet_id", "new_status"]
        }
    }
}

# agent with custom function tools
timesheet_agent = LlmAgent(
    name="timesheet_agent",
    model=Gemini(model="gemini-2.5-flash-lite", retry_options=retry_config),
    instruction="You are a helpful timesheet assistant.",
    tools=[
        tool_view_queries,
        tool_submit_timesheet,
        tool_manager_approval,
        tool_update_timesheet_status
    ],
)

print("✅ Timesheet agent created with custom function tools")
print("🔧 Available tools:")
for tool_name, schema in TOOL_SCHEMAS.items():
    print(f"  • {tool_name} - {schema['description']}")

#Set up Session Management
# InMemorySessionService stores conversations in RAM (temporary)
session_service = InMemorySessionService()

# Create the Runner
runner = Runner(agent=timesheet_agent, app_name=APP_NAME, session_service=session_service)

print("✅ Stateful agent initialized!")
print(f"   - Application: {APP_NAME}")
print(f"   - User: {USER_ID}")
print(f"   - Using: {session_service.__class__.__name__}")

# --- Configuration and Database Setup ---

DB_NAME = 'timesheet_agent.db'
EMPLOYEE_ID = 'employee-demo-5678'
MANAGER_ID = 'manager-demo-1234'
CURRENT_USER_ID = EMPLOYEE_ID  # Start as the employee by default
CONN: Optional[sqlite3.Connection] = None

def init_db() -> Dict[str, Any]:
    """Initializes the SQLite database and sets up initial data."""
    global CONN
    logging.info("Initializing database...")
    # Check if DB file exists to decide if we need to seed data later
    #db_exists = os.path.exists(DB_NAME)
    is_new_db = not os.path.exists(DB_NAME)

    if CONN is None:
        CONN = sqlite3.connect(DB_NAME)
        logging.info(f"Database connection established to {DB_NAME}.")

    cursor = CONN.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS user_profiles (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            reportsTo TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS timesheets (
            id TEXT PRIMARY KEY,
            employeeId TEXT NOT NULL,
            managerId TEXT,
            date TEXT NOT NULL,
            hours REAL NOT NULL,
            task TEXT,
            status TEXT NOT NULL,
            submittedAt TEXT,
            approvedAt TEXT
        )
    """)

    CONN.commit()

    if is_new_db:
        logging.info("New database detected. Seeding with initial data...")
        seed_file = 'seed_data.sql'
        try:
            with open(seed_file, 'r') as f:
                sql_script = f.read()
            cursor.executescript(sql_script)
            CONN.commit()
            logging.info(f"Database seeded successfully from {seed_file}.")
        except FileNotFoundError:
            logging.warning(f"{seed_file} not found. Seeding with default manager and employee.")
            # Fallback to original seeding if file not found
            cursor.execute("INSERT INTO user_profiles (id, name, role, reportsTo) VALUES (?, ?, ?, ?)",
                           (MANAGER_ID, 'Default Manager', 'Manager', None))
            cursor.execute("INSERT INTO user_profiles (id, name, role, reportsTo) VALUES (?, ?, ?, ?)",
                           (EMPLOYEE_ID, 'Demo Employee', 'Employee', MANAGER_ID))
            CONN.commit()
            logging.info(f"Seeded manager profile: {MANAGER_ID} and employee profile: {EMPLOYEE_ID}")
        except sqlite3.Error as e:
            logging.error(f"Error seeding database from {seed_file}: {e}", exc_info=True)
            print(f"Error seeding database: {e}")

    # Load the initial user profile (which is the employee)
    cursor.execute("SELECT name, role, reportsTo FROM user_profiles WHERE id=?", (CURRENT_USER_ID,))
    profile_data = cursor.fetchone()

    if not profile_data:
        # This can happen if CURRENT_USER_ID is not in the seeded data.
        # Let's ensure the default user exists to prevent a crash.
        logging.warning(f"Current user ID '{CURRENT_USER_ID}' not found. Creating a default profile.")
        cursor.execute("INSERT OR IGNORE INTO user_profiles (id, name, role, reportsTo) VALUES (?, ?, ?, ?)",
                       (MANAGER_ID, 'Default Manager', 'Manager', None))
        cursor.execute("INSERT OR IGNORE INTO user_profiles (id, name, role, reportsTo) VALUES (?, ?, ?, ?)",
                       (EMPLOYEE_ID, 'Demo Employee', 'Employee', MANAGER_ID))
        CONN.commit()
        cursor.execute("SELECT name, role, reportsTo FROM user_profiles WHERE id=?", (CURRENT_USER_ID,))
        profile_data = cursor.fetchone()
        if not profile_data:
             raise RuntimeError(f"Could not load profile for user '{CURRENT_USER_ID}'. The database may be inconsistent.")

    logging.info(f"Database initialization complete. Current user: {profile_data[0]}")
    return {
        'id': CURRENT_USER_ID,
        'name': profile_data[0],
        'role': profile_data[1],
        'reportsTo': profile_data[2]
    }

# Initialize DB and get current profile
CURRENT_PROFILE = init_db()

# --- Utility Functions (Database Access) ---

def get_user_name(user_id: str) -> str:
    """Retrieves the display name for a given user ID."""
    if not CONN: return "Unknown"
    cursor = CONN.cursor()
    cursor.execute("SELECT name FROM user_profiles WHERE id=?", (user_id,))
    result = cursor.fetchone()
    return result[0] if result else f'User-{user_id[:4]}'

def get_timesheets(user_id=None, manager_id=None, status=None, limit=None) -> List[Dict[str, Any]]:
    """Filters timesheets based on criteria."""
    if not CONN: return []
    query = "SELECT id, date, hours, task, status, employeeId, submittedAt FROM timesheets WHERE 1=1"
    params = []

    if user_id:
        query += " AND employeeId = ?"
        params.append(user_id)
    if manager_id:
        query += " AND managerId = ?"
        params.append(manager_id)
    if status:
        query += " AND status = ?"
        params.append(status)

    query += " ORDER BY submittedAt DESC"
    if limit is not None:
        query += f" LIMIT {limit}"

    cursor = CONN.cursor()
    cursor.execute(query, params)

    columns = [desc[0] for desc in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

if __name__ == '__main__':
    import asyncio
    # This block now contains the main agent loop.
    print("=" * 70)
    print(f"ADK TIMESHEET AGENT CONSOLE (Python CLI)")
    print("-" * 70)
    print(f"User: {CURRENT_PROFILE['name']} | Role: {CURRENT_PROFILE['role']} (ID: {CURRENT_USER_ID[:8]}...)")
    print(f"Database: {DB_NAME}")
    print("NOTE: Using live Gemini API calls.")
    print("Tip: Type 'role manager' or 'role employee' to switch roles.")
    print("=" * 70)

    def set_role(new_role):
        """Updates the current user's role in the database and session."""
        logging.info(f"User requested role change to '{new_role}'.")
        global CURRENT_PROFILE
        if new_role not in ['Employee', 'Manager']:
            print("Invalid role. Must be 'Employee' or 'Manager'.")
            return
        if not CONN: return
        try:
            cursor = CONN.cursor()
            cursor.execute("UPDATE user_profiles SET role = ? WHERE id = ?", (new_role, CURRENT_USER_ID))
            CONN.commit()
            CURRENT_PROFILE['role'] = new_role
            logging.info(f"Role successfully updated to {new_role}.")
            print(f"\n[SYSTEM] Role updated to {new_role}.")
        except Exception as e:
            logging.error(f"Error updating role: {e}", exc_info=True)
            print(f"Error updating role: {e}")

    async def main_loop():
        session_name = "cli_session"
        try:
            session = await session_service.create_session(
                app_name=APP_NAME, user_id=CURRENT_USER_ID, session_id=session_name
            )
        except Exception:
            session = await session_service.get_session(
                app_name=APP_NAME, user_id=CURRENT_USER_ID, session_id=session_name
            )

        while True:
            print("\nAGENT: How can I help you? (e.g., 'view status', 'submit 7.5 hours for Project X', 'review approvals')")
            command = input("Your query: ").strip()

            if command.lower() in ('q', 'quit', 'exit'):
                logging.info("User requested to quit. Closing database connection.")
                print(f"\nGoodbye! Closing connection to {DB_NAME}.")
                if CONN:
                    CONN.close()
                break

            if command.lower().startswith('role '):
                parts = command.split(' ', 1)
                if len(parts) == 2:
                    set_role(parts[1].strip().capitalize())
                else:
                    print("Usage: role [manager|employee]")
                continue

            try:
                logging.info(f"Received user query: '{command}'")
                timesheet_agent.instruction = get_agent_instruction(CURRENT_USER_ID, CURRENT_PROFILE['role'])

                logging.info("Invoking agent chat...")
                await run_session(runner, CURRENT_USER_ID, session, command) # type: ignore
                logging.info("Agent returned response.")

            except Exception as e:
                logging.error(f"An unhandled error occurred in the agent loop: {e}", exc_info=True)
                print(f"\nAGENT ERROR: An unhandled error occurred during tool execution: {e}")

    asyncio.run(main_loop())
