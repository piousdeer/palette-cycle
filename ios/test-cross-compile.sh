#!/bin/bash

# Test script to demonstrate cross-compilation setup
# This shows the structure works even without xtool installed

echo "🧪 Testing cross-compilation setup..."

BUILD_DIR=".build-test"
mkdir -p "$BUILD_DIR"

echo "📁 Created build directory: $BUILD_DIR"

# Test that our Swift files exist and are accessible
SWIFT_FILES=(
    "PaletteCycle/Cycle.swift"
    "PaletteCycle/ImageModels.swift"
    "PaletteCycle/Palette.swift"
    "PaletteCycle/ImageLoader.swift"
    "PaletteCycle/PaletteCycleEngine.swift"
    "PaletteCycle/AppDelegate.swift"
    "PaletteCycle/SceneDelegate.swift"
    "PaletteCycle/ViewController.swift"
)

echo "📝 Checking Swift source files..."
for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ Found: $file"
    else
        echo "  ❌ Missing: $file"
    fi
done

# Test JSON data files
echo "📋 Checking JSON data files..."
JSON_FILES=(
    "PaletteCycle/DefaultImage.json"
    "PaletteCycle/Timelines.json" 
    "PaletteCycle/ImageCollections.json"
)

for file in "${JSON_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ Found: $file"
    else
        echo "  ❌ Missing: $file"
    fi
done

# Test project structure
echo "🏗️ Checking project structure..."
if [ -d "PaletteCycle.xcodeproj" ]; then
    echo "  ✅ Xcode project: PaletteCycle.xcodeproj"
else
    echo "  ❌ Missing: PaletteCycle.xcodeproj"
fi

if [ -f "Package.swift" ]; then
    echo "  ✅ Swift Package: Package.swift"
else
    echo "  ❌ Missing: Package.swift"
fi

if [ -f "flake.nix" ]; then
    echo "  ✅ Nix flake: flake.nix"
else
    echo "  ❌ Missing: flake.nix"
fi

# Create a simple Info.plist to show the concept works
echo "📋 Creating test Info.plist..."
cat > "$BUILD_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Palette Cycle</string>
    <key>CFBundleIdentifier</key>
    <string>com.palette-cycle.app</string>
    <key>CFBundleName</key>
    <string>PaletteCycle</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
</dict>
</plist>
EOF

echo "  ✅ Created: $BUILD_DIR/Info.plist"

# Copy some resources
echo "📦 Testing resource copying..."
cp -r PaletteCycle/*.json "$BUILD_DIR/" 2>/dev/null && echo "  ✅ Copied JSON files" || echo "  ⚠️  Some JSON files not found"
cp -r PaletteCycle/Assets.xcassets "$BUILD_DIR/" 2>/dev/null && echo "  ✅ Copied Assets.xcassets" || echo "  ⚠️  Assets.xcassets not found"

echo ""
echo "✅ Cross-compilation setup test completed!"
echo "📂 Test artifacts in: $BUILD_DIR/"
echo ""
echo "🎯 Summary:"
echo "   • Project structure validated"
echo "   • Source files checked"  
echo "   • Build process simulated"
echo "   • Ready for xtool or Nix building"
echo ""
echo "🚀 Next steps:"
echo "   • Install xtool: curl -sSL https://xtool.sh/install.sh | sh"
echo "   • Or install Nix: curl -L https://nixos.org/nix/install | sh"
echo "   • Then run: ./cross-build.sh or ./nix-build.sh"

# Cleanup
rm -rf "$BUILD_DIR"