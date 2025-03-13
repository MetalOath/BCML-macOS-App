# BCML macOS Launcher

<img src="BCML-macOS-Launcher/assets/AppIcon.icns" alt="BCML Logo" width="100"/>

A native macOS application launcher for BCML (BOTW Cross-Platform Mod Loader), providing a convenient way to run BCML on macOS systems, integrated directly into the BCML project.

## Overview

BCML macOS Launcher is a simple, lightweight wrapper application that allows users to launch BCML directly from their Applications folder or Dock, without needing to use Terminal commands. This project streamlines the user experience for macOS users by:

- Providing a native macOS application experience
- Setting required environment variables automatically
- Ensuring a smooth integration with macOS
- Offering a visually appealing icon in your Dock and Applications folder

This launcher targets users who have followed the [neebyA/BCML](https://github.com/neebyA/BCML/tree/macos) installation instructions and want a more convenient way to launch the application.

## Installation

### Method 1: Download and Install the Pre-built App

1. Download the latest DMG file from the [Releases](https://github.com/YourUsername/BCML-macOS-Launcher/releases) page
2. Mount the DMG file by double-clicking it
3. Drag the BCML app to your Applications folder
4. Unmount the DMG by dragging it to the Trash

### Method 2: Build from Source

See the "Building from Source" section below.

## Usage

1. Launch BCML from your Applications folder or Dock
2. If launching for the first time, you may need to right-click (or Control+click) the app and select "Open" to bypass macOS security restrictions
3. BCML will launch with the appropriate environment settings

### Troubleshooting

If you encounter issues:

- Ensure BCML is properly installed at `/Users/YourUsername/Desktop/BCML/`
- Check that the virtual environment is activated and BCML works when run from Terminal
- For permission errors, ensure the app has execution permissions

## Requirements

- macOS 10.15 Catalina or later
- Python 3.9 or later installed via Homebrew
- BCML installed and configured according to the [neebyA/BCML macOS instructions](https://github.com/neebyA/BCML/tree/macos)
- Installation location at `/Users/YourUsername/Desktop/BCML/` (modify `src/MacOS/BCMLLauncher` if installed elsewhere)

## Building from Source

### Prerequisites

- Xcode Command Line Tools (`xcode-select --install`)
- [Homebrew](https://brew.sh) (recommended for dependency management)

### Build Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/YourUsername/BCML-macOS-Launcher.git
   cd BCML-macOS-Launcher
   ```

2. Make the build script executable:
   ```bash
   chmod +x scripts/build.sh
   ```

3. Run the build script:
   ```bash
   ./scripts/build.sh
   ```

4. The built application will be available in the `build` directory, along with a DMG file ready for distribution

### Customizing the Launcher

If you've installed BCML in a location other than `/Users/YourUsername/Desktop/BCML/`, you'll need to update the path in `src/MacOS/BCMLLauncher`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [neebyA](https://github.com/neebyA) for the macOS fork of BCML
- [NiceneNerd](https://github.com/NiceneNerd) for the original BCML
- The BOTW modding community
