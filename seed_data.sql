-- seed_data.sql

-- Clear existing data to ensure a clean slate on first run
DELETE FROM user_profiles;
DELETE FROM timesheets;

-- Insert User Profiles

INSERT OR IGNORE INTO user_profiles (id, name, role, reportsTo) VALUES 
('manager-demo-1234', 'Default Manager', 'Manager', NULL);

INSERT OR IGNORE INTO user_profiles (id, name, role, reportsTo) VALUES 
('employee-demo-5678', 'Test Employee-1', 'Employee', 'manager-demo-1234');

INSERT OR IGNORE INTO user_profiles (id, name, role, reportsTo) VALUES 
('employee-demo-5679', 'Test Employee-2', 'Employee', 'employee-demo-5678');


/*
TEST DATA: OCTOBER 2025 (All Approved)
Employee: employee-demo-5678, Manager: manager-demo-1234
*/

-- October 1 (Wed) - October 3 (Fri)
INSERT INTO timesheets VALUES ('ts-1', 'employee-demo-5678', 'manager-demo-1234', '2025-10-01', 8.0, 'Initial project setup and planning.', 'Approved', '2025-10-01T17:30:00Z', '2025-10-02T09:15:00Z');
INSERT INTO timesheets VALUES ('ts-2', 'employee-demo-5678', 'manager-demo-1234', '2025-10-02', 8.5, 'Developed API endpoints for user authentication.', 'Approved', '2025-10-02T18:00:00Z', '2025-10-03T10:05:00Z');
INSERT INTO timesheets VALUES ('ts-3', 'employee-demo-5678', 'manager-demo-1234', '2025-10-03', 7.5, 'Wrote unit tests for core services.', 'Approved', '2025-10-03T17:00:00Z', '2025-10-06T11:45:00Z');

-- October 6 (Mon) - October 10 (Fri)
INSERT INTO timesheets VALUES ('ts-4', 'employee-demo-5678', 'manager-demo-1234', '2025-10-06', 8.0, 'Integrated frontend components with new API.', 'Approved', '2025-10-06T17:45:00Z', '2025-10-07T09:30:00Z');
INSERT INTO timesheets VALUES ('ts-5', 'employee-demo-5678', 'manager-demo-1234', '2025-10-07', 7.8, 'Debugged critical issue in payment processing.', 'Approved', '2025-10-07T17:30:00Z', '2025-10-08T10:00:00Z');
INSERT INTO timesheets VALUES ('ts-6', 'employee-demo-5678', 'manager-demo-1234', '2025-10-08', 8.2, 'Refactored database schema for performance.', 'Approved', '2025-10-08T17:50:00Z', '2025-10-09T09:00:00Z');
INSERT INTO timesheets VALUES ('ts-7', 'employee-demo-5678', 'manager-demo-1234', '2025-10-09', 8.0, 'Peer code review and documentation update.', 'Approved', '2025-10-09T17:35:00Z', '2025-10-10T11:20:00Z');
INSERT INTO timesheets VALUES ('ts-8', 'employee-demo-5678', 'manager-demo-1234', '2025-10-10', 7.9, 'Deployed release candidate to staging environment.', 'Approved', '2025-10-10T17:20:00Z', '2025-10-13T09:40:00Z');

-- October 13 (Mon) - October 17 (Fri)
INSERT INTO timesheets VALUES ('ts-9', 'employee-demo-5678', 'manager-demo-1234', '2025-10-13', 8.1, 'Met with product team for sprint planning.', 'Approved', '2025-10-13T17:40:00Z', '2025-10-14T09:55:00Z');
INSERT INTO timesheets VALUES ('ts-10', 'employee-demo-5678', 'manager-demo-1234', '2025-10-14', 8.0, 'Began work on new dashboard feature (UI/UX).', 'Approved', '2025-10-14T17:30:00Z', '2025-10-15T10:30:00Z');
INSERT INTO timesheets VALUES ('ts-11', 'employee-demo-5678', 'manager-demo-1234', '2025-10-15', 7.7, 'Implemented data fetching logic for dashboard.', 'Approved', '2025-10-15T17:15:00Z', '2025-10-16T11:10:00Z');
INSERT INTO timesheets VALUES ('ts-12', 'employee-demo-5678', 'manager-demo-1234', '2025-10-16', 8.3, 'Prepared presentation for team review.', 'Approved', '2025-10-16T18:00:00Z', '2025-10-17T09:25:00Z');
INSERT INTO timesheets VALUES ('ts-13', 'employee-demo-5678', 'manager-demo-1234', '2025-10-17', 8.0, 'Fixed accessibility issues across the application.', 'Approved', '2025-10-17T17:30:00Z', '2025-10-20T10:00:00Z');

-- October 20 (Mon) - October 24 (Fri)
INSERT INTO timesheets VALUES ('ts-14', 'employee-demo-5678', 'manager-demo-1234', '2025-10-20', 8.0, 'Security audit preparation and review.', 'Approved', '2025-10-20T17:40:00Z', '2025-10-21T09:35:00Z');
INSERT INTO timesheets VALUES ('ts-15', 'employee-demo-5678', 'manager-demo-1234', '2025-10-21', 8.2, 'Addressed minor bugs reported in production.', 'Approved', '2025-10-21T17:55:00Z', '2025-10-22T10:15:00Z');
INSERT INTO timesheets VALUES ('ts-16', 'employee-demo-5678', 'manager-demo-1234', '2025-10-22', 7.9, 'Optimized image loading performance.', 'Approved', '2025-10-22T17:25:00Z', '2025-10-23T09:05:00Z');
INSERT INTO timesheets VALUES ('ts-17', 'employee-demo-5678', 'manager-demo-1234', '2025-10-23', 8.1, 'Created new CI/CD pipeline configuration.', 'Approved', '2025-10-23T17:45:00Z', '2025-10-24T11:30:00Z');
INSERT INTO timesheets VALUES ('ts-18', 'employee-demo-5678', 'manager-demo-1234', '2025-10-24', 8.0, 'Assisted junior developer with onboarding.', 'Approved', '2025-10-24T17:30:00Z', '2025-10-27T10:45:00Z');

-- October 27 (Mon) - October 31 (Fri)
INSERT INTO timesheets VALUES ('ts-19', 'employee-demo-5678', 'manager-demo-1234', '2025-10-27', 8.3, 'Discovered and patched XSS vulnerability.', 'Approved', '2025-10-27T18:00:00Z', '2025-10-28T09:10:00Z');
INSERT INTO timesheets VALUES ('ts-20', 'employee-demo-5678', 'manager-demo-1234', '2025-10-28', 7.9, 'Updated third-party library dependencies.', 'Approved', '2025-10-28T17:25:00Z', '2025-10-29T10:00:00Z');
INSERT INTO timesheets VALUES ('ts-21', 'employee-demo-5678', 'manager-demo-1234', '2025-10-29', 8.0, 'Prepared quarterly team performance report.', 'Approved', '2025-10-29T17:30:00Z', '2025-10-30T11:25:00Z');
INSERT INTO timesheets VALUES ('ts-22', 'employee-demo-5678', 'manager-demo-1234', '2025-10-30', 8.2, 'Final testing before production deployment.', 'Approved', '2025-10-30T17:55:00Z', '2025-10-31T09:40:00Z');
INSERT INTO timesheets VALUES ('ts-23', 'employee-demo-5678', 'manager-demo-1234', '2025-10-31', 8.0, 'Monitored production release post-deployment.', 'Approved', '2025-10-31T17:30:00Z', '2025-11-03T10:10:00Z');

-----------------------------------------------------------
-- TEST DATA: NOVEMBER 2025 (First 2 weeks Approved)
-----------------------------------------------------------

-- November 3 (Mon) - November 7 (Fri) - Approved
INSERT INTO timesheets VALUES ('ts-24', 'employee-demo-5678', 'manager-demo-1234', '2025-11-03', 8.1, 'Began planning for Q4 feature roadmap.', 'Approved', '2025-11-03T17:40:00Z', '2025-11-04T09:35:00Z');
INSERT INTO timesheets VALUES ('ts-25', 'employee-demo-5678', 'manager-demo-1234', '2025-11-04', 8.0, 'Prototype new user preference settings page.', 'Approved', '2025-11-04T17:30:00Z', '2025-11-05T10:15:00Z');
INSERT INTO timesheets VALUES ('ts-26', 'employee-demo-5678', 'manager-demo-1234', '2025-11-05', 7.9, 'Reviewed technical debt backlog items.', 'Approved', '2025-11-05T17:25:00Z', '2025-11-06T09:20:00Z');
INSERT INTO timesheets VALUES ('ts-27', 'employee-demo-5678', 'manager-demo-1234', '2025-11-06', 8.2, 'Conducted A/B testing analysis meeting.', 'Approved', '2025-11-06T17:55:00Z', '2025-11-07T11:40:00Z');
INSERT INTO timesheets VALUES ('ts-28', 'employee-demo-5678', 'manager-demo-1234', '2025-11-07', 8.0, 'Fixed minor CSS display bugs.', 'Approved', '2025-11-07T17:30:00Z', '2025-11-10T10:05:00Z');

-- November 10 (Mon) - November 14 (Fri) - Approved
INSERT INTO timesheets VALUES ('ts-29', 'employee-demo-5678', 'manager-demo-1234', '2025-11-10', 8.3, 'Started implementation of user preference API.', 'Approved', '2025-11-10T18:00:00Z', '2025-11-11T09:50:00Z');
INSERT INTO timesheets VALUES ('ts-30', 'employee-demo-5678', 'manager-demo-1234', '2025-11-11', 8.0, 'Updated build scripts for faster deployment.', 'Approved', '2025-11-11T17:35:00Z', '2025-11-12T10:25:00Z');
INSERT INTO timesheets VALUES ('ts-31', 'employee-demo-5678', 'manager-demo-1234', '2025-11-12', 7.8, 'Collaborated on database query optimization.', 'Approved', '2025-11-12T17:20:00Z', '2025-11-13T09:15:00Z');
INSERT INTO timesheets VALUES ('ts-32', 'employee-demo-5678', 'manager-demo-1234', '2025-11-13', 8.1, 'Finalized user preference settings backend.', 'Approved', '2025-11-13T17:45:00Z', '2025-11-14T11:35:00Z');
INSERT INTO timesheets VALUES ('ts-33', 'employee-demo-5678', 'manager-demo-1234', '2025-11-14', 8.0, 'Wrote integration tests for preference feature.', 'Approved', '2025-11-14T17:30:00Z', '2025-11-17T10:55:00Z');

-----------------------------------------------------------
-- TEST DATA: NOVEMBER 2025 (Last 2 weeks Pending)
-----------------------------------------------------------

-- November 17 (Mon) - November 21 (Fri) - Pending
INSERT INTO timesheets VALUES ('ts-34', 'employee-demo-5678', 'manager-demo-1234', '2025-11-17', 8.2, 'Started work on third-party integration module.', 'Pending', '2025-11-17T17:50:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-35', 'employee-demo-5678', 'manager-demo-1234', '2025-11-18', 8.0, 'Setup authentication flow for external API.', 'Pending', '2025-11-18T17:30:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-36', 'employee-demo-5678', 'manager-demo-1234', '2025-11-19', 7.9, 'Daily standup and code review session.', 'Pending', '2025-11-19T17:20:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-37', 'employee-demo-5678', 'manager-demo-1234', '2025-11-20', 8.1, 'Refined UI elements based on QA feedback.', 'Pending', '2025-11-20T17:40:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-38', 'employee-demo-5678', 'manager-demo-1234', '2025-11-21', 8.0, 'Prepared release notes for upcoming sprint.', 'Pending', '2025-11-21T17:30:00Z', NULL);

-- November 24 (Mon) - November 28 (Fri) - Pending
INSERT INTO timesheets VALUES ('ts-39', 'employee-demo-5678', 'manager-demo-1234', '2025-11-24', 7.7, 'Troubleshot environment variable configuration.', 'Pending', '2025-11-24T17:15:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-40', 'employee-demo-5678', 'manager-demo-1234', '2025-11-25', 8.0, 'Documentation for new third-party module.', 'Pending', '2025-11-25T17:30:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-41', 'employee-demo-5678', 'manager-demo-1234', '2025-11-26', 8.3, 'Finalized integration tests; 100% coverage.', 'Pending', '2025-11-26T18:00:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-42', 'employee-demo-5678', 'manager-demo-1234', '2025-11-27', 8.0, 'Internal demo of new preference feature.', 'Pending', '2025-11-27T17:30:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-43', 'employee-demo-5678', 'manager-demo-1234', '2025-11-28', 7.5, 'Holiday staffing coverage planning.', 'Pending', '2025-11-28T17:00:00Z', NULL);

/*
TEST DATA: OCTOBER 2025 (All Approved)
Employee: employee-demo-5679, Manager: employee-demo-5678
*/

-- October 1 (Wed) - October 3 (Fri)
INSERT INTO timesheets VALUES ('ts-44', 'employee-demo-5679', 'employee-demo-5678', '2025-10-01', 7.5, 'Researched new cloud deployment strategies.', 'Approved', '2025-10-01T17:00:00Z', '2025-10-02T09:45:00Z');
INSERT INTO timesheets VALUES ('ts-45', 'employee-demo-5679', 'employee-demo-5678', '2025-10-02', 8.2, 'Documented existing microservice architecture.', 'Approved', '2025-10-02T17:50:00Z', '2025-10-03T10:15:00Z');
INSERT INTO timesheets VALUES ('ts-46', 'employee-demo-5679', 'employee-demo-5678', '2025-10-03', 8.0, 'Configured monitoring alerts for production servers.', 'Approved', '2025-10-03T17:30:00Z', '2025-10-06T11:00:00Z');

-- October 6 (Mon) - October 10 (Fri)
INSERT INTO timesheets VALUES ('ts-47', 'employee-demo-5679', 'employee-demo-5678', '2025-10-06', 8.5, 'Troubleshooting database connection pooling.', 'Approved', '2025-10-06T18:15:00Z', '2025-10-07T09:50:00Z');
INSERT INTO timesheets VALUES ('ts-48', 'employee-demo-5679', 'employee-demo-5678', '2025-10-07', 7.8, 'Implemented rate limiting on public endpoints.', 'Approved', '2025-10-07T17:20:00Z', '2025-10-08T10:35:00Z');
INSERT INTO timesheets VALUES ('ts-49', 'employee-demo-5679', 'employee-demo-5678', '2025-10-08', 8.0, 'Attended cross-team synchronization meeting.', 'Approved', '2025-10-08T17:30:00Z', '2025-10-09T09:10:00Z');
INSERT INTO timesheets VALUES ('ts-50', 'employee-demo-5679', 'employee-demo-5678', '2025-10-09', 8.1, 'Wrote Terraform scripts for infrastructure update.', 'Approved', '2025-10-09T17:40:00Z', '2025-10-10T11:50:00Z');
INSERT INTO timesheets VALUES ('ts-51', 'employee-demo-5679', 'employee-demo-5678', '2025-10-10', 7.9, 'Ran vulnerability scanning on current codebase.', 'Approved', '2025-10-10T17:25:00Z', '2025-10-13T09:20:00Z');

-- October 13 (Mon) - October 17 (Fri)
INSERT INTO timesheets VALUES ('ts-52', 'employee-demo-5679', 'employee-demo-5678', '2025-10-13', 8.0, 'Mentored new intern on best coding practices.', 'Approved', '2025-10-13T17:30:00Z', '2025-10-14T10:10:00Z');
INSERT INTO timesheets VALUES ('ts-53', 'employee-demo-5679', 'employee-demo-5678', '2025-10-14', 8.2, 'Developed internal tooling for log analysis.', 'Approved', '2025-10-14T17:55:00Z', '2025-10-15T10:40:00Z');
INSERT INTO timesheets VALUES ('ts-54', 'employee-demo-5679', 'employee-demo-5678', '2025-10-15', 7.7, 'Prepared capacity planning report for next quarter.', 'Approved', '2025-10-15T17:10:00Z', '2025-10-16T09:30:00Z');
INSERT INTO timesheets VALUES ('ts-55', 'employee-demo-5679', 'employee-demo-5678', '2025-10-16', 8.3, 'Integrated new monitoring dashboard into Grafana.', 'Approved', '2025-10-16T18:00:00Z', '2025-10-17T11:15:00Z');
INSERT INTO timesheets VALUES ('ts-56', 'employee-demo-5679', 'employee-demo-5678', '2025-10-17', 8.0, 'Responded to 3 production incidents (minor).', 'Approved', '2025-10-17T17:30:00Z', '2025-10-20T10:30:00Z');

-- October 20 (Mon) - October 24 (Fri)
INSERT INTO timesheets VALUES ('ts-57', 'employee-demo-5679', 'employee-demo-5678', '2025-10-20', 8.1, 'Updated Kubernetes deployment manifest.', 'Approved', '2025-10-20T17:45:00Z', '2025-10-21T09:05:00Z');
INSERT INTO timesheets VALUES ('ts-58', 'employee-demo-5679', 'employee-demo-5678', '2025-10-21', 8.0, 'Reviewed all pull requests from the development team.', 'Approved', '2025-10-21T17:30:00Z', '2025-10-22T10:00:00Z');
INSERT INTO timesheets VALUES ('ts-59', 'employee-demo-5679', 'employee-demo-5678', '2025-10-22', 7.9, 'Automated SSL certificate renewal process.', 'Approved', '2025-10-22T17:25:00Z', '2025-10-23T11:20:00Z');
INSERT INTO timesheets VALUES ('ts-60', 'employee-demo-5679', 'employee-demo-5678', '2025-10-23', 8.2, 'Conducted disaster recovery simulation test.', 'Approved', '2025-10-23T17:55:00Z', '2025-10-24T09:40:00Z');
INSERT INTO timesheets VALUES ('ts-61', 'employee-demo-5679', 'employee-demo-5678', '2025-10-24', 8.0, 'Created documentation for rollback procedures.', 'Approved', '2025-10-24T17:30:00Z', '2025-10-27T10:15:00Z');

-- October 27 (Mon) - October 31 (Fri)
INSERT INTO timesheets VALUES ('ts-62', 'employee-demo-5679', 'employee-demo-5678', '2025-10-27', 8.3, 'Optimized CI build times by caching dependencies.', 'Approved', '2025-10-27T18:00:00Z', '2025-10-28T09:25:00Z');
INSERT INTO timesheets VALUES ('ts-63', 'employee-demo-5679', 'employee-demo-5678', '2025-10-28', 7.9, 'Investigated latency spikes in API gateway.', 'Approved', '2025-10-28T17:25:00Z', '2025-10-29T10:50:00Z');
INSERT INTO timesheets VALUES ('ts-64', 'employee-demo-5679', 'employee-demo-5678', '2025-10-29', 8.0, 'Set up log streaming to external aggregation service.', 'Approved', '2025-10-29T17:30:00Z', '2025-10-30T09:00:00Z');
INSERT INTO timesheets VALUES ('ts-65', 'employee-demo-5679', 'employee-demo-5678', '2025-10-30', 8.2, 'Reviewed system resource utilization trends.', 'Approved', '2025-10-30T17:50:00Z', '2025-10-31T11:10:00Z');
INSERT INTO timesheets VALUES ('ts-66', 'employee-demo-5679', 'employee-demo-5678', '2025-10-31', 8.0, 'Final preparation for weekend maintenance window.', 'Approved', '2025-10-31T17:30:00Z', '2025-11-03T09:40:00Z');

-----------------------------------------------------------
-- TEST DATA: NOVEMBER 2025 (First 2 weeks Approved)
-----------------------------------------------------------

-- November 3 (Mon) - November 7 (Fri) - Approved
INSERT INTO timesheets VALUES ('ts-67', 'employee-demo-5679', 'employee-demo-5678', '2025-11-03', 8.1, 'Executed major database migration script.', 'Approved', '2025-11-03T17:40:00Z', '2025-11-04T10:05:00Z');
INSERT INTO timesheets VALUES ('ts-68', 'employee-demo-5679', 'employee-demo-5678', '2025-11-04', 8.0, 'Post-migration health checks and validation.', 'Approved', '2025-11-04T17:30:00Z', '2025-11-05T11:30:00Z');
INSERT INTO timesheets VALUES ('ts-69', 'employee-demo-5679', 'employee-demo-5678', '2025-11-05', 7.9, 'Optimized network security group rules.', 'Approved', '2025-11-05T17:20:00Z', '2025-11-06T09:20:00Z');
INSERT INTO timesheets VALUES ('ts-70', 'employee-demo-5679', 'employee-demo-5678', '2025-11-06', 8.2, 'Collaborated with security team on internal audit.', 'Approved', '2025-11-06T17:55:00Z', '2025-11-07T10:15:00Z');
INSERT INTO timesheets VALUES ('ts-71', 'employee-demo-5679', 'employee-demo-5678', '2025-11-07', 8.0, 'Researched best practices for secret management.', 'Approved', '2025-11-07T17:30:00Z', '2025-11-10T09:00:00Z');

-- November 10 (Mon) - November 14 (Fri) - Approved
INSERT INTO timesheets VALUES ('ts-72', 'employee-demo-5679', 'employee-demo-5678', '2025-11-10', 8.3, 'Setup new development environments for team.', 'Approved', '2025-11-10T18:00:00Z', '2025-11-11T10:40:00Z');
INSERT INTO timesheets VALUES ('ts-73', 'employee-demo-5679', 'employee-demo-5678', '2025-11-11', 8.0, 'Wrote detailed technical specifications for Q1.', 'Approved', '2025-11-11T17:30:00Z', '2025-11-12T11:15:00Z');
INSERT INTO timesheets VALUES ('ts-74', 'employee-demo-5679', 'employee-demo-5678', '2025-11-12', 7.8, 'Debugged intermittent errors in CI/CD pipeline.', 'Approved', '2025-11-12T17:15:00Z', '2025-11-13T09:35:00Z');
INSERT INTO timesheets VALUES ('ts-75', 'employee-demo-5679', 'employee-demo-5678', '2025-11-13', 8.1, 'Automated dependency auditing process.', 'Approved', '2025-11-13T17:45:00Z', '2025-11-14T10:00:00Z');
INSERT INTO timesheets VALUES ('ts-76', 'employee-demo-5679', 'employee-demo-5678', '2025-11-14', 8.0, 'Finalized Q4 budget proposal for cloud services.', 'Approved', '2025-11-14T17:30:00Z', '2025-11-17T11:20:00Z');

-----------------------------------------------------------
-- TEST DATA: NOVEMBER 2025 (Last 2 weeks Pending)
-----------------------------------------------------------

-- November 17 (Mon) - November 21 (Fri) - Pending
INSERT INTO timesheets VALUES ('ts-77', 'employee-demo-5679', 'employee-demo-5678', '2025-11-17', 8.2, 'Investigated high CPU usage on reporting service.', 'Pending', '2025-11-17T17:50:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-78', 'employee-demo-5679', 'employee-demo-5678', '2025-11-18', 8.0, 'Refactored internal logging library to reduce overhead.', 'Pending', '2025-11-18T17:30:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-79', 'employee-demo-5679', 'employee-demo-5678', '2025-11-19', 7.9, 'Daily check-ins and knowledge sharing session.', 'Pending', '2025-11-19T17:25:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-80', 'employee-demo-5679', 'employee-demo-5678', '2025-11-20', 8.1, 'Tested new zero-downtime deployment strategy.', 'Pending', '2025-11-20T17:40:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-81', 'employee-demo-5679', 'employee-demo-5678', '2025-11-21', 8.0, 'On-call shift handoff and documentation updates.', 'Pending', '2025-11-21T17:30:00Z', NULL);

-- November 24 (Mon) - November 28 (Fri) - Pending
INSERT INTO timesheets VALUES ('ts-82', 'employee-demo-5679', 'employee-demo-5678', '2025-11-24', 7.7, 'Reviewed and audited IAM policies for least privilege.', 'Pending', '2025-11-24T17:15:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-83', 'employee-demo-5679', 'employee-demo-5678', '2025-11-25', 8.0, 'Prepared production metrics report for management.', 'Pending', '2025-11-25T17:30:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-84', 'employee-demo-5679', 'employee-demo-5678', '2025-11-26', 8.3, 'Wrote script to automatically clean up old log files.', 'Pending', '2025-11-26T18:00:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-85', 'employee-demo-5679', 'employee-demo-5678', '2025-11-27', 8.0, 'Pre-holiday system stabilization checks.', 'Pending', '2025-11-27T17:30:00Z', NULL);
INSERT INTO timesheets VALUES ('ts-86', 'employee-demo-5679', 'employee-demo-5678', '2025-11-28', 7.5, 'Final system checks before weekend closure.', 'Pending', '2025-11-28T17:00:00Z', NULL);