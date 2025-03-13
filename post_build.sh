#!/bin/bash

# Post-build script to copy necessary files to the app bundle

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the destination path
DEST_DIR="$SCRIPT_DIR/dist/BCML.app/Contents/Resources/lib/python3.9/bcml/helpers/"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy the 7z.so file
if [ -f "$SCRIPT_DIR/bcml/helpers/7z.so" ]; then
    echo "Copying 7z.so to the app bundle..."
    cp "$SCRIPT_DIR/bcml/helpers/7z.so" "$DEST_DIR"
fi

# Copy the 7zz file (macOS executable)
if [ -f "$SCRIPT_DIR/bcml/helpers/7zz" ]; then
    echo "Copying 7zz to the app bundle..."
    cp "$SCRIPT_DIR/bcml/helpers/7zz" "$DEST_DIR"
    chmod +x "$DEST_DIR/7zz"
fi

echo "Post-build script completed."
