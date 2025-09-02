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
