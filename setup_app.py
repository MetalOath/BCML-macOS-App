#!/usr/bin/env python3
"""
Setup script to create a standalone macOS application for BCML.
This script uses py2app to bundle BCML and all its dependencies.
"""

import os
import sys
import shutil
import subprocess
from setuptools import setup
import py2app
from pathlib import Path

# Configuration
APP_NAME = "BCML"
VERSION = "3.10.8"
ICON_FILE = "bcml_icon.icns"
LAUNCHER_SCRIPT = "app_launcher.py"
RESOURCES_TO_COPY = [
    # Add resource files that need to be copied to the app bundle
    ("BCML-macOS-Launcher/src/Resources/run_bcml.py", "Resources/run_bcml.py"),
    ("BCML-macOS-Launcher/src/config.json", "Resources/config.json"),
]

# Clean up any existing build artifacts
print("Cleaning up previous builds...")
for dir_to_clean in ["build", "dist"]:
    if os.path.exists(dir_to_clean):
        shutil.rmtree(dir_to_clean)

# Ensure resources exist
for src, _ in RESOURCES_TO_COPY:
    if not os.path.exists(src):
        print(f"Error: Required resource {src} not found!")
        sys.exit(1)

# App configuration
APP = [LAUNCHER_SCRIPT]
DATA_FILES = []

# py2app options
OPTIONS = {
    'argv_emulation': False,  # True can cause issues with file paths
    'packages': [
        'bcml',
        'PyQt5',
        'pyqtwebengine',
        'webview',
        'oead',
        'json',
        'yaml',
        'wx',
        'zlib',
        'pymsyt',
        'configparser',
        'urllib',
        'requests'
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
        'IPython',
        'jupyter',
        'sphinx',
        'pygame',
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
                'CFBundleTypeIconFile': ICON_FILE,
                'CFBundleTypeRole': 'Viewer',
                'LSHandlerRank': 'Owner',
            },
        ],
    },
    'resources': [
        # Resources will be copied to the Resources directory in the bundle
        # This list is for files that py2app doesn't automatically include
        # Dynamically populated based on RESOURCES_TO_COPY
    ],
}

# Add resources to py2app options
for src, dest in RESOURCES_TO_COPY:
    # If the destination is a subdirectory of Resources
    if '/' in dest:
        subdir = os.path.dirname(dest)
        if subdir and not subdir.startswith('Resources'):
            subdir = f"Resources/{subdir}"
        os.makedirs(f"build/{subdir}", exist_ok=True)
        dest_path = f"build/{dest}"
        shutil.copy2(src, dest_path)
        OPTIONS['resources'].append(dest_path)
    else:
        OPTIONS['resources'].append(src)

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
    
    print("Build completed.")
    print("You can now find the app in the dist/ directory.")
