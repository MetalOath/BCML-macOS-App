#!/usr/bin/env python
"""
Launcher script for the BCML macOS application.
This script sets necessary environment variables and launches the BCML app.
"""

import os
import sys
import subprocess
from pathlib import Path

# Set necessary environment variables
os.environ['QTWEBENGINE_DISABLE_SANDBOX'] = '1'

def main():
    """Main entry point for the BCML application"""
    try:
        # Import and run BCML
        import bcml.__main__
        bcml.__main__.main()
    except Exception as e:
        # Write error to a log file in case of crash
        log_path = Path.home() / 'Library' / 'Logs' / 'BCML'
        log_path.mkdir(parents=True, exist_ok=True)
        
        with open(log_path / 'error.log', 'a') as f:
            f.write(f"[{os.path.basename(__file__)}] Error: {str(e)}\n")
            import traceback
            f.write(traceback.format_exc())
        
        # Show error message
        subprocess.run(['osascript', '-e', f'display alert "BCML Error" message "An error occurred: {str(e)}" buttons {{"OK"}} default button 1'])
        
        return 1
    return 0

if __name__ == '__main__':
    sys.exit(main())
