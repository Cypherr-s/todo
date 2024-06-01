# Todo List Management Script

## Overview

This script is a simple command-line tool to manage todo tasks. Each task has a unique identifier, a title, a description, a location, a due date and time, and a completion marker. The script provides functionalities to create, update, delete, show, list, and search tasks.

## Design Choices

### Data Storage

- **File Format:** The data is stored in a plain text file (`todo.txt`)that should be created in advance, where each line represents a task.
- **Task Fields:** Each task has the following fields:
  - **ID:** A unique identifier generated based on the current timestamp.
  - **Title:** The title of the task (required).
  - **Description:** A description of the task (optional).
  - **Location:** The location of the task (optional).
  - **Due Date and Time:** The due date and time of the task in the format `YYYY-MM-DD HH:MM` (required).
  - **Completion Marker:** A marker indicating whether the task is completed (`1` for completed, `0` for not completed).

The fields are separated by a pipe (`|`) character.

### Code Organization

- **Functions:** The script is organized into functions for each action (e.g., `create_task`, `update_task`, `delete_task`, etc.). This modular approach makes the code easier to read and maintain.
- **Main Script:** The main part of the script handles command-line arguments to determine which function to call.
- **Error Handling:** The script includes error handling to ensure valid inputs and to handle unexpected issues gracefully. Errors are redirected to a log file (`error.log`).
