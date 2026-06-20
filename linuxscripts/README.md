# Linux Server Scripts

This folder contains examples of Linux administration, automation, and Bash scripting projects used to operate the Lonely Outcasts Path of Titans community server.

These systems were built to make the server easier to manage, reduce repetitive admin work, improve stability, and create a better experience for players and staff.

All public examples are sanitized. Sensitive information such as authentication tokens, private server identifiers, IP addresses, player IDs, and private configuration details have been removed.

---

# Featured Systems

## Teleport Command System

A custom teleport command system that allows players to use chat-based teleport commands to move to common locations on the map.

This was built to improve player convenience while still allowing staff to control and manage the system.

## Timeout Enforcement System

A timeout system used for rule enforcement.

It tracks timeout durations, blocks teleport commands for timed-out players, teleports players back to the timeout location if needed, and handles relog attempts.

## Automated Server Restart System

A scheduled restart system that warns players before restart, stops the server, clears stuck processes, restarts the service, reloads Creator Mode, and restarts helper scripts.

This helps keep the server stable and reduces the amount of manual work needed during daily maintenance.

## Marks Automation

A background script that automatically distributes marks to players at regular intervals.

This helps support the server's growth and marks settings without requiring staff to manually run commands all the time.

## Server Operations & Maintenance

Documentation and examples showing scheduled backups, maintenance tasks, systemd service management, process monitoring, and general server administration workflows.

---

# Skills Demonstrated

- Linux Server Administration
- Bash Scripting
- Process Management
- Log Monitoring
- Task Automation
- Service Management
- Scheduled Maintenance
- Troubleshooting & Debugging
- Community Server Operations
- Workflow Design

---

# Why This Matters

Running a live Path of Titans server means dealing with real problems as they happen.

These scripts and systems were built to solve issues I ran into while managing Lonely Outcasts, including restarts, player convenience, rule enforcement, backups, and keeping helper scripts running properly.

A lot of this was learned by trial and error, but each system helped make the server more stable and easier to manage.
