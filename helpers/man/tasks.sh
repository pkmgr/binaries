#!/usr/bin/env bash
source ./.functions
printf_help "4" "Usage: tasks.sh [task_num] [command] ..."
printf_help "4" "list [all|complete]       - shows a list of tasks"
printf_help "4" "add [@project] desc       - adds a task to the given project"
printf_help "4" "<task_num> delete         - deletes a task and all its sessions"
printf_help "4" "<task_num> start          - starts a session for the given task"
printf_help "4" "[task_num] stop [durn]    - stops session(s) with optional duration"
printf_help "4" "<task_num> session <durn> - creates a session"
printf_help "4" "<task_num> switch [durn]  - switches session to a new task"
printf_help "4" "<task_num> done [durn]    - marks a task as complete"
printf_help "4" "<task_num> [info]         - shows information for the given task"
printf_help "4" "report [week]             - generate a weekly report"
printf_help "4" "cleanup                   - discard all completed tasks"
