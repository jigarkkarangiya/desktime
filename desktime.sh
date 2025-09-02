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
# Color definitions
# ---------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Background colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

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

# Function to print a decorative border
print_border() {
    local char="$1"
    local length="$2"
    local color="$3"
    printf "${color}"
    for i in $(seq 1 $length); do
        printf "$char"
    done
    printf "${RESET}\n"
}

# Function to center text
center_text() {
    local text="$1"
    local width="$2"
    local color="$3"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "${color}"
    for i in $(seq 1 $padding); do printf " "; done
    printf "$text"
    for i in $(seq 1 $padding); do printf " "; done
    if [ $(( ${#text} % 2 )) -ne $(( width % 2 )) ]; then printf " "; fi
    printf "${RESET}\n"
}

# Function to format time with icon
format_time_line() {
    local icon="$1"
    local label="$2"
    local time="$3"
    local color="$4"
    printf "  ${CYAN}${icon}${RESET}  ${BOLD}${label}:${RESET} ${color}${time}${RESET}\n"
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

# Determine status color based on hours worked
if [ $diff_hours -lt 8 ]; then
    status_color="$YELLOW"
    status_icon="⏳"
    status_text="WORKING"
elif [ $diff_hours -lt 9 ]; then
    status_color="$BLUE"
    status_icon="⚡"
    status_text="ALMOST DONE"
else
    status_color="$GREEN"
    status_icon="✅"
    status_text="CAN LEAVE!"
fi

# Clear screen for better presentation
clear

# Display beautiful output
echo
print_border "═" 60 "$PURPLE"
center_text "🕐 DESK TIME TRACKER 🕐" 60 "$BOLD$WHITE$BG_PURPLE"
print_border "═" 60 "$PURPLE"
echo

# ASCII Art Clock
echo -e "${CYAN}        ⏰ Work Hours Dashboard ⏰${RESET}"
echo -e "${DIM}    ╭─────────────────────────────────╮${RESET}"
echo -e "${DIM}    │                                 │${RESET}"

format_time_line "🌅" "Started at  " "$first_time_12" "$GREEN"
format_time_line "🕐" "Current time" "$current_time_12" "$BLUE"
format_time_line "⏱️ " "Worked for  " "${diff_hours}h ${diff_minutes}m" "$YELLOW"
format_time_line "🚪" "Can leave at" "$leave_time" "$PURPLE"

echo -e "${DIM}    │                                 │${RESET}"
echo -e "${DIM}    ╰─────────────────────────────────╯${RESET}"
echo

# Status indicator
print_border "─" 60 "$CYAN"
center_text "${status_icon} STATUS: ${status_text} ${status_icon}" 60 "$BOLD$status_color"
print_border "─" 60 "$CYAN"

# Progress bar
echo
echo -e "  ${BOLD}Progress toward 9 hours:${RESET}"
progress=$(( (diff_sec * 40) / (9 * 3600) ))
if [ $progress -gt 40 ]; then progress=40; fi

printf "  ["
for i in $(seq 1 40); do
    if [ $i -le $progress ]; then
        if [ $diff_hours -ge 9 ]; then
            printf "${GREEN}█${RESET}"
        else
            printf "${YELLOW}█${RESET}"
        fi
    else
        printf "${DIM}░${RESET}"
    fi
done
printf "] "

# Percentage
percentage=$(( (diff_sec * 100) / (9 * 3600) ))
if [ $percentage -gt 100 ]; then percentage=100; fi
if [ $percentage -ge 100 ]; then
    echo -e "${GREEN}${BOLD}${percentage}%${RESET}"
else
    echo -e "${YELLOW}${percentage}%${RESET}"
fi

echo
print_border "═" 60 "$PURPLE"

# Motivational message
if [ $diff_hours -lt 4 ]; then
    echo -e "  ${YELLOW}☕ Good morning! Keep up the great work!${RESET}"
elif [ $diff_hours -lt 8 ]; then
    echo -e "  ${BLUE}💪 You're doing great! Keep going!${RESET}"
elif [ $diff_hours -lt 9 ]; then
    echo -e "  ${CYAN}🎯 Almost there! Just a bit more!${RESET}"
else
    echo -e "  ${GREEN}🎉 Excellent work! You've completed your 9 hours!${RESET}"
fi

print_border "═" 60 "$PURPLE"
echo

# Show helpful info if this is a fresh install
if [ "$1" = "--install" ]; then
    echo
    echo -e "${GREEN}✅ Installation complete!${RESET} You can now run ${BOLD}desktime${RESET} from anywhere."
    echo -e "If the command is not found, restart your terminal or run: ${CYAN}source ~/.bashrc${RESET}"
    echo
fi
