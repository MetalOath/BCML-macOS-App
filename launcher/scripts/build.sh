#!/bin/bash
# build.sh
# Description: Build script for integrated BCML macOS Application
# Author: BCML Launcher Team
# Date: 2025-03-13

# Exit on error
set -e

# Set root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "${ROOT_DIR}/.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"
ASSETS_DIR="${ROOT_DIR}/assets"
BUILD_DIR="${ROOT_DIR}/build"
APP_NAME="BCML.app"
DMG_NAME="BCML-macOS.dmg"

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Building Integrated BCML macOS Application ===${NC}"

# Verify BCML source is available
if [ ! -d "${PROJECT_ROOT}/bcml" ]; then
  echo -e "${RED}Error: BCML source code not found at ${PROJECT_ROOT}/bcml${NC}"
  echo -e "${RED}Please ensure you run this script from the root of the BCML-macOS-App repository${NC}"
  exit 1
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
  echo -e "${RED}Error: Python 3 is required but was not found${NC}"
  exit 1
fi

# Create build directory
echo -e "${YELLOW}Creating build directory...${NC}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/"{MacOS,Resources,Frameworks}

# Copy app contents
echo -e "${YELLOW}Copying app contents...${NC}"
cp "${SRC_DIR}/Contents/Info.plist" "${BUILD_DIR}/${APP_NAME}/Contents/"
cp "${SRC_DIR}/Contents/PkgInfo" "${BUILD_DIR}/${APP_NAME}/Contents/"
cp "${SRC_DIR}/MacOS/BCMLLauncher" "${BUILD_DIR}/${APP_NAME}/Contents/MacOS/"
cp "${ASSETS_DIR}/AppIcon.icns" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/"
cp "${SRC_DIR}/config.json" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/"

# Copy BCML core files to the app bundle
echo -e "${YELLOW}Copying BCML core files...${NC}"
mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml"

# Copy Python launcher script
echo -e "${YELLOW}Copying Python launcher script...${NC}"
cp "${PROJECT_ROOT}/app_launcher.py" "${BUILD_DIR}/${APP_NAME}/"

# Copy core BCML files
echo -e "${YELLOW}Copying BCML Python package...${NC}"
cp -R "${PROJECT_ROOT}/bcml/"* "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/"

# Copy required Python dependencies
echo -e "${YELLOW}Preparing Python dependencies...${NC}"
if [ -d "${PROJECT_ROOT}/venv" ]; then
  echo "Found virtual environment, will use its libraries"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib"
  cp -R "${PROJECT_ROOT}/venv/lib/python"*"/site-packages/"* "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/"
  echo "Copied Python libraries from venv"
else
  echo -e "${YELLOW}Warning: No virtual environment found at ${PROJECT_ROOT}/venv${NC}"
  echo -e "${YELLOW}The app will use system-installed Python packages${NC}"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib"
fi

# Copy any extra required files (wheel files, etc.)
if [ -f "${PROJECT_ROOT}/bcml-"*"-macosx"*".whl" ]; then
  echo -e "${YELLOW}Copying BCML wheel file...${NC}"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib"
  cp "${PROJECT_ROOT}/bcml-"*"-macosx"*".whl" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/"
fi

# Copy Rust extensions if they exist
if [ -f "${PROJECT_ROOT}/target/release/lib"*".dylib" ]; then
  echo -e "${YELLOW}Copying Rust extensions...${NC}"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Frameworks"
  cp "${PROJECT_ROOT}/target/release/lib"*".dylib" "${BUILD_DIR}/${APP_NAME}/Contents/Frameworks/"
fi

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod -R 755 "${BUILD_DIR}/${APP_NAME}/Contents/MacOS/"
chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/Info.plist"
chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/PkgInfo"
chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/Resources/AppIcon.icns"
chmod +x "${BUILD_DIR}/${APP_NAME}/app_launcher.py" 

# Update config to point to the bundled resources
echo -e "${YELLOW}Updating app configuration...${NC}"
cat > "${BUILD_DIR}/${APP_NAME}/Contents/Resources/config.json" << EOF
{
  "environment_variables": {
    "QTWEBENGINE_DISABLE_SANDBOX": "1"
  },
  "settings": {
    "use_bundled_resources": true,
    "bundled_python_lib_path": "Contents/Resources/lib",
    "bundled_bcml_path": "Contents/Resources/bcml"
  }
}
EOF

# Ad-hoc codesign (can be replaced with a developer certificate)
echo -e "${YELLOW}Code signing...${NC}"
codesign --force --deep --sign - "${BUILD_DIR}/${APP_NAME}"

# Create DMG file
echo -e "${YELLOW}Creating DMG file...${NC}"
cd "${BUILD_DIR}"
hdiutil create -volname "BCML" -srcfolder "${APP_NAME}" -ov -format UDZO "${DMG_NAME}"

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}DMG file created at:${NC} ${BUILD_DIR}/${DMG_NAME}"
echo -e "${YELLOW}Note: This is a standalone app that includes the BCML core.${NC}"
