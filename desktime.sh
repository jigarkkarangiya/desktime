#!/bin/bash

# Get first timestamp from today's auth.log
first_time=$(sudo grep "$(date '+%b %e')" /var/log/auth.log | head -n 1 | awk '{print $3}')
current_time=$(date +"%H:%M:%S")

# Convert both times to seconds since epoch
first_sec=$(date -d "$first_time" +%s)
current_sec=$(date -d "$current_time" +%s)

# Calculate difference in seconds
diff_sec=$(( current_sec - first_sec ))

# Convert seconds to hours and minutes
diff_hours=$(( diff_sec / 3600 ))
diff_minutes=$(( (diff_sec % 3600) / 60 ))

# Convert times to 12-hour format
first_time_12=$(date -d "$first_time" +"%I:%M:%S %p")
current_time_12=$(date -d "$current_time" +"%I:%M:%S %p")

echo "First log entry: $first_time_12"
echo "Current time:   $current_time_12"
echo "Elapsed:        ${diff_hours} hours ${diff_minutes} minutes"
