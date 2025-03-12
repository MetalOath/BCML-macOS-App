![BCML Logo](https://i.imgur.com/OiqKPx0.png)

# BCML: Integrated macOS Application for BOTW Mod Loader

A standalone macOS application for _The Legend of Zelda: Breath of the Wild_ mod management, with BCML (BOTW Cross-Platform Mod Loader) fully integrated.

![BCML Banner](https://i.imgur.com/vmZanVl.png)

## Purpose

Why a mod loader for BOTW? Installing a mod is usually easy enough once you have a
homebrewed console or an emulator. Is there a need for a special tool?

Yes. As soon as you start trying to install multiple mods, you will find complications.
The BOTW game ROM is fundamentally structured for performance and storage use on a
family console, without any support for modification. As such, files like the
[resource size table](https://zeldamods.org/wiki/Resource_system) or
[TitleBG.pack](https://zeldamods.org/wiki/TitleBG.pack) will almost inevitably begin to
clash once you have more than a mod or two. Symptoms can include mods simply taking no
effect, odd bugs, actors that don't load, hanging on the load screen, or complete
crashing. BCML exists to resolve this problem. It identifies, isolates, and merges the
changes made by each mod into a single modpack that just works.

## Prerequisites

-   Windows 10+ (7-8 _might_ work but are not officially supported) or basically any modern Linux
    distribution or macOS 10.15 Catalina or later
-   A legal, unpacked game dump of _The Legend of Zelda: Breath of the Wild_ for Switch
    (version 1.6.0) or Wii U (version 1.5.0)
-   [The latest x64 Visual C++ redistributable](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads#section-2) (Windows only)
-   Python 3.7 - 3.10 (64-bit version)
-   Cemu (optional)

## Setup

There are several ways to install BCML depending on your platform.

### Windows and Linux via PyPI

Install Python 3.7 - 3.10 (**64 bit version**), making sure to add it to your PATH, and then
run `pip install bcml`.

**Note for Linux users**: Because of the ways different distros handle Python packaging,
it often works better to install BCML in some contained environment. There are a few options for
this. The easiest would be to use [`pipx`](https://github.com/pypa/pipx). You can install `pipx`
through pip, and then run `pipx install bcml`. In some cases you might need to also run `pipx
inject bcml pywebview[qt]`.

**Note for Linux white screen bug**: Try setting the environmental variable: `QTWEBENGINE_DISABLE_SANDBOX=1`.

Another option for Linux users is using a virtual environment ("venv"). To do so, you can run
something like this:

```sh
python -m venv bcml_env
source bcml_env/bin/activate # will activate the venv
pip install bcml
```

**Full Linux Example with CEMU**

`sudo pacman -S python39` Adjust for you distribution, arch defaults to a newer python

```mkdir -p ~/.local/share/cemu/graphicPacks/BreathOfTheWild_BCML
python3.9 -m venv /.local/bcml_env
source ~/.local/bcml_env/bin/activate
python3.9 -m pip install bcml
~/.local/bcml_env/bin/bcml
```

to launch BCML in the future

`source ~/.local/bcml_env/bin/activate; ~/.local/bcml_env/bin/bcml`

- In BCML, check 'without cemu' and set export path to '~/.local/share/cemu/graphicPacks/BreathOfTheWild_BCML'
- install your mods
- execute `curl https://pastebin.com/raw/igCLK2tz -o ~/.local/share/cemu/graphicPacks/BreathOfTheWild_BCML/rules.txt`

* If your mods still don't load, verify that ~/.local/share/cemu/graphicPacks/BreathOfTheWild_BCML/rules.txt exist and try 'disable links for master mod' in BCML settings

### macOS Setup

Running BCML on macOS requires some additional setup.

#### Additional Prerequisites for macOS

-   CMake 3.12 or later
-   Xcode Command Line Tools (`xcode-select --install`)
-   [Homebrew](https://brew.sh) (recommended for dependency management)
-   Python 3.9 or later installed via Homebrew

#### Build from Source on macOS

A `bootstrap_macos.sh` file is included to perform all of the build steps in a virtual environment. Read below for details to perform the steps manually.

##### Intel

Set the environment variable `MACOSX_DEPLOYMENT_TARGET` to `10.14` or higher, then follow the same steps as for building from source [below](#building-from-source).

##### Apple Silicon

PyQt5 has issues building on Apple Silicon, so this guide will use [Homebrew](https://brew.sh)'s prebuilt version. This means that Homebrew Python is required, and that the minimum required version is Python 3.9.
```
brew install python@3.9
brew install pyqt@5
/opt/homebrew/bin/python3.9 -m venv --system-site-packages venv
source venv/bin/activate
```
and then follow the same steps as building from source below, starting from Step 2.
You can also just run `bootstrap_macos.sh` to perform the above steps.

Alternatively, Rosetta can be used to build for Intel, either by starting the Terminal through Rosetta, or with `arch -x86_64 ./bootstrap_macos.sh`

#### Install from Wheel on macOS

Download the wheel corresponding to your architecture and Python version from [here](https://github.com/neebyA/BCML/releases), and install with `pip install <path_to_wheel>`, substituting in the correct file path, e.g. `pip install ~/Downloads/bcml-3.10.8-cp310-cp310-macosx_10_14_x86_64.whl`

Note that on Apple Silicon you should still install `pyqt@5` and Python through Homebrew, or install the Intel binary using Rosetta.

### Building from Source

Building from source requires, in addition to the general prerequisites:

-   Python 3.7 - 3.10 64 bit

-   Rust 1.60+ (nightly)

-   Node.js v14+

-   mkdocs and mkdocs-material

    Run `pip install mkdocs mkdocs-material` in venv if not using `bootstrap.sh`

Steps to build from source:

1. Create and activate a Python virtual environment (venv)

    1. Open terminal to repo root folder
    2. `python -m venv venv`
    3. Activate the venv (usually `venv/bin/activate` on Linux or `venv\Scripts\activate.ps1` on Windows)

2. Install Python requirements

    1. Open terminal to repo root folder
    2. Run `pip install -r requirements.txt`
    3. Also install Maturin: `pip install maturin`

3. Build Rust extension module

    1. Open terminal to repo root folder
    2. Run `maturin develop` (or `maturin develop --release` for performance)

4. Prepare the webpack bundle

    1. Open terminal to `bcml/assets`
    2. Run `npm install`
    3. Run `npm run build` (or `npm run test` to watch while editing)

5. Build the docs

    1. Open terminal to repo root folder
    2. Run `mkdocs build`

6. Create an installable wheel with `maturin build` or run without installing with
   `python -m bcml`

Note that on Linux, you can simply run `bootstrap.sh` to perform these steps
automatically unless you would like more control.

## BCML macOS Integrated Application

The project has been restructured to make the macOS launcher the central component with BCML fully integrated into it. This creates a standalone macOS application that provides a complete BCML experience without requiring separate installation steps. The integrated approach offers:

- A native macOS application experience with no Terminal knowledge required
- One-click installation via DMG file
- All required dependencies bundled within the application
- Automatic environment configuration for optimal performance
- Seamless updates through application replacement
- Visually appealing icon in your Dock and Applications folder

### Installation of BCML macOS App

#### Method 1: Download and Install the Pre-built App

1. Download the latest DMG file from the [Releases](https://github.com/MetalOath/BCML-macOS-App/releases) page
2. Mount the DMG file by double-clicking it
3. Drag the BCML app to your Applications folder
4. Unmount the DMG by dragging it to the Trash

#### Method 2: Build the Application from Source

1. Make the build script executable:
   ```bash
   chmod +x launcher/scripts/build.sh
   ```

2. Run the build script:
   ```bash
   ./launcher/scripts/build.sh
   ```

3. The built application will be available in the `launcher/build` directory, along with a DMG file

### Using the BCML macOS App

1. Launch BCML from your Applications folder or Dock
2. If launching for the first time, you may need to right-click (or Control+click) the app and select "Open" to bypass macOS security restrictions
3. BCML will launch with all components properly configured

### Troubleshooting the BCML macOS App

If you encounter issues:

- Check the logs in `~/Library/Logs/BCML/bcml.log` for detailed error information
- Ensure your system meets the minimum requirements (macOS 10.15 Catalina or later)
- For permission errors, ensure the app has execution permissions
- If experiencing graphical issues, try launching with the Terminal command: `open -a BCML --args --disable-gpu`

## Usage and Troubleshooting

For information on how to use BCML, see the Help dialog in-app or read the documentation
[on the repo](https://github.com/NiceneNerd/BCML/tree/master/docs). For issues and
troubleshooting, please check the official
[Troubleshooting](https://github.com/NiceneNerd/BCML/wiki/Troubleshooting) page.

## Contributing

-   Issues: <https://github.com/NiceneNerd/BCML/issues>
-   Source: <https://github.com/NiceneNerd/BCML>

BOTW is an immensely complex game, and there are a number of new mergers that could be
written. If you find an aspect of the game that can be complicated by mod conflicts, but
BCML doesn't yet handle it, feel free to try writing a merger for it and submitting a
PR.

Python and JSX code for BCML is subject to formatting standards. Python should be
formatted with Black. JSX should be formatted with Prettier, using the following
settings:

```json
{
    "prettier.arrowParens": "avoid",
    "prettier.jsxBracketSameLine": true,
    "prettier.printWidth": 88,
    "prettier.tabWidth": 4,
    "prettier.trailingComma": "none"
}
```

## License

The BCML core components are licensed under the terms of the GNU General Public License, version 3
or later. The source is publicly available on
[GitHub](https://github.com/NiceneNerd/BCML).

The macOS application integration components are licensed under the MIT License.

This software includes the 7-Zip console application `7z.exe` and the library `7z.dll`,
which are licensed under the GNU Lesser General Public License. The source code for this
application is available for free at <https://www.7-zip.org/download.html>.

This software includes part of a modified copy of the `pywebview` Python package,
copyright 2020 Roman Sirokov under the BSD-3-Clause License. The source code for the
original library is available for free at <https://github.com/r0x0r/pywebview>.

## Acknowledgments

- [NiceneNerd](https://github.com/NiceneNerd) for the original BCML
- [neebyA](https://github.com/neebyA) for the macOS fork of BCML
- [MetalOath](https://github.com/MetalOath) for the integrated macOS application
- The BOTW modding community
