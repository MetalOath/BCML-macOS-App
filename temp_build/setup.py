#!/usr/bin/env python3
"""
Standalone setup script to create a macOS application for BCML.
This version avoids conflicts with the main pyproject.toml.
"""

import os
import sys
import shutil
from setuptools import setup
import py2app
from pathlib import Path

# Configuration
APP_NAME = "BCML"
VERSION = "3.10.8"
ICON_FILE = "../bcml_icon.icns"  # Using the icon from parent directory
LAUNCHER_SCRIPT = "app_launcher.py"

# Clean up any existing build artifacts
print("Cleaning up previous builds...")
for dir_to_clean in ["build", "dist"]:
    if os.path.exists(dir_to_clean):
        shutil.rmtree(dir_to_clean)

# Copy resources
os.makedirs("Resources", exist_ok=True)
shutil.copy2("../BCML-macOS-Launcher/src/Resources/run_bcml.py", "Resources/run_bcml.py")
shutil.copy2("../BCML-macOS-Launcher/src/config.json", "Resources/config.json")
shutil.copy2("../app_launcher.py", "app_launcher.py")

# App configuration
APP = [LAUNCHER_SCRIPT]
DATA_FILES = [
    ('Resources', ['Resources/run_bcml.py', 'Resources/config.json']),
]

# py2app options
OPTIONS = {
    'argv_emulation': False,
    'packages': [
        'bcml',
        'PyQt5',
        'PyQtWebEngine',  # Correct case for actual package name
        'webview',
        'oead',
        'json',
        'yaml',
        'requests',
    ],
    'includes': [
        'sip',
        'PyQt5.QtCore',
        'PyQt5.QtGui',
        'PyQt5.QtWebEngine',
        'PyQt5.QtWebEngineWidgets',
        'PyQt5.QtWidgets',
        'webview.platforms.cocoa',
    ],
    'frameworks': [],
    'excludes': [
        'matplotlib',
        'scipy',
        'numpy',
        'pandas',
        'tkinter',
        'PySide2',
    ],
    'iconfile': ICON_FILE,
    'plist': {
        'CFBundleName': APP_NAME,
        'CFBundleDisplayName': APP_NAME,
        'CFBundleIdentifier': 'com.bcml.app',
        'CFBundleVersion': VERSION,
        'CFBundleShortVersionString': VERSION,
        'NSHumanReadableCopyright': 'BCML - BOTW Cross-Platform Mod Loader',
        'NSHighResolutionCapable': True,
        'NSRequiresAquaSystemAppearance': False,
        'LSEnvironment': {
            'QTWEBENGINE_DISABLE_SANDBOX': '1',
            'PYTHONPATH': '@executable_path/../Resources/lib/python3.9/site-packages',
        },
        'CFBundleDocumentTypes': [
            {
                'CFBundleTypeName': 'BNP Mod File',
                'CFBundleTypeExtensions': ['bnp'],
                'CFBundleTypeIconFile': os.path.basename(ICON_FILE),
                'CFBundleTypeRole': 'Viewer',
                'LSHandlerRank': 'Owner',
            },
        ],
    },
}

if __name__ == '__main__':
    print(f"Building {APP_NAME} version {VERSION}...")
    setup(
        name=APP_NAME,
        version=VERSION,
        app=APP,
        data_files=DATA_FILES,
        options={'py2app': OPTIONS},
        setup_requires=['py2app'],
    )
    
    print("Build completed in temp_build directory.")
    print("Copying to main build directory...")
    
    # Copy the built app to the main directory
    parent_dist = Path("../dist")
    os.makedirs(parent_dist, exist_ok=True)
    
    if os.path.exists("dist/BCML.app"):
        if os.path.exists(f"{parent_dist}/BCML.app"):
            shutil.rmtree(f"{parent_dist}/BCML.app")
        shutil.copytree("dist/BCML.app", f"{parent_dist}/BCML.app")
        print(f"App successfully copied to {parent_dist}/BCML.app")
