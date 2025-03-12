#!/bin/bash
# init-repo.sh
# Description: Initialize Git repository for BCML macOS Launcher
# Author: BCML Launcher Team
# Date: 2025-03-12

# Exit on error
set -e

# Set root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Initializing Git repository for BCML macOS Launcher...${NC}"

# Initialize Git repository
if [ -d .git ]; then
  echo -e "${YELLOW}Git repository already initialized.${NC}"
else
  echo -e "${YELLOW}Creating Git repository...${NC}"
  git init
fi

# Add all files
echo -e "${YELLOW}Adding files to Git repository...${NC}"
git add .

# Create initial commit
echo -e "${YELLOW}Creating initial commit...${NC}"
git commit -m "feat: Initial commit of BCML macOS Launcher"

echo -e "${GREEN}Git repository initialized successfully!${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Create a new repository on GitHub (https://github.com/new)"
echo -e "2. Run the following commands to push to GitHub:"
echo
echo -e "   git remote add origin https://github.com/YourUsername/BCML-macOS-App.git"
echo -e "   git branch -M main"
echo -e "   git push -u origin main"
echo
echo -e "3. Alternatively, to create a fork of the original BCML repository:"
echo -e "   a. Fork https://github.com/neebyA/BCML on GitHub"
echo -e "   b. Clone your fork locally"
echo -e "   c. Add your launcher as a directory in your fork"
echo -e "   d. Commit and push your changes to your fork"
echo
echo -e "${GREEN}Happy coding!${NC}"
