# desktime

desktime is a simple command-line tool for Ubuntu that calculates the elapsed time since the first log entry of the day in /var/log/auth.log. It displays the first log timestamp, current time, and the elapsed time in 12-hour (AM/PM) format.

## Features
- Displays the first authentication log entry of the day.
- Shows the current system time in 12-hour format.
- Calculates elapsed time in hours and minutes.
- Easy one-line installation on Ubuntu.

## Installation

### Option 1: Direct installation via curl
```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh | sudo tee /usr/local/bin/desktime > /dev/null && sudo chmod +x /usr/local/bin/desktime
```

### Option 2: Using the installer script
```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/install.sh | bash
```

## Usage
```bash
desktime
```

## Requirements
- Ubuntu or any Linux system.
- Access to /var/log/auth.log (may require sudo).
- bash and coreutils (standard on most Linux systems).

## License
MIT License.
