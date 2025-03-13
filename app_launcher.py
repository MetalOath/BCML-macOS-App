#!/usr/bin/env python

"""
Central entry point for the BCML macOS application.
This script initializes the environment and launches the integrated BCML app.
"""

import os
import sys
import json
import logging
import subprocess
import importlib.util
from pathlib import Path
from typing import Optional, Dict, Any

class BCMLMacOSApp:
    """Main class managing the BCML macOS application lifecycle"""

    def __init__(self):
        self.app_root = Path(__file__).parent.absolute()
        self.is_bundle = self._check_if_bundle()
        self.log_path = Path.home() / 'Library' / 'Logs' / 'BCML'
        self.log_path.mkdir(parents=True, exist_ok=True)
        self.setup_logging()

        # Ensure required environment variables are set
        if 'QTWEBENGINE_DISABLE_SANDBOX' not in os.environ:
            os.environ['QTWEBENGINE_DISABLE_SANDBOX'] = '1'

        # Load configuration
        self.config = self.load_config()

        # Set application paths
        if (self.app_root / 'Contents' / 'Resources' / 'bcml').exists():
            self.bcml_path = self.app_root / 'Contents' / 'Resources' / 'bcml'
        else:
            self.bcml_path = self.app_root / 'bcml'

        # Add paths to Python path for imports
        if str(self.app_root) not in sys.path:
            sys.path.insert(0, str(self.app_root))
        
        # Add bcml path and parent directories to Python path
        if str(self.bcml_path.parent) not in sys.path:
            sys.path.insert(0, str(self.bcml_path.parent))

        # Print debug information
        logging.debug("App initialization:")
        logging.debug(f"  App root: {self.app_root}")
        logging.debug(f"  Is bundle: {self.is_bundle}")
        logging.debug(f"  BCML path: {self.bcml_path}")
        logging.debug(f"  Python path: {sys.path}")

    def _check_if_bundle(self) -> bool:
        """Check if running as part of a macOS app bundle"""
        # Look for typical macOS bundle structure
        return (self.app_root / 'Contents' / 'MacOS').exists() or \
               (self.app_root.parent / 'MacOS').exists() or \
               (self.app_root.parent.parent / 'MacOS').exists()

    def setup_logging(self):
        """Set up logging for the application"""
        log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        logging.basicConfig(
            level=logging.DEBUG,
            format=log_format,
            handlers=[
                logging.FileHandler(self.log_path / 'bcml.log'),
                logging.StreamHandler()
            ]
        )

    def load_config(self) -> Dict[str, Any]:
        """Load configuration from JSON files"""
        config_paths = [
            self.app_root / 'launcher' / 'src' / 'config.json',  # Dev location
            self.app_root / 'Contents' / 'Resources' / 'config.json'  # Bundle location
        ]

        config = {
            "environment_variables": {},
            "settings": {}
        }

        for path in config_paths:
            if path.exists():
                try:
                    with open(path, 'r') as f:
                        loaded_config = json.load(f)

                    # Apply environment variables
                    if 'environment_variables' in loaded_config:
                        for key, value in loaded_config['environment_variables'].items():
                            os.environ[key] = value
                            config['environment_variables'][key] = value

                    # Apply settings
                    if 'settings' in loaded_config:
                        config['settings'].update(loaded_config['settings'])

                    logging.debug(f"Loaded configuration from {path}")
                    break
                except Exception as e:
                    logging.error(f"Error loading config from {path}: {e}")

        return config

    def check_bcml_installed(self) -> bool:
        """Check if BCML is properly installed"""
        return (self.bcml_path / '__init__.py').exists()

    def run(self) -> int:
        """Run the BCML application"""
        try:
            if not self.check_bcml_installed():
                logging.error(f"BCML not installed at {self.bcml_path}")
                logging.debug(f"Directory contents: {list(self.bcml_path.parent.glob('*'))}")
                self.show_error("BCML is not properly installed in the application bundle.")
                return 1

            # Try to load bundled Python libraries if available
            lib_path = None
            
            # Check config for bundled lib path
            if "settings" in self.config and "bundled_python_lib_path" in self.config["settings"]:
                relative_lib_path = self.config["settings"]["bundled_python_lib_path"]
                possible_lib_path = self.app_root / relative_lib_path
                if possible_lib_path.exists():
                    lib_path = possible_lib_path
                    logging.debug(f"Using bundled Python libraries from {lib_path}")
                    if str(lib_path) not in sys.path:
                        sys.path.insert(0, str(lib_path))
            
            # Debug message about paths
            logging.debug(f"Final sys.path: {sys.path}")
            
            # Attempt to import BCML
            try:
                logging.debug("Importing bcml module...")
                import bcml
                logging.debug(f"bcml module found at {bcml.__file__}")
                
                logging.debug("Importing bcml.__main__...")
                import bcml.__main__
                
                logging.info("Starting BCML...")
                bcml.__main__.main()
                
                return 0
            except ImportError as e:
                logging.exception("Error importing BCML")
                self.show_error(f"Error importing BCML: {str(e)}\n\nCheck that bcml is properly installed.")
                return 1

        except Exception as e:
            logging.exception("Error running BCML")
            self.show_error(f"An error occurred: {str(e)}")
            return 1

    def show_error(self, message: str):
        """Display error message using macOS alert dialog"""
        logging.error(message)
        try:
            subprocess.run([
                'osascript',
                '-e',
                f'display alert "BCML Error" message "{message}" buttons {{"OK"}} default button 1'
            ])
        except Exception as e:
            logging.error(f"Failed to show error dialog: {e}")

def main():
    """Main entry point for the BCML application"""
    app = BCMLMacOSApp()
    return app.run()

if __name__ == '__main__':
    sys.exit(main())
