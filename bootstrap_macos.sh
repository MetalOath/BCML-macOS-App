#!/bin/zsh

ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo "Intel Mac, using bootstrap.sh with MACOSX_DEPLOYMENT_TARGET=10.14"
    # default target on Intel is 10.7, which is too low to compile all crates
    exec env MACOSX_DEPLOYMENT_TARGET=10.14 ./bootstrap.sh
fi

# bootstrap.sh below, but with some modifications for Apple silicon
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

if [ ! command -v brew &> /dev/null ]
then
    echo "Homebrew is required to build BCML on Apple Silicon"
    exit
fi

if test -z "$(find $(brew --prefix)/bin -maxdepth 1 -name 'python3.*' -print -quit)"
then
    echo "Homebrew Python 3.9+ is required to build BCML but was not found"
    exit
fi

# Homebrew pyqt@5 requires Python >= 3.9. Choose the lowest installed version
PYTHON_VERSION=$(ls $(brew --prefix)/bin/python3.* | grep -v config | cut -d . -f 2 | awk '$1 >= 9' | sort -n | head -n 1)

if test -z "$PYTHON_VERSION"
then
    echo "Homebrew Python 3.9+ is required to build BCML but was not found"
    exit
fi

if [ ! command -v npm &> /dev/null ] || [ $(version $($(echo node -v) | sed -e s/^v//)) -lt 14000000000 ]
then
    echo "Node.js v14+ is required to build BCML but was not found"
    exit
fi

if [ ! command -v cargo &> /dev/null ] || [ $(version $(cargo -V | sed -e s/^cargo\ //)) -lt 1060000000 ]
then
    echo "Cargo 1.60+ is required to build BCML but was not found"
    exit
fi

if [ ! command -v cmake &> /dev/null ] || [ $(version $(cmake --version | head -n 1 | sed -e s/^cmake\ version\ //)) -lt 3012000000 ]
then
    echo "cmake 3.12+ is required to build BCML but was not found"
    exit
fi

# Apple Silicon has issues with installing PyQt5 using pip without Rosetta. We can get around this by using the homebrew version
echo "Installing pyqt@5..."
brew ls pyqt@5 &> /dev/null || brew install pyqt@5

echo "Creating Python virtual environment..."
$(brew --prefix)/bin/python3.$PYTHON_VERSION -m venv --system-site-packages venv >/dev/null
source venv/bin/activate

echo "Installing Python dependencies..."
pip3 install --disable-pip-version-check mkdocs mkdocs-material setuptools wheel pyqtwebengine maturin >/dev/null
pip3 install --disable-pip-version-check -r requirements.txt >/dev/null

echo "Building docs..."
mkdocs build -q -d bcml/assets/help >/dev/null

echo "Installing npm packages..."
export NODE_OPTIONS=--openssl-legacy-provider
cd bcml/assets
npm install --loglevel=error >/dev/null
echo "Building webpack bundle..."
npm run build --loglevel=error >/dev/null
cd ../../

echo "Compiling Rust extension module..."
maturin develop -q >/dev/null

echo "Done! You are now ready to work on BCML."
echo "After \`source venv/bin/activate\`, you can run with \`python -m bcml\` or build an installable wheel with \`maturin build\`."
