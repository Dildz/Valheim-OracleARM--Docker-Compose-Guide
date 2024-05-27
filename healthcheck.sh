#!/bin/bash
set -eo pipefail

save_interval=600

file_path=$(ls $SAVE_DIR/server_*.log | sort | tail -1)
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
            exit 1
        else
            exit 0
        fi
        break
    fi
    # Immediately fail if we see a fatal signal
    if [[ $line == *"Caught fatal signal"* ]]; then
        exit 1
    fi
done < <(tac "$file_path")
# We haven't seen a World saved line, must be stuck
exit 1