#!/usr/bin/env python3
"""
BCML macOS launcher wrapper script.
This script sets up the Python environment and launches BCML.
"""

import os
import sys
import site
import subprocess
from pathlib import Path
import json

def setup_environment():
    """Set up the Python environment for BCML to run properly"""
    # Get the directory where this script is located
    script_dir = Path(os.path.dirname(os.path.realpath(__file__)))
    app_dir = script_dir.parent.parent  # Contents folder
    
    # Set necessary environment variables
    os.environ['QTWEBENGINE_DISABLE_SANDBOX'] = '1'
    
    # Add the app's Python lib directory to sys.path
    lib_path = app_dir / 'Resources' / 'lib' / 'python3.9' / 'site-packages'
    if lib_path.exists():
        sys.path.insert(0, str(lib_path))
        # Also add it to site-packages
        site.addsitedir(str(lib_path))
    
    # Add the app's frameworks directory to PATH for any binary dependencies
    frameworks_path = app_dir / 'Frameworks'
    if frameworks_path.exists():
        os.environ['PATH'] = f"{frameworks_path}:{os.environ.get('PATH', '')}"

def log_error(error_msg, tb=None):
    """Write error to log file and show dialog"""
    # Create log directory
    log_path = Path.home() / 'Library' / 'Logs' / 'BCML'
    log_path.mkdir(parents=True, exist_ok=True)
    
    # Write to log file
    with open(log_path / 'error.log', 'a') as f:
        f.write(f"[run_bcml.py] Error: {error_msg}\n")
        if tb:
            f.write(tb)
    
    # Show error dialog
    subprocess.run(['osascript', '-e', 
                   f'display alert "BCML Error" message "An error occurred: {error_msg}" buttons {{"OK"}} default button 1'])

def main():
    """Main entry point for BCML launcher"""
    try:
        # Set up the environment
        setup_environment()
        
        # Import and run BCML
        from bcml.__main__ import main as bcml_main
        bcml_main()
        return 0
        
    except ImportError as e:
        log_error(f"Failed to import BCML: {str(e)}", tb=subprocess.getoutput("pip list"))
        return 1
    except Exception as e:
        import traceback
        log_error(str(e), tb=traceback.format_exc())
        return 1

if __name__ == '__main__':
    sys.exit(main())
