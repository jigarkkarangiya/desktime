#!/bin/bash

# ===========================
# desktime installer - no sudo required
# ===========================

INSTALL_DIR="$HOME/bin"
INSTALL_PATH="$INSTALL_DIR/desktime"
REPO_RAW="https://raw.githubusercontent.com/jigarkkarangiya/desktime/main/desktime.sh"

echo "Installing desktime..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download and install
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$REPO_RAW" -o "$INSTALL_PATH"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$INSTALL_PATH" "$REPO_RAW"
else
    echo "Error: Neither curl nor wget is available. Please install one of them."
    exit 1
fi

# Make executable
chmod +x "$INSTALL_PATH"

# Add ~/bin to PATH if not already there
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$rc"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$rc"
        echo "Added ~/bin to PATH in $rc"
    fi
done

# Run with install flag to show completion message
"$INSTALL_PATH" --install
