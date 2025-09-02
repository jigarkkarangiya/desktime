Perfect! We can make this fully “one-liner install & uninstall” friendly, and also prepare a **final updated README.md** reflecting everything.

---

## **1️⃣ One-liner Install**

Users can install `desktime` with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh | bash
```

* Installs in `~/bin/desktime`
* Auto-updates on every run
* No sudo required

---

## **2️⃣ One-liner Uninstall**

Create a script `desktime-uninstall.sh` in your repo:

```bash
#!/bin/bash

INSTALL_DIR="$HOME/bin"
INSTALL_PATH="$INSTALL_DIR/desktime"

# Remove the desktime binary
rm -f "$INSTALL_PATH" && echo "desktime removed from $INSTALL_PATH."

# Remove PATH line from shell rc
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$rc" ]; then
    sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' "$rc"
  fi
done

echo "Uninstallation complete. Restart your terminal."
```

Then the **one-liner uninstall** is:

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime-uninstall.sh | bash
```

---

## **3️⃣ Updated README.md**

````markdown
# desktime

`desktime` is a command-line tool for Ubuntu/Linux that calculates the elapsed time since the first log entry of the day in `/var/log/auth.log`.  
It shows the first log timestamp, current time, elapsed time, and the suggested leave time after 9 hours in **12-hour (AM/PM) format**.  

It **auto-updates** from GitHub every time it runs and requires **no sudo password**.

---

## Features

- Displays first authentication log entry of the day  
- Shows current system time in 12-hour format  
- Calculates elapsed time in hours and minutes  
- Shows when you can leave after completing 9 hours  
- Auto-updates from GitHub  
- Easy one-line install and uninstall  

---

## Installation (One-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh | bash
````

* Installs `desktime` in `~/bin`
* Adds auto-update support
* No sudo required

Make sure `~/bin` is in your `PATH`:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Uninstallation (One-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime-uninstall.sh | bash
```

* Removes `desktime` binary from `~/bin`
* Cleans up the PATH entry

---

## Usage

```bash
desktime
```

Example output:

```
First log entry: 09:15:42 AM
Current time:   05:20:30 PM
Elapsed:        8 hours 5 minutes
You can leave office at: 06:15:42 PM (after completing 9 hours)
```

---

## Requirements

* Ubuntu or Linux system
* Access to `/var/log/auth.log` (may require sudo to read logs)
* `bash` and `coreutils` (standard on most Linux systems)

---

## License

MIT License