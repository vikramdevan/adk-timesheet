# ADK Timesheet Agent

The ADK Timesheet Agent is a conversational AI assistant designed to streamline timesheet management for both employees and managers. Built with the Google Agent Development Kit (ADK), this tool uses a Large Language Model (LLM) to understand natural language commands, allowing users to interact with a timesheet system through an intuitive command-line interface (CLI).

## Features

- **Conversational Interface**: No more GUIs. Log hours, check your status, and approve timesheets using plain English.
- **Role-Based Access Control**: The agent's capabilities adapt based on whether you are an 'Employee' or a 'Manager'.
- **Employee Functions**:
  - Submit new timesheet entries.
  - View current timesheet status, including pending items, monthly hours, and manager details.
- **Manager Functions**:
  - Review all pending timesheets from direct reports.
  - Approve or reject timesheets.
- **Stateful Sessions**: The agent remembers the context of your conversation for a more natural workflow.

## Technology Stack

- **Core Framework**: Python
- **Agent Library**: Google Agent Development Kit (ADK)
- **LLM**: Google Gemini
- **Database**: SQLite
- **Dependencies**: `python-dotenv`, `google-adk`, `google.genai`

## Prerequisites

- Python 3.9+
- A Google API Key with access to the Gemini API.

## Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/adk-timesheet.git
    cd adk-timesheet
    ```

2.  **Create and activate a virtual environment:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

3.  **Install the required dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Configure your environment variables:**
    - Create a file named `.env` in the root of the project directory.
    - Add your Google API key to this file:
      ```
      GOOGLE_API_KEY="YOUR_API_KEY_HERE"
      ```

## Running the Application

1.  **Launch the agent:**
    ```bash
    python agent.py
    ```
    This will initialize the SQLite database (`timesheet_agent.db`), seed it with sample data from `seed_data.sql`, and start the interactive CLI.

2.  **Interact with the agent:**
    Once running, the agent will prompt you for a query. You can type commands like:
    - `view status`
    - `submit 8 hours working on the new feature`
    - `review pending approvals`

## Usage

The agent understands a variety of commands. The default user role is **Employee**.

### Switching Roles

You can switch between 'Employee' and 'Manager' roles to see how the agent adapts its tools and permissions.

- **To switch to Manager:**
  ```
  role manager
  ```
- **To switch back to Employee:**
  ```
  role employee
  ```

### Example Commands

**As an Employee:**
- `check my status`
- `what's my history?`
- `log 7.5 hours for project documentation`
- `submit my time for yesterday: 8.1 hours doing code reviews`

**As a Manager:**
- `are there any pending approvals?`
- `show me the timesheets I need to review`
- (After reviewing pending sheets) `approve timesheet ts-34`
- `reject ts-39`

### Quitting the Application
To exit the agent, type `q`, `quit`, or `exit`.

## Database

The application uses a local SQLite database file (`timesheet_agent.db`) which is created automatically on the first run. The database is pre-populated with two sample users and a history of timesheet entries from the `seed_data.sql` file.

- **Default Manager**: `manager-demo-1234`
- **Default Employee**: `employee-demo-5678`

You can inspect the `timesheet_agent.db` file with any SQLite browser to see how the data changes as you interact with the agent.

## Project Structure

```
.
├── agent.py            # Main application logic, agent definition, and CLI loop
├── requirements.txt    # Python dependencies
├── seed_data.sql       # Initial data for the SQLite database
├── .env                # (To be created) For storing API keys
└── README.md           # This file
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request with any bug fixes or new features.