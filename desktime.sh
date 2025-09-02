#!/bin/bash

# ===========================
# desktime - user-friendly auto-updating version
# ===========================

# Set install path in user-owned folder
INSTALL_DIR="$HOME/bin"
INSTALL_PATH="$INSTALL_DIR/desktime"
mkdir -p "$INSTALL_DIR"

# Ensure ~/bin is in PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *) export PATH="$INSTALL_DIR:$PATH" ;;
esac

# GitHub raw URL of this script
REPO_RAW="https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh"

# ---------------------------
# Auto-update (no sudo required)
# ---------------------------
curl -fsSL "$REPO_RAW" -o "$INSTALL_PATH.tmp"
chmod +x "$INSTALL_PATH.tmp"

# Replace only if different
if [ ! -f "$INSTALL_PATH" ] || ! cmp -s "$INSTALL_PATH.tmp" "$INSTALL_PATH"; then
    mv "$INSTALL_PATH.tmp" "$INSTALL_PATH"
    echo "desktime has been updated to the latest version!"
else
    rm -f "$INSTALL_PATH.tmp"
fi

# ---------------------------
# Main functionality
# ---------------------------

# Get first timestamp from today's auth.log
first_time=$(grep "$(date '+%b %e')" /var/log/auth.log | head -n 1 | awk '{print $3}')
current_time=$(date +"%H:%M:%S")

# Convert to seconds since epoch
first_sec=$(date -d "$first_time" +%s)
current_sec=$(date -d "$current_time" +%s)

# Calculate elapsed time
diff_sec=$(( current_sec - first_sec ))
diff_hours=$(( diff_sec / 3600 ))
diff_minutes=$(( (diff_sec % 3600) / 60 ))

# Convert times to 12-hour format
first_time_12=$(date -d "$first_time" +"%I:%M:%S %p")
current_time_12=$(date -d "$current_time" +"%I:%M:%S %p")

# Calculate "leave office" time after 9 hours
leave_sec=$(( first_sec + 9*3600 ))
leave_time=$(date -d "@$leave_sec" +"%I:%M:%S %p")

# Display output
echo "First log entry: $first_time_12"
echo "Current time:   $current_time_12"
echo "Elapsed:        ${diff_hours} hours ${diff_minutes} minutes"
echo "You can leave office at: $leave_time (after completing 9 hours)"
