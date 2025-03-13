#!/bin/bash
# contribute-to-fork.sh
# Description: Integrate BCML macOS Launcher into a fork of neebyA/BCML
# Author: BCML Launcher Team
# Date: 2025-03-12

# Exit on error
set -e

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check if BCML fork directory is provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: Please provide the path to your cloned BCML fork.${NC}"
  echo -e "Usage: $0 /path/to/your/bcml/fork"
  exit 1
fi

BCML_FORK_PATH="$1"

# Check if path exists and is a directory
if [ ! -d "$BCML_FORK_PATH" ]; then
  echo -e "${RED}Error: Directory '$BCML_FORK_PATH' does not exist.${NC}"
  exit 1
fi

# Check if it's a git repository
if [ ! -d "$BCML_FORK_PATH/.git" ]; then
  echo -e "${RED}Error: '$BCML_FORK_PATH' is not a git repository.${NC}"
  exit 1
fi

# Set root directory of our launcher project
LAUNCHER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Step 2: Create a new branch in the BCML fork
echo -e "${YELLOW}Creating a new branch in your BCML fork...${NC}"
cd "$BCML_FORK_PATH"

# Make sure we're on the macos branch first
git checkout macos || {
  echo -e "${RED}Error: 'macos' branch not found. Make sure you've cloned neebyA/BCML with the macos branch.${NC}"
  exit 1
}

# Create and checkout a new branch
BRANCH_NAME="feature/macos-app-launcher"
git checkout -b "$BRANCH_NAME"
echo -e "${GREEN}Created and switched to branch '$BRANCH_NAME'.${NC}"

# Step 3: Create macos-launcher directory in the BCML fork
echo -e "${YELLOW}Creating macos-launcher directory in your BCML fork...${NC}"
LAUNCHER_DEST="$BCML_FORK_PATH/macos-launcher"
mkdir -p "$LAUNCHER_DEST"

# Step 4: Copy all files from our launcher project to the BCML fork
echo -e "${YELLOW}Copying BCML macOS Launcher files to your BCML fork...${NC}"

# First remove the .git directory if it exists in the launcher project (to avoid nested git repositories)
if [ -d "$LAUNCHER_DIR/.git" ]; then
  rm -rf "$LAUNCHER_DIR/.git"
fi

# Copy all files
cp -r "$LAUNCHER_DIR/"* "$LAUNCHER_DEST/"

# Step 5: Add and commit changes
echo -e "${YELLOW}Adding and committing changes...${NC}"
git add "$LAUNCHER_DEST"
git commit -m "feat(macos): Add macOS application launcher

This commit adds a native macOS application launcher for BCML, providing a more
user-friendly way to launch BCML on macOS without using Terminal commands.

- Added complete application bundle structure
- Included build script for creating a distributable DMG
- Added documentation and license
- Implemented proper error handling and configuration"

echo -e "${GREEN}Changes committed successfully!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Push your changes to your fork:"
echo -e "   git push -u origin $BRANCH_NAME"
echo
echo -e "2. Create a pull request on GitHub:"
echo -e "   a. Go to your fork on GitHub"
echo -e "   b. Switch to the '$BRANCH_NAME' branch"
echo -e "   c. Click 'Contribute' and then 'Open pull request'"
echo -e "   d. Fill in the PR details and submit"
echo
echo -e "${GREEN}Your BCML macOS Launcher is now integrated into your BCML fork!${NC}"
