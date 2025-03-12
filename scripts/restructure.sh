#!/bin/bash
# restructure.sh
# Description: Script to restructure project, moving launcher files to main project
# Author: BCML macOS App Team
# Date: 2025-03-13

# Exit on error
set -e

# Set root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAUNCHER_DIR="${ROOT_DIR}/launcher"
ASSETS_DIR="${ROOT_DIR}/assets"
SRC_DIR="${ROOT_DIR}/src"

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Restructuring Project to Integrate BCML and Launcher ===${NC}"

# Create necessary directories
echo -e "${YELLOW}Creating necessary directories...${NC}"
mkdir -p "${SRC_DIR}/Contents/MacOS"
mkdir -p "${ASSETS_DIR}"

# Move assets
echo -e "${YELLOW}Moving app assets...${NC}"
if [ -d "${LAUNCHER_DIR}/assets" ]; then
  cp -R "${LAUNCHER_DIR}/assets/"* "${ASSETS_DIR}/"
fi

# Move source files
echo -e "${YELLOW}Moving source files...${NC}"
if [ -d "${LAUNCHER_DIR}/src/Contents" ]; then
  cp -R "${LAUNCHER_DIR}/src/Contents/"* "${SRC_DIR}/Contents/"
fi
if [ -f "${LAUNCHER_DIR}/src/MacOS/BCMLLauncher" ]; then
  cp "${LAUNCHER_DIR}/src/MacOS/BCMLLauncher" "${SRC_DIR}/Contents/MacOS/"
fi
if [ -f "${LAUNCHER_DIR}/src/config.json" ]; then
  cp "${LAUNCHER_DIR}/src/config.json" "${SRC_DIR}/"
fi

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
find "${SRC_DIR}/Contents/MacOS" -type f -exec chmod +x {} \;

# Update build script paths
echo -e "${YELLOW}Updating build script paths...${NC}"
if [ -f "${ROOT_DIR}/scripts/build.sh" ]; then
  sed -i "" "s|SRC_DIR=\"\${ROOT_DIR}/launcher/src\"|SRC_DIR=\"\${ROOT_DIR}/src\"|g" "${ROOT_DIR}/scripts/build.sh"
  sed -i "" "s|ASSETS_DIR=\"\${ROOT_DIR}/launcher/assets\"|ASSETS_DIR=\"\${ROOT_DIR}/assets\"|g" "${ROOT_DIR}/scripts/build.sh"
  echo -e "${GREEN}Updated build script paths${NC}"
fi

echo -e "${GREEN}Project restructuring complete!${NC}"
echo -e "${YELLOW}The launcher files have been integrated into the main project structure.${NC}"
echo -e "${YELLOW}The launcher directory can now be removed once you verify everything is working correctly.${NC}"
