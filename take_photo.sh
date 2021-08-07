#!/bin/bash
set -eo pipefail
# set -x

# Required for bash scripts run from Automator
export PATH=/usr/local/bin:$PATH

# Make a temp directory
PHOTO_TMPDIR=$(mktemp -d)
cd $PHOTO_TMPDIR

# Open the temp directory in a new Finder window
open $PHOTO_TMPDIR

sleep 0.5
# Reposition and resize the new Finder window to fixed coordinates
read -r -d '' ASCRIPT_RESIZE_FINDER_WINDOW <<'EOF' || true
tell application "System Events" to tell process "Finder"
    set position of window 1 to {0, 0}
    set size of window 1 to {800, 600}
    activate
end tell
EOF

osascript -e "$ASCRIPT_RESIZE_FINDER_WINDOW"
sleep 0.1

# Manually open the "Take Photo" menu using simulated mouse and keyboard event
cliclick 'rc:550,300' 'kp:page-down' 'kp:arrow-right' 'kp:enter'

# Wait for first image to appear in the temp directory
PHOTO_FILENAME="$(timeout 60 fswatch "$PHOTO_TMPDIR" --one-event || echo '')"
if [ -z "$PHOTO_FILENAME" ]; then
  echo "Timed out while waiting for photo!" >&2
  exit 1
fi
echo "Captured photo: $PHOTO_FILENAME"

read -r -d '' ASCRIPT_COPY_TO_CB <<EOF || true
tell application "Finder"
    activate
    close Finder window 1
end tell

set the clipboard to (read (POSIX file "$PHOTO_FILENAME") as JPEG picture)
EOF
osascript -e "$ASCRIPT_COPY_TO_CB"

echo "Copied $PHOTO_FILENAME to clipboard"
