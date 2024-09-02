#!/bin/bash

# healthcheck.sh

set -eo pipefail

save_interval=600  # Time interval (in seconds) expected between saves

# Specify the path to the log file
log_file="/home/ubuntu/docker/logs/valheim.log"

# Check if the log file exists
if [ ! -f "$log_file" ]; then
    echo "Log file not found: $log_file"
    exit 1
fi

current_time=$(date +%s)

# Look for the line containing "World saved" and read the file backwards
while IFS= read -r line; do
    if [[ $line == *"World saved"* ]]; then
        # Extract the timestamp from the beginning of the line
        timestamp=$(awk -F': ' '{print $1}' <<< "$line")
        # Convert the timestamp to seconds since epoch
        timestamp_seconds=$(date -d "$timestamp" +%s)
        # Calculate the time difference in seconds
        time_diff=$((current_time - timestamp_seconds))
        # Check if the time difference is more than the save interval
        if [[ $time_diff -gt $save_interval ]]; then
            exit 1  # Fail the health check if the interval is exceeded
        else
            exit 0  # Pass the health check if the server is saving regularly
        fi
        break
    fi
    # Immediately fail if we see a fatal signal
    if [[ $line == *"Caught fatal signal"* ]]; then
        exit 1
    fi
done < <(tac "$log_file")
# We haven't seen a "World saved" line, so assume the server is stuck
exit 1
