# BCML macOS Launcher

![BCML Logo](../../launcher/assets/AppIcon.icns)

A native macOS application launcher for BCML (BOTW Cross-Platform Mod Loader), providing a convenient way to run BCML on macOS systems, integrated directly into the BCML project.

## Overview

BCML macOS Launcher is a simple, lightweight wrapper application that allows users to launch BCML directly from their Applications folder or Dock, without needing to use Terminal commands. This project streamlines the user experience for macOS users by:

- Providing a native macOS application experience
- Setting required environment variables automatically
- Ensuring a smooth integration with macOS
- Offering a visually appealing icon in your Dock and Applications folder

This launcher targets users who have followed the BCML macOS installation instructions and want a more convenient way to launch the application.

## Installation

### Method 1: Download and Install the Pre-built App

1. Download the latest DMG file from the [Releases](https://github.com/MetalOath/BCML-macOS-App/releases) page
2. Mount the DMG file by double-clicking it
3. Drag the BCML app to your Applications folder
4. Unmount the DMG by dragging it to the Trash

### Method 2: Build from Source

See the [Building from Source](app-structure.md#building-the-application) section for more details.

## Usage

1. Launch BCML from your Applications folder or Dock
2. If launching for the first time, you may need to right-click (or Control+click) the app and select "Open" to bypass macOS security restrictions
3. BCML will launch with the appropriate environment settings

### Troubleshooting

If you encounter issues:

- Ensure BCML is properly installed with all dependencies
- Check that the virtual environment is activated and BCML works when run from Terminal
- For permission errors, ensure the app has execution permissions

## Requirements

- macOS 10.15 Catalina or later
- Python 3.9 or later installed via Homebrew
- BCML installed and configured according to the macOS installation instructions

## Building from Source

For detailed information on the application structure and build process, see the [Application Structure](app-structure.md) documentation.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

For contribution guidelines, see the [main CONTRIBUTING.md](../../CONTRIBUTING.md) file.

## License

This project is licensed under the MIT License - see the [LICENSE](../../launcher/LICENSE) file for details.

## Acknowledgments

- [neebyA](https://github.com/neebyA) for the macOS fork of BCML
- [NiceneNerd](https://github.com/NiceneNerd) for the original BCML
- [MetalOath](https://github.com/MetalOath) for the macOS Launcher integration
- The BOTW modding community
