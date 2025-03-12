#!/bin/bash
# push-to-existing-fork.sh
# Description: Push BCML macOS Launcher to an existing GitHub fork
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

# Set variables
REPO_URL="https://github.com/MetalOath/BCML-macOS-App.git"
LAUNCHER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BCML_DIR="$(cd "$LAUNCHER_DIR/.." && pwd)"
TEMP_CLONE_DIR="/tmp/bcml-macos-app-$(date +%s)"

echo -e "${YELLOW}Preparing to push BCML project with macOS Launcher to $REPO_URL...${NC}"

# Step 1: Clone the fork
echo -e "${YELLOW}Step 1: Cloning the fork...${NC}"
mkdir -p "$TEMP_CLONE_DIR"
git clone "$REPO_URL" "$TEMP_CLONE_DIR"
cd "$TEMP_CLONE_DIR"

# Step 2: Check if the repository is empty or has a main branch
if git show-ref --verify --quiet refs/heads/main; then
  echo -e "${YELLOW}Using existing main branch...${NC}"
  git checkout main
else
  echo -e "${YELLOW}Creating main branch...${NC}"
  git checkout --orphan main
  git rm -rf . || true  # Remove any existing files (if any)
fi

# Step 3: Copy all files from our BCML root directory to the cloned repository
echo -e "${YELLOW}Copying BCML project files with macOS Launcher...${NC}"

# Remove git-related files from our source to avoid conflicts
find "$BCML_DIR" -name ".git*" -not -path "*node_modules*" | xargs rm -rf 2>/dev/null || true

# Copy all files
cp -r "$BCML_DIR/"* "$TEMP_CLONE_DIR/"
cp -r "$BCML_DIR/".[!.]* "$TEMP_CLONE_DIR/" 2>/dev/null || true  # Copy hidden files

# Step 4: Update README for the fork
echo -e "${YELLOW}Updating README for the fork...${NC}"
sed -i '' "s|https://github.com/YourUsername/BCML-macOS-App|$REPO_URL|g" README.md || true

# Step 5: Add all files
echo -e "${YELLOW}Adding files to Git repository...${NC}"
git add .

# Step 6: Commit changes
echo -e "${YELLOW}Committing changes...${NC}"
git commit -m "feat: Initial commit of BCML macOS Launcher

A native macOS application launcher for BCML (BOTW Cross-Platform Mod Loader),
providing a convenient way to run BCML on macOS systems.

- Provides a native macOS application experience
- Sets required environment variables automatically
- Ensures smooth integration with macOS
- Includes build scripts and documentation" || echo -e "${YELLOW}No changes to commit${NC}"

# Step 7: Push to GitHub
echo -e "${YELLOW}Pushing to GitHub...${NC}"
git push -u origin main

echo -e "${GREEN}Push completed successfully!${NC}"
echo
echo -e "${BLUE}Your BCML macOS Launcher is now available at:${NC}"
echo -e "$REPO_URL"
echo
echo -e "${YELLOW}To build the application:${NC}"
echo -e "1. Clone your repository locally:"
echo -e "   git clone $REPO_URL"
echo -e "2. Run the build script:"
echo -e "   cd BCML-macOS-App"
echo -e "   ./scripts/build.sh"
echo
echo -e "${GREEN}The macOS launcher is now ready to be shared with the community!${NC}"
