#!/bin/bash
# build.sh
# Description: Build script for BCML macOS Launcher
# Author: BCML Launcher Team
# Date: 2025-03-12

# Exit on error
set -e

# Set root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"
ASSETS_DIR="${ROOT_DIR}/assets"
BUILD_DIR="${ROOT_DIR}/build"
APP_NAME="BCML.app"
DMG_NAME="BCML-launcher.dmg"

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create build directory
echo -e "${YELLOW}Creating build directory...${NC}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/"{MacOS,Resources}

# Copy app contents
echo -e "${YELLOW}Copying app contents...${NC}"
cp "${SRC_DIR}/Contents/Info.plist" "${BUILD_DIR}/${APP_NAME}/Contents/"
cp "${SRC_DIR}/Contents/PkgInfo" "${BUILD_DIR}/${APP_NAME}/Contents/"
cp "${SRC_DIR}/MacOS/BCMLLauncher" "${BUILD_DIR}/${APP_NAME}/Contents/MacOS/"
cp "${ASSETS_DIR}/AppIcon.icns" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/"
cp "${SRC_DIR}/config.json" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/"

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod -R 755 "${BUILD_DIR}/${APP_NAME}/Contents/MacOS/"
chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/Info.plist"
chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/PkgInfo"
chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/Resources/AppIcon.icns"

# Ad-hoc codesign (can be replaced with a developer certificate)
echo -e "${YELLOW}Code signing...${NC}"
codesign --force --deep --sign - "${BUILD_DIR}/${APP_NAME}"

# Create DMG file
echo -e "${YELLOW}Creating DMG file...${NC}"
cd "${BUILD_DIR}"
hdiutil create -volname "BCML" -srcfolder "${APP_NAME}" -ov -format UDZO "${DMG_NAME}"

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}DMG file created at:${NC} ${BUILD_DIR}/${DMG_NAME}"
