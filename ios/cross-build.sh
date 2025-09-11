#!/bin/bash

# Cross-compilation build script for iOS Palette Cycle app
# This script attempts to build the iOS app on Linux using xtool

set -e

echo "🔨 Cross-compiling Palette Cycle iOS app on Linux..."

# Configuration
APP_NAME="PaletteCycle"
BUNDLE_ID="com.palette-cycle.app"
IOS_VERSION_MIN="17.0"
ARCH="arm64"
TARGET="$ARCH-apple-ios$IOS_VERSION_MIN"

# Check for xtool
if ! command -v xtool &> /dev/null; then
    echo "❌ xtool not found. Please install it first:"
    echo "   curl -sSL https://xtool.sh/install.sh | sh"
    echo "   Or see cross-compile.md for alternative methods"
    exit 1
fi

# Create build directory
BUILD_DIR=".build-cross"
mkdir -p "$BUILD_DIR"

echo "📁 Build directory: $BUILD_DIR"
echo "🎯 Target: $TARGET"

# Swift source files to compile
SWIFT_FILES=(
    "PaletteCycle/Cycle.swift"
    "PaletteCycle/ImageModels.swift"
    "PaletteCycle/Palette.swift"
    "PaletteCycle/ImageLoader.swift"
    "PaletteCycleEngine.swift"
    "PaletteCycle/AppDelegate.swift"
    "PaletteCycle/SceneDelegate.swift"
    "PaletteCycle/ViewController.swift"
)

echo "📝 Compiling Swift files..."

# Try to use xtool for compilation
for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  📄 Compiling: $file"
        # Use xtool to compile Swift file for iOS
        xtool swift -target "$TARGET" -c "$file" -o "$BUILD_DIR/$(basename ${file%.swift}).o" || {
            echo "❌ Failed to compile $file with xtool"
            echo "🔄 Trying alternative approach..."
            
            # Alternative: Use system Swift with iOS target if available
            if command -v swift &> /dev/null; then
                swift -target "$TARGET" -c "$file" -o "$BUILD_DIR/$(basename ${file%.swift}).o" 2>/dev/null || {
                    echo "⚠️  Could not compile $file for iOS target. Skipping..."
                }
            fi
        }
    else
        echo "❌ File not found: $file"
        exit 1
    fi
done

# Try to link object files into an executable
echo "🔗 Linking object files..."
OBJECT_FILES=("$BUILD_DIR"/*.o)

if [ ${#OBJECT_FILES[@]} -gt 0 ] && [ -f "${OBJECT_FILES[0]}" ]; then
    xtool ld -arch "$ARCH" -ios_version_min "$IOS_VERSION_MIN" \
        "${OBJECT_FILES[@]}" \
        -o "$BUILD_DIR/$APP_NAME" || {
        echo "⚠️  Linking failed with xtool. This may require iOS SDK and signing."
    }
else
    echo "⚠️  No object files found. Cross-compilation may have failed."
fi

# Create Info.plist for the app
echo "📋 Creating Info.plist..."
cat > "$BUILD_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Palette Cycle</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIFileSharingEnabled</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# Copy resources
echo "📦 Copying resources..."
cp -r PaletteCycle/Assets.xcassets "$BUILD_DIR/" 2>/dev/null || true
cp -r PaletteCycle/Base.lproj "$BUILD_DIR/" 2>/dev/null || true
cp PaletteCycle/*.json "$BUILD_DIR/" 2>/dev/null || true

echo ""
echo "✅ Cross-compilation attempt completed!"
echo ""
echo "📂 Build artifacts in: $BUILD_DIR/"
echo ""
echo "⚠️  Important notes:"
echo "   • This is an experimental cross-compilation build"
echo "   • iOS apps typically require code signing to run on devices"
echo "   • Some iOS-specific features may not work without proper SDK"
echo "   • For production builds, use Xcode on macOS or the Nix flake approach"
echo ""
echo "🔄 Alternative: Try './nix-build.sh' for macOS VM-based building"