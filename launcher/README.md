# BCML Integrated macOS Application

<img src="assets/AppIcon.icns" alt="BCML Logo" width="100"/>

The core component of the BCML macOS App, providing a fully integrated, standalone application experience for BCML (BOTW Cross-Platform Mod Loader) on macOS systems.

## Overview

The BCML macOS App is now a fully integrated application where this launcher component serves as the central framework, with BCML directly built into it. Instead of being a wrapper that finds and launches an external BCML installation, this application bundles everything needed to run BCML in a single, self-contained package.

### Key Features

- **Complete Integration**: The application bundles BCML core functionality directly, eliminating the need for separate installation steps
- **Simplified User Experience**: No Terminal commands or Python knowledge required
- **Self-Contained Package**: All dependencies and components are included in the app bundle
- **Native macOS Experience**: Proper application bundle with icon and system integration
- **Automatic Environment Setup**: Required environment variables and paths are configured automatically
- **Enhanced Error Handling**: Comprehensive logging and user-friendly error messages
- **Quick Updates**: Easily update by replacing the application

## Installation

### Method 1: Download and Install the Pre-built App

1. Download the latest DMG file from the [Releases](https://github.com/MetalOath/BCML-macOS-App/releases) page
2. Mount the DMG file by double-clicking it
3. Drag the BCML app to your Applications folder
4. Unmount the DMG by dragging it to the Trash

### Method 2: Build from Source

See the "Building from Source" section below.

## Usage

1. Launch BCML from your Applications folder or Dock
2. If launching for the first time, you may need to right-click (or Control+click) the app and select "Open" to bypass macOS security restrictions
3. BCML will launch with all components properly configured

### Troubleshooting

If you encounter issues:

- Check the logs in `~/Library/Logs/BCML/bcml.log` for detailed error information
- Ensure your system meets the minimum requirements (macOS 10.15 Catalina or later)
- For permission errors, ensure the app has execution permissions
- If experiencing graphical issues, try launching with the Terminal command: `open -a BCML --args --disable-gpu`

## Requirements

- macOS 10.15 Catalina or later
- No Python installation required (bundled with the app)
- No separate BCML installation needed

## Building from Source

### Prerequisites

- Xcode Command Line Tools (`xcode-select --install`)
- [Homebrew](https://brew.sh) (recommended for dependency management)
- Python 3.9 or later (for development only, not required for the final app)

### Build Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/MetalOath/BCML-macOS-App.git
   cd BCML-macOS-App
   ```

2. Make the build script executable:
   ```bash
   chmod +x launcher/scripts/build.sh
   ```

3. Run the build script:
   ```bash
   ./launcher/scripts/build.sh
   ```

4. The built application will be available in the `launcher/build` directory, along with a DMG file ready for distribution

## Application Structure

The application follows the standard macOS bundle structure with additional components to integrate BCML:

```
BCML.app/
├── app_launcher.py      # Central Python entry point
├── Contents/
│   ├── Frameworks/      # Rust extensions
│   ├── Info.plist       # App metadata
│   ├── MacOS/
│   │   └── BCMLLauncher # Main executable
│   ├── PkgInfo
│   └── Resources/
│       ├── AppIcon.icns # App icon
│       ├── bcml/        # BCML Python package
│       ├── config.json  # Configuration
│       └── lib/         # Python dependencies
```

For more details on the application structure, see [app-structure.md](../docs/app-structure.md).

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

- [NiceneNerd](https://github.com/NiceneNerd) for the original BCML
- [neebyA](https://github.com/neebyA) for the macOS fork of BCML
- [MetalOath](https://github.com/MetalOath) for the integrated macOS application
- The BOTW modding community
