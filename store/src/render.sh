#!/bin/sh
# Renders an HTML source to a PNG of exact size with headless Chrome.
# Usage: store/src/render.sh <source.html> <out.png> <width> <height>
set -e
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
SRC=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --allow-file-access-from-files --default-background-color=00000000 \
  --virtual-time-budget=3000 --window-size="$3,$4" --screenshot="$2" "file://$SRC" >/dev/null 2>&1
