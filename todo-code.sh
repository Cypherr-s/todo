#!/bin/bash

TODO_FILE="todo.txt"

# Function to print usage information
usage() {
    echo "Usage: $0 <action> [arguments]"
    echo "Actions:"
    echo "  create   - Create a new task"
    echo "  update   - Update an existing task"
    echo "  delete   - Delete a task"
    echo "  show     - Show information about a task"
    echo "  list     - List tasks of a given day"
    echo "  search   - Search for a task by title"
    echo "  help     - Display the help menu"
    exit 1
}

# Function to display help menu
display_help() {
    echo "Usage: $0 <action> [arguments]"
    echo "Actions:"
    echo "  create   - Create a new task"
    echo "            Arguments: None"
    echo "            Usage: ./todo.sh create"
    echo
    echo "  update   - Update an existing task"
    echo "            Arguments: <task_id>"
    echo "            Usage: ./todo.sh update <task_id>"
    echo
    echo "  delete   - Delete a task"
    echo "            Arguments: <task_id>"
    echo "            Usage: ./todo.sh delete <task_id>"
    echo
    echo "  show     - Show information about a task"
    echo "            Arguments: <task_id>"
    echo "            Usage: ./todo.sh show <task_id>"
    echo
    echo "  list     - List tasks of a given day"
    echo "            Arguments: None"
    echo "            Usage: ./todo.sh list"
    echo
    echo "  search   - Search for a task by title"
    echo "            Arguments: <title>"
    echo "            Usage: ./todo.sh search <title>"
    echo
    echo "  help     - Display this help menu"
    echo "            Arguments: None"
    echo "            Usage: ./todo.sh help"
    echo
    echo "Description:"
    echo "  This script manages todo tasks. Each task has a unique identifier, a title, a description, a location, a due date and time, and a completion marker."
    echo "  The script can create, update, delete, show information about, list, and search for tasks."
    exit 0
}

# Function to create a new task
create_task() {
    echo "Enter task title:"
    read title
    if [[ -z "$title" ]]; then
        echo "Title cannot be empty." >&2
        exit 1
    fi

    echo "Enter task description (optional):"
    read description

    echo "Enter task location (optional):"
    read location

    echo "Enter due date (YYYY-MM-DD):"
    read due_date
    if ! date -d "$due_date" &>/dev/null; then
        echo "Invalid date format. Please use YYYY-MM-DD." >&2
        exit 1
    fi

    while true; do
        echo "Enter due time (HH:MM, 24-hour format):"
        read due_time
        if [[ -z "$due_time" ]]; then
            echo "Time cannot be empty." >&2
        elif ! date -d "$due_time" &>/dev/null; then
            echo "Invalid time format. Please use HH:MM, 24-hour format." >&2
        else
            break
        fi
    done

    # Generate unique identifier for task
    while true; do
        task_id=$(date +%s | tail -c 5)
        if ! grep -q "^$task_id" "$TODO_FILE"; then
            break
        fi
    done

    echo "$task_id|$title|$description|$location|$due_date $due_time|0" >> "$TODO_FILE"
    echo "Task created with ID: $task_id"
}

# Function to update an existing task
update_task() {
    echo "Enter task ID to update:"
    read task_id

    # Check if task ID exists
    if ! grep -q "^$task_id" "$TODO_FILE"; then
        echo "Task with ID $task_id not found." >&2
        exit 1
    fi

    echo "Enter new title (press Enter to keep current):"
    read new_title

    echo "Enter new description (press Enter to keep current):"
    read new_description

    echo "Enter new location (press Enter to keep current):"
    read new_location

    echo "Enter new due date (YYYY-MM-DD, press Enter to keep current):"
    read new_due_date

    while true; do
        echo "Enter new due time (HH:MM, 24-hour format, press Enter to keep current):"
        read new_due_time
        if [[ -z "$new_due_time" ]]; then
            break
        elif ! date -d "$new_due_time" &>/dev/null; then
            echo "Invalid time format. Please use HH:MM, 24-hour format." >&2
        else
            break
        fi
    done

    # Read the existing line from the file
    old_line=$(grep "^$task_id" "$TODO_FILE")

    # Replace fields with new values if provided
    IFS="|" read -r id title description location due_date_time status <<< "$old_line"
    [[ -n "$new_title" ]] && title="$new_title"
    [[ -n "$new_description" ]] && description="$new_description"
    [[ -n "$new_location" ]] && location="$new_location"
    [[ -n "$new_due_date" ]] && due_date_time="$new_due_date $(echo $due_date_time | awk '{print $2}')"
    [[ -n "$new_due_time" ]] && due_date_time="$(echo $due_date_time | awk '{print $1}') $new_due_time"

    new_line="$id|$title|$description|$location|$due_date_time|$status"

    # Debug output to verify the changes
    echo "Old Line: $old_line"
    echo "New Line: $new_line"

    # Escape special characters in the old and new lines
    escaped_old_line=$(echo "$old_line" | sed 's/[\/&]/\\&/g')
    escaped_new_line=$(echo "$new_line" | sed 's/[\/&]/\\&/g')

    # Write the modified line back to the file
    sed -i "s|$escaped_old_line|$escaped_new_line|" "$TODO_FILE"
    echo "Task updated successfully."
}

# Function to delete a task
delete_task() {
    echo "Enter task ID to delete:"
    read task_id

    # Check if task ID exists
    if ! grep -q "^$task_id" "$TODO_FILE"; then
        echo "Task with ID $task_id not found." >&2
        exit 1
    fi

    # Remove the line corresponding to the task ID
    sed -i "/^$task_id/d" "$TODO_FILE"
    echo "Task with ID $task_id deleted successfully."
}

# Function to show information about a task
show_task() {
    echo "Enter task ID to show:"
    read task_id

    # Check if task ID exists
    if ! grep -q "^$task_id" "$TODO_FILE"; then
        echo "Task with ID $task_id not found." >&2
        exit 1
    fi

    # Display the task information
    grep "^$task_id" "$TODO_FILE"
}

# Function to list tasks of a given day
list_tasks() {
    echo "Enter date (YYYY-MM-DD) to list tasks:"
    read list_date

    # Display completed tasks
    echo "Completed tasks for $list_date:"
    grep -E "\|$list_date [0-9]{2}:[0-9]{2}\|1$" "$TODO_FILE" | sed 's/[^|]*|//'

    # Display uncompleted tasks
    echo "Uncompleted tasks for $list_date:"
    grep -E "\|$list_date [0-9]{2}:[0-9]{2}\|0$" "$TODO_FILE" | sed 's/[^|]*|//'
}

# Function to search for a task by title
search_task() {
    echo "Enter title to search:"
    read search_title

    # Search for the task by title and format the output
    grep -i "$search_title" "$TODO_FILE" | while IFS= read -r line; do
        id=$(echo "$line" | awk -F "|" '{print $1}')
        title=$(echo "$line" | awk -F "|" '{print $2}')
        description=$(echo "$line" | awk -F "|" '{print $3}')
        location=$(echo "$line" | awk -F "|" '{print $4}')
        due_date_time=$(echo "$line" | awk -F "|" '{print $5}')
        status=$(echo "$line" | awk -F "|" '{print $6}')
        
        # Check if fields are empty and provide default messages
        [ -z "$title" ] && title="<No Title>"
        [ -z "$description" ] && description="<No Description>"
        [ -z "$location" ] && location="<No Location>"
        [ -z "$due_date_time" ] && due_date_time="<No Due Date & Time>"
        [ "$status" -eq 0 ] && status="undone" || status="done"

        echo "--------------------------------"
        echo "Task:"
        echo "ID: $id"
        echo "Title: $title"
        echo "Description: $description"
        echo "Location: $location"
        echo "Due Date & Time: $due_date_time"
        echo "Status: $status"
        echo "--------------------------------"
    done
}

# Function to display finished and unfinished tasks of today
display_today_tasks() {
    today=$(date "+%Y-%m-%d")
    echo "Today's date: $today"
    
    completed_tasks=$(grep -E "\|$today [0-9]{2}:[0-9]{2}\|1$" "$TODO_FILE")
    uncompleted_tasks=$(grep -E "\|$today [0-9]{2}:[0-9]{2}\|0$" "$TODO_FILE")
    
    echo "Completed tasks for $today:"
    if [[ -z "$completed_tasks" ]]; then
        echo "No completed tasks for today."
    else
        echo "$completed_tasks" | awk -F'|' '{print $2 " - " $5}'
    fi
    
    echo "Uncompleted tasks for $today:"
    if [[ -z "$uncompleted_tasks" ]]; then
        echo "No uncompleted tasks for today."
    else
        echo "$uncompleted_tasks" | awk -F'|' '{print $2 " - " $5}'
    fi
}

# Main script
if [ $# -eq 0 ]; then
    display_today_tasks
    exit 0
fi

action=$1
case $action in
    "create")
        create_task
        ;;
    "update")
        update_task
        ;;
    "delete")
        delete_task
        ;;
    "show")
        show_task
        ;;
    "list")
        list_tasks
        ;;
    "search")
        search_task
        ;;
    "help")
        display_help
        ;;
    *)
        echo "Invalid action. Use '$0 help' to see the valid options." >&2
        usage
        ;;
esac
