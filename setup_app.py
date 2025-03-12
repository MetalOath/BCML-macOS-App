"""
This is a setup.py script generated to create a standalone macOS application
for BCML (BOTW Cross-Platform Mod Loader).
"""

from setuptools import setup

APP = ['app_launcher.py']
OPTIONS = {
    'argv_emulation': True,
    'packages': ['bcml', 'PyQt5', 'pyqtwebengine', 'webview'],
    'includes': ['sip', 'PyQt5.QtCore', 'PyQt5.QtGui', 'PyQt5.QtWebEngine', 'PyQt5.QtWebEngineWidgets'],
    'excludes': ['matplotlib', 'scipy', 'numpy', 'pandas'],
    'iconfile': 'bcml_icon.icns',
    'plist': {
        'CFBundleName': 'BCML',
        'CFBundleDisplayName': 'BCML',
        'CFBundleIdentifier': 'com.bcml.app',
        'CFBundleVersion': '3.10.8',
        'CFBundleShortVersionString': '3.10.8',
        'NSHumanReadableCopyright': 'BCML - BOTW Cross-Platform Mod Loader',
        'NSHighResolutionCapable': True,
        'NSRequiresAquaSystemAppearance': False,
        'LSEnvironment': {
            'QTWEBENGINE_DISABLE_SANDBOX': '1',
        },
    },
}

setup(
    name="BCML",
    app=APP,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
