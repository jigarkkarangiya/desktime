# desktime

A command-line tool for Linux systems that calculates your work hours by tracking your first login of the day. Shows elapsed time and when you can leave after completing 9 hours in a clean, user-friendly format.

---

## Features

- 🕐 Displays your first login time of the day
- ⏰ Shows current time and elapsed work hours  
- 🚪 Calculates when you can leave after 9 hours
- 🔄 Auto-updates from GitHub
- 📦 Simple installation and removal
- 🛡️ Works without administrative privileges

---

## Installation

Install with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/install.sh | bash
```

Alternative installation method:

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh | bash
```

The tool installs to `~/bin/desktime` and automatically configures your PATH.

---

## Usage

After installation, run:

```bash
desktime
```

### Example Output

```
════════════════════════════════════════════════════════════
                   🕐 DESK TIME TRACKER 🕐                    
════════════════════════════════════════════════════════════

        ⏰ Work Hours Dashboard ⏰
    ╭─────────────────────────────────╮
    │                                 │
  🌅  Started at  : 09:15:42 AM
  🕐  Current time: 05:20:30 PM
  ⏱️   Worked for  : 8h 5m
  🚪  Can leave at: 06:15:42 PM
    │                                 │
    ╰─────────────────────────────────╯

────────────────────────────────────────────────────────────
                  ⚡ STATUS: ALMOST DONE ⚡                   
────────────────────────────────────────────────────────────

  Progress toward 9 hours:
  [████████████████████████████████████░░░░] 90%

════════════════════════════════════════════════════════════
  🎯 Almost there! Just a bit more!
════════════════════════════════════════════════════════════
```

---

## Uninstallation

Remove the tool completely:

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime-uninstall.sh | bash
```

This removes the binary and cleans up configuration files.

---

## How It Works

The tool intelligently determines your first login time using multiple methods:

1. **System logs** - Checks authentication logs across different distributions
2. **System commands** - Uses `who`, `last`, and other utilities as fallbacks
3. **Graceful defaults** - Provides reasonable estimates when data is unavailable

The tool handles different Linux distributions, log formats, and permission scenarios automatically.

---

## Requirements

- Linux system (Ubuntu, CentOS, Fedora, Debian, etc.)
- `bash` shell 
- `curl` or `wget` for installation
- Standard Unix utilities (`date`, `awk`, `grep`)

---

## Troubleshooting

### Command not found after installation

Restart your terminal or run:
```bash
source ~/.bashrc
```

### Incorrect times displayed

If times seem wrong, the tool may be using fallback data. This can happen when:
- System logs are not accessible
- You haven't logged in through the normal authentication system
- The system clock is incorrect

The tool will still provide useful estimates in these scenarios.

---

## License

MIT License