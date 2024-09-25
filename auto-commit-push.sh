#!/bin/bash

# Define the working directory where the repository is located
# TODO: Modify this to the path of your repository
WORKING_DIR="$HOME/.config/hypr/"

# Enable or disable logging (true to enable, false to disable)
LOGGING_ENABLED=false # NOTE: Set to false to disable logging

# Define log files
LOG_DIR="$WORKING_DIR/logs"
NOTHING_CHANGED_LOG="$LOG_DIR/nothing_changed.log"
COMMITS_LOG="$LOG_DIR/commits.log"

# Create log directory if it doesn't exist
if [ "$LOGGING_ENABLED" = true ]; then
    mkdir -p "$LOG_DIR"
fi

# Navigate to your repository directory
cd "$WORKING_DIR" || exit

# Add all changes excluding the logs directory
git add -- $(git ls-files -mo --exclude="$LOG_DIR/*")

# Check if there are any changes to commit excluding the logs directory
if ! git diff --cached --quiet -- . ":(exclude)$LOG_DIR/*"; then
    # Get the current date and time
    CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

    # Get the list of changed and added files excluding the logs directory
    CHANGED_FILES=$(git diff --name-only --cached | grep -v "^logs/")

    # Format the commit message with the current date and list of changed files
    COMMIT_MESSAGE="Automated commit and push on $CURRENT_DATE by script
Changed files:
$CHANGED_FILES"

    # Commit the changes with the formatted message
    git commit -m "$COMMIT_MESSAGE"

    # Rename the default branch from master to main if necessary
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    if [ "$CURRENT_BRANCH" = "master" ]; then
        git branch -m main
    fi

    # Push the changes to the remote repository
    git push origin main

    # Log the commit and changed files
    if [ "$LOGGING_ENABLED" = true ]; then
        {
            echo "Commit on $CURRENT_DATE"
            echo "Changed files:"
            echo "$CHANGED_FILES"
            echo "--------------------------"
        } >>"$COMMITS_LOG"
    fi
else
    # Log if no changes at all
    if [ "$LOGGING_ENABLED" = true ]; then
        echo "No changes to commit on $(date +"%Y-%m-%d %H:%M:%S")" >>"$NOTHING_CHANGED_LOG"
    fi
fi
