#!/bin/bash
# push-direct.sh
# Description: Push BCML macOS Launcher directly to GitHub
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
TEMP_DIR="/tmp/bcml-push-$(date +%s)"

echo -e "${YELLOW}Preparing to push BCML project with macOS Launcher to $REPO_URL...${NC}"

# Create a temporary directory for the new repository
mkdir -p "$TEMP_DIR"

# Copy all files from the BCML root directory
echo -e "${YELLOW}Copying files to temporary directory...${NC}"
cp -r "$BCML_DIR/"* "$TEMP_DIR/"
cp -r "$BCML_DIR/."* "$TEMP_DIR/" 2>/dev/null || true

# Initialize git repository
echo -e "${YELLOW}Initializing new git repository...${NC}"
cd "$TEMP_DIR"
git init

# Update README for the fork
echo -e "${YELLOW}Updating README for the repository...${NC}"
sed -i '' "s|https://github.com/YourUsername/BCML-macOS-Launcher|$REPO_URL|g" README.md || true

# Add files
echo -e "${YELLOW}Adding files to git...${NC}"
git add .

# Commit changes
echo -e "${YELLOW}Committing changes...${NC}"
git commit -m "feat: Initial commit of BCML macOS Launcher

A native macOS application launcher for BCML (BOTW Cross-Platform Mod Loader),
providing a convenient way to run BCML on macOS systems.

- Provides a native macOS application experience
- Sets required environment variables automatically
- Ensures smooth integration with macOS
- Includes build scripts and documentation"

# Set remote
echo -e "${YELLOW}Setting remote repository...${NC}"
git remote add origin "$REPO_URL"

# Push to GitHub
echo -e "${YELLOW}Pushing to GitHub. You may be prompted for credentials...${NC}"
git push -u origin main --force

echo -e "${GREEN}Push completed successfully!${NC}"
echo
echo -e "${BLUE}Your BCML macOS Launcher is now available at:${NC}"
echo -e "$REPO_URL"
echo
echo -e "${YELLOW}To build the application:${NC}"
echo -e "1. Clone your repository"
echo -e "2. Run the build script: ./scripts/build.sh"
echo
echo -e "${GREEN}The macOS launcher is now ready to be shared with the community!${NC}"
