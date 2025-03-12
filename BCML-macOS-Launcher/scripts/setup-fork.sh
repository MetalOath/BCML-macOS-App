#!/bin/bash
# setup-fork.sh
# Description: Clone neebyA/BCML fork and prepare for contribution
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

# Ask for GitHub username
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
  echo -e "${RED}Error: GitHub username cannot be empty.${NC}"
  exit 1
fi

# Ask for local directory to clone to
read -p "Enter local directory path to clone the fork to (default: ~/BCML-fork): " CLONE_DIR
CLONE_DIR=${CLONE_DIR:-~/BCML-fork}

# Expand tilde to home directory
CLONE_DIR="${CLONE_DIR/#\~/$HOME}"

# Check if directory exists
if [ -d "$CLONE_DIR" ]; then
  read -p "Directory exists. Overwrite? (y/n): " OVERWRITE
  if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
    echo -e "${YELLOW}Aborted.${NC}"
    exit 0
  fi
  rm -rf "$CLONE_DIR"
fi

# Create directory
mkdir -p "$CLONE_DIR"

# Step 1: Fork the repository on GitHub
echo -e "${YELLOW}Step 1: Fork the repository${NC}"
echo -e "Please go to ${BLUE}https://github.com/neebyA/BCML${NC} and click 'Fork' in the top right corner."
echo -e "Make sure to fork the repository to your GitHub account: ${BLUE}$GITHUB_USERNAME${NC}"
echo -e "Once done, press Enter to continue..."
read -p ""

# Step 2: Clone your fork
echo -e "${YELLOW}Step 2: Cloning your fork...${NC}"
cd "$CLONE_DIR"
git clone "https://github.com/$GITHUB_USERNAME/BCML.git" .

# Step 3: Add the original repository as a remote
echo -e "${YELLOW}Step 3: Adding the original repository as a remote...${NC}"
git remote add upstream https://github.com/neebyA/BCML.git

# Step 4: Fetch the macos branch
echo -e "${YELLOW}Step 4: Fetching the macos branch...${NC}"
git fetch upstream macos:macos

# Step 5: Checkout the macos branch
echo -e "${YELLOW}Step 5: Checking out the macos branch...${NC}"
git checkout macos

# Step 6: Push the macos branch to your fork
echo -e "${YELLOW}Step 6: Pushing the macos branch to your fork...${NC}"
git push -u origin macos

echo -e "${GREEN}Setup complete!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Run the contribute-to-fork.sh script to integrate BCML macOS Launcher:"
echo -e "   ./scripts/contribute-to-fork.sh $CLONE_DIR"
echo
echo -e "2. Follow the instructions provided by contribute-to-fork.sh to push and create a pull request."
echo
echo -e "${GREEN}Your fork is now ready for contributions!${NC}"
