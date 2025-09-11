# Cross-Compilation Setup for iOS on Linux

This document provides instructions for building the iOS Palette Cycle app on Linux using cross-compilation tools.

## Option 1: Using xtool Cross-Compilation

### Prerequisites

1. **Install xtool** (iOS cross-compilation toolchain for Linux):
   ```bash
   # Install xtool from https://xtool.sh
   curl -sSL https://xtool.sh/install.sh | sh
   ```

2. **Install required dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install build-essential clang llvm cmake ninja-build

   # Or for other distributions, install equivalent packages
   ```

3. **Download iOS SDK** (required for cross-compilation):
   - You'll need the iOS SDK files, which can be obtained from Xcode
   - Place the SDK in `~/ios-sdk/` or adjust paths in the build script

### Building with xtool

```bash
cd ios/
chmod +x cross-build.sh
./cross-build.sh
```

## Option 2: Using cctools-port

### Install cctools-port

```bash
git clone https://github.com/tpoechtrager/cctools-port.git
cd cctools-port
./usage_examples/ios_toolchain/build.sh
```

### Configure environment

```bash
export IOS_TOOLCHAIN_ROOT="/path/to/ios/toolchain"
export PATH="$IOS_TOOLCHAIN_ROOT/bin:$PATH"
```

### Build the app

```bash
cd ios/
./cross-build-cctools.sh
```

## Note

Cross-compiling iOS apps on Linux is complex and may require:
- iOS SDK files from macOS/Xcode
- Proper signing certificates for distribution
- Some features may not work identically to native Xcode builds

For the most reliable build, consider the Nix flake approach with macOS VM (see `flake.nix`).