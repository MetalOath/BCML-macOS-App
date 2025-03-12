#!/bin/bash
# build.sh
# Description: Consolidated, optimized build script for BCML macOS Application
# Focuses on memory efficiency and build performance
# Author: BCML Launcher Team (Optimized version)
# Date: 2025-03-13

# Exit on error
set -e

# Set root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${ROOT_DIR}/src"
ASSETS_DIR="${ROOT_DIR}/assets"
BUILD_DIR="${ROOT_DIR}/build"
LAUNCHER_DIR="${ROOT_DIR}/launcher"
APP_NAME="BCML.app"
DMG_NAME="BCML-macOS.dmg"
TMP_DIR="${BUILD_DIR}/tmp"

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Build mode flags
BUILD_MAIN=true
BUILD_LAUNCHER=false
LAUNCHER_ONLY=false
INCREMENTAL_BUILD=false

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --launcher)
      BUILD_LAUNCHER=true
      ;;
    --launcher-only)
      BUILD_LAUNCHER=true
      BUILD_MAIN=false
      LAUNCHER_ONLY=true
      ;;
    --incremental)
      INCREMENTAL_BUILD=true
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --launcher      Build the launcher app as well"
      echo "  --launcher-only Build only the launcher app"
      echo "  --incremental   Use incremental build mode (skip unchanged components)"
      echo "  --help          Show this help message"
      exit 0
      ;;
  esac
done

echo -e "${YELLOW}=== Building Optimized BCML macOS Application ===${NC}"

# Verify BCML source is available if building main app
if [ "$BUILD_MAIN" = true ] && [ ! -d "${ROOT_DIR}/bcml" ]; then
  echo -e "${RED}Error: BCML source code not found at ${ROOT_DIR}/bcml${NC}"
  echo -e "${RED}Please ensure you run this script from the root of the BCML-macOS-App repository${NC}"
  exit 1
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
  echo -e "${RED}Error: Python 3 is required but was not found${NC}"
  exit 1
fi

# Create a cleanup function to remove temporary files
cleanup() {
  echo -e "${YELLOW}Cleaning up temporary files...${NC}"
  if [ -d "${TMP_DIR}" ]; then
    rm -rf "${TMP_DIR}"
  fi
}

# Register the cleanup function to run on exit
trap cleanup EXIT

# Create build and temporary directories
echo -e "${YELLOW}Creating build directory...${NC}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${TMP_DIR}"

# ----- MEMORY OPTIMIZATION FUNCTIONS -----

# Function to optimize Rust compilation
optimize_rust_build() {
  echo -e "${YELLOW}Optimizing Rust compilation settings...${NC}"
  
  # Create a temporary .cargo/config.toml file to override default settings
  mkdir -p "${ROOT_DIR}/.cargo"
  cat > "${ROOT_DIR}/.cargo/config.toml" << EOF
[build]
# Use thin LTO instead of fat LTO to reduce memory usage
rustflags = ["-C", "lto=thin", "-C", "codegen-units=4"]

[profile.release]
# Override Cargo.toml settings with more memory-efficient options
lto = "thin"
codegen-units = 4
EOF
  
  # Set memory limits for Rust compilation
  export RUSTFLAGS="-C lto=thin -C codegen-units=4"
  # Limit parallel jobs based on available memory
  MEM_GB=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
  if [ $MEM_GB -lt 8 ]; then
    export CARGO_BUILD_JOBS=2
  elif [ $MEM_GB -lt 16 ]; then
    export CARGO_BUILD_JOBS=4
  fi
}

# Function to optimize webpack build
optimize_webpack_build() {
  local webpack_dir="$1"
  echo -e "${YELLOW}Optimizing webpack build for ${webpack_dir}...${NC}"
  
  # Create an optimized webpack config
  cat > "${webpack_dir}/webpack.production.js" << EOF
const path = require("path");
const TerserPlugin = require("terser-webpack-plugin");

module.exports = {
  mode: "production",
  output: {
    path: path.resolve(__dirname, "scripts"),
    publicPath: "/scripts/",
    filename: "bundle.js"
  },
  optimization: {
    minimize: true,
    minimizer: [new TerserPlugin({
      parallel: 2, // Reduce parallel processing to save memory
      terserOptions: {
        compress: {
          ecma: 5,
          warnings: false,
          comparisons: false
        },
        output: {
          ecma: 5,
          comments: false
        }
      }
    })],
    removeEmptyChunks: true,
    mergeDuplicateChunks: true,
    splitChunks: {
      chunks: 'all'
    }
  },
  performance: {
    hints: false
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            compact: true,
            presets: [
              ["@babel/preset-env", { modules: "commonjs" }],
              "@babel/preset-react"
            ],
            plugins: [
              "@babel/plugin-proposal-class-properties",
              "@babel/plugin-proposal-object-rest-spread",
              "@babel/plugin-syntax-dynamic-import",
              "@babel/plugin-transform-runtime",
              "@babel/plugin-proposal-optional-chaining"
            ]
          }
        }
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          "style-loader",
          "css-loader",
          "sass-loader"
        ]
      }
    ]
  }
};
EOF

  # Add terser plugin for better minification with memory constraints
  if [ -f "${webpack_dir}/package.json" ]; then
    cd "${webpack_dir}"
    npm install --no-save terser-webpack-plugin
  fi
  
  # Set memory limit for Node.js processes
  export NODE_OPTIONS="--max-old-space-size=2048" # Limit Node.js memory usage to 2GB
}

# Function to optimize Python package copying
optimize_python_deps() {
  local venv_path="$1"
  local target_path="$2"
  echo -e "${YELLOW}Optimizing Python dependency copying...${NC}"
  
  # Create a list of required packages only - this reduces the copied content significantly
  REQUIRED_PACKAGES=(
    "oead"
    "packaging"
    "PyQt5"
    "pyqtwebengine"
    "pywebview"
    "QtPy"
    "requests"
    "rstb"
    "xxhash"
    "botw_utils"
    "pythonnet"
  )
  
  # Create a script to copy only required packages
  cat > "${TMP_DIR}/copy_deps.py" << EOF
import os
import sys
import shutil
import site
from pathlib import Path

# Get paths
venv_path = sys.argv[1]
target_path = sys.argv[2]
packages = sys.argv[3].split(',')

# Ensure target directory exists
target = Path(target_path)
target.mkdir(parents=True, exist_ok=True)

# Find site-packages in venv
if os.path.exists(venv_path):
    # For different Python versions
    site_paths = list(Path(venv_path).glob('lib/python*/site-packages'))
    if not site_paths:
        print("No site-packages found in venv")
        sys.exit(1)
    site_path = site_paths[0]
else:
    # Use system site-packages as fallback
    site_path = Path(site.getsitepackages()[0])

print(f"Using site-packages from: {site_path}")

# Copy only required packages (exclude tests and __pycache__)
for package in packages:
    # Try direct package (e.g., package name as directory)
    pkg_path = site_path / package
    if pkg_path.exists() and pkg_path.is_dir():
        target_pkg_path = target / package
        print(f"Copying package directory: {package}")
        shutil.copytree(pkg_path, target_pkg_path, 
                        ignore=shutil.ignore_patterns('__pycache__', 'tests', '*.pyc'))
        continue
    
    # Try package as .py file
    pkg_file = site_path / f"{package}.py"
    if pkg_file.exists():
        print(f"Copying package file: {package}.py")
        shutil.copy2(pkg_file, target)
        continue
        
    # Try dist-info or egg-info
    for info_dir in site_path.glob(f"{package}*.*-info"):
        target_info = target / info_dir.name
        print(f"Copying package metadata: {info_dir.name}")
        shutil.copytree(info_dir, target_info,
                        ignore=shutil.ignore_patterns('__pycache__'))
    
    # Try more complex cases like PyQt5 which has a directory structure
    for pkg_file in site_path.glob(f"{package}*.whl") + site_path.glob(f"{package}*.pth"):
        print(f"Copying wheel/pth: {pkg_file.name}")
        shutil.copy2(pkg_file, target)
    
    # Try package as a namespace with hyphen (e.g., "botw-utils" -> "botw_utils")
    alt_name = package.replace("-", "_")
    alt_path = site_path / alt_name
    if alt_path.exists() and alt_path.is_dir():
        target_alt_path = target / alt_name
        print(f"Copying package with alternate name: {alt_name}")
        shutil.copytree(alt_path, target_alt_path,
                        ignore=shutil.ignore_patterns('__pycache__', 'tests', '*.pyc'))
EOF

  # Create lib directory
  mkdir -p "${target_path}"
  
  # Run the optimized dependency copy script
  echo -e "${YELLOW}Copying only required Python dependencies...${NC}"
  python3 "${TMP_DIR}/copy_deps.py" \
    "${venv_path}" \
    "${target_path}" \
    "$(IFS=, ; echo "${REQUIRED_PACKAGES[*]}")"
}

# Function to check for incremental build
check_incremental_build() {
  local build_dir="$1"
  local app_path="$2"
  
  if [ "$INCREMENTAL_BUILD" = true ] && [ -d "${build_dir}/${app_path}" ] && [ -f "${build_dir}/last_build" ]; then
    LAST_BUILD=$(cat "${build_dir}/last_build")
    CURRENT_TIME=$(date +%s)
    
    # Check if it's been less than 1 hour since last build
    if (( CURRENT_TIME - LAST_BUILD < 3600 )); then
      echo -e "${YELLOW}Recent build detected (less than 1 hour ago)${NC}"
      echo -e "${YELLOW}Using incremental build mode...${NC}"
      return 0 # true
    fi
  fi
  
  return 1 # false
}

# Function to build the main BCML app
build_main_app() {
  echo -e "${YELLOW}=== Building Main BCML App ===${NC}"
  
  # Check for incremental build
  if check_incremental_build "${BUILD_DIR}" "${APP_NAME}"; then
    local IS_INCREMENTAL=true
  else
    local IS_INCREMENTAL=false
  fi
  
  # Create app directory structure
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/"{MacOS,Resources,Frameworks}
  
  # Copy app contents
  echo -e "${YELLOW}Copying app contents...${NC}"
  cp "${SRC_DIR}/Contents/Info.plist" "${BUILD_DIR}/${APP_NAME}/Contents/"
  cp "${SRC_DIR}/Contents/PkgInfo" "${BUILD_DIR}/${APP_NAME}/Contents/"
  cp -p "${SRC_DIR}/Contents/MacOS/BCMLLauncher" "${BUILD_DIR}/${APP_NAME}/Contents/MacOS/"
  cp "${ASSETS_DIR}/AppIcon.icns" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/"
  cp "${SRC_DIR}/config.json" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/"
  
  # Copy Python launcher script
  echo -e "${YELLOW}Copying Python launcher script...${NC}"
  cp "${ROOT_DIR}/app_launcher.py" "${BUILD_DIR}/${APP_NAME}/"
  
  # Build BCML React frontend with optimized webpack config if needed
  if [ ! -d "${ROOT_DIR}/bcml/assets" ]; then
    echo -e "${YELLOW}Warning: BCML assets directory not found. Skipping frontend build.${NC}"
  elif [ "$IS_INCREMENTAL" = false ] || [ ! -f "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/assets/scripts/bundle.js" ]; then
    echo -e "${YELLOW}Building BCML frontend...${NC}"
    optimize_webpack_build "${ROOT_DIR}/bcml/assets"
    
    cd "${ROOT_DIR}/bcml/assets"
    NODE_OPTIONS="--max-old-space-size=2048" npx webpack --config webpack.production.js
  fi
  
  # Optimize copying of BCML Python package
  echo -e "${YELLOW}Copying BCML Python package...${NC}"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml"
  
  # Use rsync for more efficient copying with exclusions
  rsync -a --delete \
    --exclude="__pycache__" \
    --exclude="*.pyc" \
    --exclude=".git" \
    --exclude="node_modules" \
    "${ROOT_DIR}/bcml/" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/"
  
  # Handle Python dependencies with memory optimizations
  if [ "$IS_INCREMENTAL" = false ] || [ ! -d "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib" ]; then
    if [ -d "${ROOT_DIR}/venv" ]; then
      optimize_python_deps "${ROOT_DIR}/venv" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib"
    else
      echo -e "${YELLOW}Warning: No virtual environment found at ${ROOT_DIR}/venv${NC}"
      echo -e "${YELLOW}The app will use system-installed Python packages${NC}"
      mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib"
    fi
  fi
  
  # Copy wheel file if it exists
  if [ "$IS_INCREMENTAL" = false ] || [ ! -f "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/bcml-"*"-macosx"*".whl" ]; then
    if [ -f "${ROOT_DIR}/bcml-"*"-macosx"*".whl" ]; then
      echo -e "${YELLOW}Copying BCML wheel file...${NC}"
      mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib"
      cp "${ROOT_DIR}/bcml-"*"-macosx"*".whl" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/"
    fi
  fi
  
  # Copy Rust extensions with incremental support
  if [ "$IS_INCREMENTAL" = false ] || [ ! -f "${BUILD_DIR}/${APP_NAME}/Contents/Frameworks/lib"*".dylib" ]; then
    if [ -f "${ROOT_DIR}/target/release/lib"*".dylib" ]; then
      echo -e "${YELLOW}Copying Rust extensions...${NC}"
      mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Frameworks"
      cp "${ROOT_DIR}/target/release/lib"*".dylib" "${BUILD_DIR}/${APP_NAME}/Contents/Frameworks/"
    fi
  fi
  
  # Copy 7z native helpers (from post_build.sh)
  echo -e "${YELLOW}Copying 7z helpers...${NC}"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/helpers"
  mkdir -p "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/python3.9/bcml/helpers/"
  
  if [ -f "${ROOT_DIR}/bcml/helpers/7z.so" ]; then
    cp "${ROOT_DIR}/bcml/helpers/7z.so" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/helpers/"
    cp "${ROOT_DIR}/bcml/helpers/7z.so" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/python3.9/bcml/helpers/"
  fi
  
  if [ -f "${ROOT_DIR}/bcml/helpers/7zz" ]; then
    cp "${ROOT_DIR}/bcml/helpers/7zz" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/helpers/"
    cp "${ROOT_DIR}/bcml/helpers/7zz" "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/python3.9/bcml/helpers/"
    chmod +x "${BUILD_DIR}/${APP_NAME}/Contents/Resources/bcml/helpers/7zz"
    chmod +x "${BUILD_DIR}/${APP_NAME}/Contents/Resources/lib/python3.9/bcml/helpers/7zz"
  fi
  
  # Set permissions
  echo -e "${YELLOW}Setting permissions...${NC}"
  chmod -R 755 "${BUILD_DIR}/${APP_NAME}/Contents/MacOS/"
  chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/Info.plist"
  chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/PkgInfo"
  chmod 644 "${BUILD_DIR}/${APP_NAME}/Contents/Resources/AppIcon.icns"
  chmod +x "${BUILD_DIR}/${APP_NAME}/app_launcher.py"
  
  # Update config to point to the bundled resources (with proper JSON syntax)
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
  
  # Create DMG file conditionally
  if [ "$IS_INCREMENTAL" = false ] || [ ! -f "${BUILD_DIR}/${DMG_NAME}" ]; then
    echo -e "${YELLOW}Creating DMG file...${NC}"
    cd "${BUILD_DIR}"
    hdiutil create -volname "BCML" -srcfolder "${APP_NAME}" -ov -format UDZO "${DMG_NAME}"
  else
    echo -e "${YELLOW}Skipping DMG creation (using existing file)...${NC}"
  fi
  
  echo -e "${GREEN}Main BCML app build completed successfully!${NC}"
  echo -e "${GREEN}DMG file created at:${NC} ${BUILD_DIR}/${DMG_NAME}"
}

# Function to build the launcher app
build_launcher_app() {
  echo -e "${YELLOW}=== Building BCML Launcher App ===${NC}"
  
  # Set launcher specific directories
  LAUNCHER_SRC_DIR="${LAUNCHER_DIR}/src"
  LAUNCHER_ASSETS_DIR="${LAUNCHER_DIR}/assets"
  LAUNCHER_BUILD_DIR="${LAUNCHER_DIR}/build"
  LAUNCHER_APP_NAME="BCMLLauncher.app"
  LAUNCHER_DMG_NAME="BCMLLauncher-macOS.dmg"
  
  # Check for incremental build
  if check_incremental_build "${LAUNCHER_BUILD_DIR}" "${LAUNCHER_APP_NAME}"; then
    local IS_INCREMENTAL=true
  else
    local IS_INCREMENTAL=false
  fi
  
  # Create launcher build directory
  mkdir -p "${LAUNCHER_BUILD_DIR}"
  mkdir -p "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/"{MacOS,Resources,Frameworks}
  
  # Copy launcher app contents
  echo -e "${YELLOW}Copying launcher app contents...${NC}"
  cp "${LAUNCHER_SRC_DIR}/Contents/Info.plist" "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/"
  cp "${LAUNCHER_SRC_DIR}/Contents/PkgInfo" "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/"
  cp -p "${LAUNCHER_SRC_DIR}/MacOS/BCMLLauncher" "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/MacOS/"
  cp "${LAUNCHER_ASSETS_DIR}/AppIcon.icns" "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/Resources/"
  cp "${LAUNCHER_SRC_DIR}/config.json" "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/Resources/"
  
  # Set permissions
  echo -e "${YELLOW}Setting launcher permissions...${NC}"
  chmod -R 755 "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/MacOS/"
  chmod 644 "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/Info.plist"
  chmod 644 "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/PkgInfo"
  chmod 644 "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}/Contents/Resources/AppIcon.icns"
  
  # Ad-hoc codesign
  echo -e "${YELLOW}Code signing launcher...${NC}"
  codesign --force --deep --sign - "${LAUNCHER_BUILD_DIR}/${LAUNCHER_APP_NAME}"
  
  # Create launcher DMG file conditionally
  if [ "$IS_INCREMENTAL" = false ] || [ ! -f "${LAUNCHER_BUILD_DIR}/${LAUNCHER_DMG_NAME}" ]; then
    echo -e "${YELLOW}Creating launcher DMG file...${NC}"
    cd "${LAUNCHER_BUILD_DIR}"
    hdiutil create -volname "BCMLLauncher" -srcfolder "${LAUNCHER_APP_NAME}" -ov -format UDZO "${LAUNCHER_DMG_NAME}"
  else
    echo -e "${YELLOW}Skipping launcher DMG creation (using existing file)...${NC}"
  fi
  
  echo -e "${GREEN}BCML Launcher app build completed successfully!${NC}"
  echo -e "${GREEN}Launcher DMG file created at:${NC} ${LAUNCHER_BUILD_DIR}/${LAUNCHER_DMG_NAME}"
}

# ----- MAIN BUILD PROCESS -----

# 1. First, optimize the compilation and build settings
optimize_rust_build

# 2. Build the main app if requested
if [ "$BUILD_MAIN" = true ]; then
  build_main_app
fi

# 3. Build the launcher app if requested
if [ "$BUILD_LAUNCHER" = true ]; then
  build_launcher_app
fi

# Record build time for incremental builds
if [ "$BUILD_MAIN" = true ]; then
  date +%s > "${BUILD_DIR}/last_build"
fi

if [ "$BUILD_LAUNCHER" = true ]; then
  date +%s > "${LAUNCHER_DIR}/build/last_build"
fi

# Print final message
echo -e "${GREEN}Build process completed successfully!${NC}"
if [ "$BUILD_MAIN" = true ] && [ "$BUILD_LAUNCHER" = true ]; then
  echo -e "${YELLOW}Both the main BCML app and launcher app have been built.${NC}"
elif [ "$BUILD_MAIN" = true ]; then
  echo -e "${YELLOW}The main BCML app has been built.${NC}"
else
  echo -e "${YELLOW}The BCML launcher app has been built.${NC}"
fi
echo -e "${YELLOW}Use --help flag for more build options.${NC}"
