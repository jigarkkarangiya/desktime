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

# Add ~/bin to PATH in shell config if not already there
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$rc"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$rc"
        echo "Added ~/bin to PATH in $rc"
    fi
done

# GitHub raw URL of this script
REPO_RAW="https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh"

# ---------------------------
# Auto-update (no sudo required)
# ---------------------------
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW" -o "$INSTALL_PATH.tmp" 2>/dev/null
    if [ $? -eq 0 ]; then
        chmod +x "$INSTALL_PATH.tmp"
        
        # Replace only if different
        if [ ! -f "$INSTALL_PATH" ] || ! cmp -s "$INSTALL_PATH.tmp" "$INSTALL_PATH"; then
            mv "$INSTALL_PATH.tmp" "$INSTALL_PATH"
            echo "desktime has been updated to the latest version!"
        else
            rm -f "$INSTALL_PATH.tmp"
        fi
    else
        rm -f "$INSTALL_PATH.tmp" 2>/dev/null
    fi
fi

# ---------------------------
# Main functionality
# ---------------------------

# Function to get first login time with multiple fallback options
get_first_login_time() {
    local today_pattern=$(date '+%b %e')
    local first_time=""
    
    # Try different log sources in order of preference
    local log_sources=(
        "/var/log/auth.log"
        "/var/log/secure"
        "/var/log/messages"
        "/var/log/syslog"
    )
    
    for log_file in "${log_sources[@]}"; do
        if [ -r "$log_file" ]; then
            first_time=$(grep "$today_pattern" "$log_file" 2>/dev/null | head -n 1 | awk '{print $3}')
            if [ -n "$first_time" ]; then
                echo "$first_time"
                return 0
            fi
        fi
    done
    
    # Fallback: try with sudo if available (but don't require it)
    if command -v sudo >/dev/null 2>&1; then
        for log_file in "${log_sources[@]}"; do
            if [ -f "$log_file" ]; then
                first_time=$(sudo grep "$today_pattern" "$log_file" 2>/dev/null | head -n 1 | awk '{print $3}')
                if [ -n "$first_time" ]; then
                    echo "$first_time"
                    return 0
                fi
            fi
        done
    fi
    
    # Ultimate fallback: check who command or last command
    if command -v who >/dev/null 2>&1; then
        # Get the earliest login time for current user today
        first_time=$(who -b 2>/dev/null | awk '{print $4}' | head -1)
        if [ -n "$first_time" ]; then
            echo "$first_time"
            return 0
        fi
    fi
    
    if command -v last >/dev/null 2>&1; then
        # Get today's first login from last command
        first_time=$(last -s today 2>/dev/null | grep "$(whoami)" | tail -1 | awk '{print $4}')
        if [ -n "$first_time" ]; then
            echo "$first_time"
            return 0
        fi
    fi
    
    # If all else fails, use a reasonable default (8:00 AM)
    echo "08:00:00"
}

# Get first timestamp
first_time=$(get_first_login_time)
current_time=$(date +"%H:%M:%S")

# Validate first_time format
if ! date -d "$first_time" >/dev/null 2>&1; then
    echo "Warning: Could not determine first login time. Using 08:00:00 as default."
    first_time="08:00:00"
fi

# Convert to seconds since epoch (today)
today=$(date +"%Y-%m-%d")
first_sec=$(date -d "$today $first_time" +%s)
current_sec=$(date -d "$today $current_time" +%s)

# Handle case where current time is before first time (crossed midnight)
if [ $current_sec -lt $first_sec ]; then
    # Add 24 hours to current time
    current_sec=$(( current_sec + 86400 ))
fi

# Calculate elapsed time
diff_sec=$(( current_sec - first_sec ))
diff_hours=$(( diff_sec / 3600 ))
diff_minutes=$(( (diff_sec % 3600) / 60 ))

# Convert times to 12-hour format
first_time_12=$(date -d "$today $first_time" +"%I:%M:%S %p")
current_time_12=$(date +"%I:%M:%S %p")

# Calculate "leave office" time after 9 hours
leave_sec=$(( first_sec + 9*3600 ))
leave_time=$(date -d "@$leave_sec" +"%I:%M:%S %p")

# Display output
echo "=================================================="
echo "                   DESK TIME                     "
echo "=================================================="
echo "First login time: $first_time_12"
echo "Current time:     $current_time_12"
echo "Elapsed time:     ${diff_hours} hours ${diff_minutes} minutes"
echo "Leave office at:  $leave_time (after 9 hours)"
echo "=================================================="

# Show helpful info if this is a fresh install
if [ "$1" = "--install" ]; then
    echo ""
    echo "Installation complete! You can now run 'desktime' from anywhere."
    echo "If the command is not found, restart your terminal or run:"
    echo "  source ~/.bashrc"
fi
