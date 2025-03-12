#!/bin/bash
# git-update.sh
# Description: Script to commit and push the restructured project
# Author: BCML macOS App Team
# Date: 2025-03-13

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Committing and Pushing Project Changes ===${NC}"

# Get list of all changes
echo -e "${YELLOW}Getting list of all changes...${NC}"
CHANGES=$(git status --porcelain)
echo "Found changes:"
echo "$CHANGES"

# Stage all changes
echo -e "${YELLOW}Staging all changes...${NC}"
git add .

# Commit the changes
echo -e "${YELLOW}Committing changes...${NC}"
git commit -m "refactor: restructure project to integrate BCML and launcher

- Make launcher the central component
- Build BCML directly into the launcher
- Reorganize project structure
- Update documentation and build scripts
- Create unified configuration files"

# Push to GitHub
echo -e "${YELLOW}Pushing to GitHub...${NC}"
echo -e "${GREEN}Using VS Code's credentials for authentication${NC}"

# If VS Code extension is available, use it
if command -v code &> /dev/null && code --list-extensions | grep -q "github.vscode-pull-request-github"; then
  echo "Using VS Code GitHub extension for push"
  git push origin main
else
  # Otherwise use standard git push
  git push origin main
fi

echo -e "${GREEN}Changes committed successfully!${NC}"
echo -e "${YELLOW}If push failed due to authentication, please push manually through VS Code's Source Control interface.${NC}"
