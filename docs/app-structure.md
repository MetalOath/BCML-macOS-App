# BCML macOS Launcher - Application Structure

This document provides an overview of the BCML macOS Launcher application structure and explains how the different components work together.

## macOS Application Bundle Structure

The BCML macOS Launcher follows the standard macOS application bundle structure:

```
BCML.app/
├── Contents/
│   ├── Info.plist        # Application metadata and configuration
│   ├── MacOS/
│   │   └── BCMLLauncher  # Main executable script
│   ├── PkgInfo           # Legacy application type and creator code
│   └── Resources/
│       └── AppIcon.icns  # Application icon
│       └── config.json   # Configuration for the launcher
```

### Key Components

#### Info.plist

The `Info.plist` file contains essential metadata about the application, including:
- Bundle identifier
- Application name and version
- Icon file reference
- Required macOS version
- Other application configuration settings

#### BCMLLauncher (Executable)

The main executable is a bash script that:
1. Loads configuration from `config.json`
2. Sets required environment variables
3. Checks for the existence of BCML installation
4. Activates the BCML virtual environment
5. Executes BCML with proper settings
6. Shows error dialogs if any issues are encountered

#### Resources

Contains assets used by the application, primarily the application icon (`AppIcon.icns`) and the configuration file (`config.json`).

## Project Structure for Development

The development project is now integrated into the BCML project:

```
BCML/
├── [BCML project files]
├── BCML-macOS-Launcher/
│   ├── .cline-rules.json     # Cline rules for code quality
│   ├── .gitignore            # Git ignore patterns
│   ├── CONTRIBUTING.md       # Contribution guidelines
│   ├── LICENSE               # MIT License
│   ├── assets/
│   │   └── AppIcon.icns      # Application icon source
│   ├── scripts/
│   │   ├── build.sh          # Build script for creating the app bundle
│   │   └── init-repo.sh      # Script to initialize Git repository
│   └── src/
│       ├── Contents/
│       │   ├── Info.plist    # Application metadata
│       │   └── PkgInfo       # Type and creator code
│       ├── MacOS/
│       │   └── BCMLLauncher  # Main executable script
│       └── config.json       # Configuration for the launcher
└── venv/
    └── bin/
        ├── activate          # Virtual environment activation script
        └── bcml              # BCML executable
```

### Building the Application

The `build.sh` script creates a proper macOS application bundle by:
1. Creating the necessary directory structure
2. Copying files to their correct locations
3. Setting appropriate permissions
4. Codesigning the application
5. Creating a DMG file for distribution

## Configuration

The application uses `config.json` for configuration, which includes:
- Path to the BCML executable
- Path to the virtual environment activation script
- Environment variables to be set before launching BCML

This configuration can be modified to support different installation locations or additional environment variables.

## Customization

To customize the launcher for different BCML installation paths:
1. Edit `src/config.json` to change the paths
2. Rebuild the application using `scripts/build.sh`

## Implementation Details

### Error Handling

The launcher implements error handling for common issues:
- BCML not found at the expected location
- Virtual environment activation script not found
- Proper error dialogs using AppleScript

### Environment Variables

The launcher sets necessary environment variables for BCML to work properly on macOS, including:
- `QTWEBENGINE_DISABLE_SANDBOX=1` - Required for Qt WebEngine to function correctly
