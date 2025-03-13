#!/usr/bin/env python3
"""
Launcher script for the BCML macOS application.
This script is the main entry point for the py2app-built BCML application.
It delegates to run_bcml.py which is responsible for setting up the environment.
"""

import os
import sys
import subprocess
import site
from pathlib import Path

def setup_bundled_environment():
    """Configure the environment for the bundled application"""
    # Get the directory where this script is located (inside the app bundle)
    if getattr(sys, 'frozen', False):
        # Running as a bundled app
        bundle_dir = Path(os.path.dirname(sys.executable)).parent
        resources_dir = bundle_dir / "Resources"
        
        # Set QTWEBENGINE_DISABLE_SANDBOX for Qt
        os.environ['QTWEBENGINE_DISABLE_SANDBOX'] = '1'
        
        # Check if we have a run_bcml.py script in the resources directory
        run_bcml_path = resources_dir / "run_bcml.py"
        if run_bcml_path.exists():
            # Execute the script
            return subprocess.call([sys.executable, str(run_bcml_path)])
        else:
            show_error(f"Could not find run_bcml.py at {run_bcml_path}")
            return 1
    else:
        # Running in development mode
        try:
            # Add the current directory to the Python path
            sys.path.insert(0, os.getcwd())
            
            # Set required environment variables
            os.environ['QTWEBENGINE_DISABLE_SANDBOX'] = '1'
            
            # Import and run BCML directly
            import bcml.__main__
            return bcml.__main__.main()
        except Exception as e:
            # Show error message and write to log
            log_error(str(e))
            return 1

def log_error(error_msg):
    """Write error to log file and show dialog"""
    # Create log directory
    log_path = Path.home() / 'Library' / 'Logs' / 'BCML'
    log_path.mkdir(parents=True, exist_ok=True)
    
    # Write to log file
    with open(log_path / 'error.log', 'a') as f:
        f.write(f"[app_launcher.py] Error: {error_msg}\n")
        import traceback
        f.write(traceback.format_exc())
    
    # Show error dialog
    show_error(error_msg)

def show_error(message):
    """Display an error dialog to the user"""
    subprocess.run(['osascript', '-e', 
                   f'display alert "BCML Error" message "An error occurred: {message}" buttons {{"OK"}} default button 1'])

def main():
    """Main entry point"""
    try:
        return setup_bundled_environment()
    except Exception as e:
        import traceback
        log_error(f"Unhandled exception: {str(e)}")
        print(traceback.format_exc())
        return 1

if __name__ == '__main__':
    sys.exit(main())
