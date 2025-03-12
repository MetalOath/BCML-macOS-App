# BCML Integrated macOS Application - Project Structure

This document provides an overview of the BCML Integrated macOS Application's structure, where the launcher serves as the central component with BCML directly built into it.

## Overview of the Integrated Architecture

The BCML macOS App is a fully integrated application where the launcher and BCML core are packaged together as a single unit. This approach eliminates the need for separate installations and simplifies the user experience. The launcher is now the central part of the project, with BCML built directly into it.

## Unified Project Structure

The project structure has been completely reorganized to reflect the integrated approach:

```
BCML-macOS-App/
├── .cline-rules.json      # Code style and quality rules for entire project
├── .gitignore             # Unified Git ignore patterns
├── CONTRIBUTING.md        # Contributing guidelines for the integrated project
├── LICENSE                # GNU GPL v3 license for BCML core
├── LICENSE.macOS.md       # MIT license for macOS components
├── README.md              # Main project documentation
├── app_launcher.py        # Central Python entry point
├── bcml/                  # BCML Python package
├── bcml-*.whl             # BCML wheel file (optional)
├── assets/                # Application assets
│   └── AppIcon.icns       # Application icon
├── docs/                  # Documentation
│   ├── app-structure.md   # This document
│   └── [other docs]       # BCML and application documentation
├── scripts/               # Build and utility scripts
│   ├── build.sh           # Main build script
│   └── restructure.sh     # Project reorganization script
├── src/                   # Application source files
│   ├── Contents/          # macOS bundle structure
│   │   ├── Info.plist     # Application metadata
│   │   ├── MacOS/         # Executable files
│   │   │   └── BCMLLauncher # Main shell script
│   │   └── PkgInfo        # Bundle type info
│   └── config.json        # Application configuration
└── target/                # Compiled Rust extensions
```

## macOS Application Bundle Structure

The built application follows the standard macOS bundle structure with integrated BCML:

```
BCML.app/
├── app_launcher.py      # Python entry point script
├── Contents/
│   ├── Frameworks/      # Contains dylib files from Rust extensions
│   ├── Info.plist       # Application metadata and configuration
│   ├── MacOS/
│   │   └── BCMLLauncher # Main executable shell script
│   ├── PkgInfo          # Legacy application type and creator code
│   └── Resources/
│       ├── AppIcon.icns # Application icon
│       ├── bcml/        # BCML Python package files
│       │   └── [BCML package files]
│       ├── config.json  # Configuration for the launcher
│       └── lib/         # Python dependencies
│           └── [Python packages and dependencies]
```

## Key Components

### Central Python Launcher (app_launcher.py)

The central Python script that:
1. Initializes the application environment
2. Sets up logging and configuration
3. Adds application paths to Python path
4. Imports and executes the BCML main function
5. Provides robust error handling and logging

### Shell Script Entry Point (BCMLLauncher)

The main executable shell script that:
1. Sets environment variables needed for macOS
2. Finds the appropriate Python interpreter
3. Launches the Python app_launcher.py script
4. Shows error dialogs if issues are encountered

### BCML Core (bcml/)

The complete BCML Python package is included directly within the app bundle, allowing the application to function without external dependencies.

### Build System (scripts/build.sh)

The unified build script:
1. Creates the necessary directory structure
2. Copies all components into place
3. Bundles the BCML Python package
4. Includes Python dependencies from the virtual environment
5. Includes Rust extensions if available
6. Sets appropriate permissions
7. Updates the configuration
8. Codesigns the application
9. Creates a DMG file for distribution

## Configuration System

The application uses `config.json` for configuration, including:
- Environment variables to be set before launching
- Settings for the integrated application
- Paths to bundled resources

### Default Configuration

```json
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
```

## Benefits of the Unified Project Structure

This integrated approach provides several advantages:
- Clear organization with the launcher as the central component
- All components built and packaged in a single operation
- Simplified development workflow
- Consistent environment for BCML to run in
- Easier maintenance and updates
- Better user experience with a native macOS application

## Implementation Details

### Building from Source

To build the application from source:

1. Clone the repository
2. Install dependencies
3. Run the build script:
   ```bash
   ./scripts/build.sh
   ```

### Environment Setup

The application handles:
- Setting necessary environment variables
- Configuring Python import paths
- Loading BCML modules directly from bundled resources

### Error Handling and Logging

Enhanced error handling includes:
- Comprehensive logging to user's Library/Logs/BCML directory
- User-friendly error dialogs using AppleScript
- Detailed error information for debugging

### Development Workflow

The integrated structure facilitates a streamlined development workflow:
1. Make changes to either BCML core or macOS launcher components
2. Run the build script to create a test build
3. Test the application
4. Package for distribution
