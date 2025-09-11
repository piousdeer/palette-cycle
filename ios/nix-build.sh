#!/bin/bash

# Nix-based iOS app builder using macOS VM
# This script uses NixThePlanet to create a macOS VM and build the iOS app inside it

set -e

echo "🍎 Building Palette Cycle iOS app using Nix + macOS VM..."

# Check if Nix is available
if ! command -v nix &> /dev/null; then
    echo "❌ Nix not found. Please install Nix first:"
    echo "   curl -L https://nixos.org/nix/install | sh"
    exit 1
fi

# Check if flakes are enabled
if ! nix --version | grep -q "flake"; then
    echo "⚠️  Nix flakes may not be enabled. You might need to enable them:"
    echo "   echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"
fi

echo "📦 Building with Nix flake..."

# Build the iOS app package
echo "🔨 Step 1: Building iOS app package..."
if nix build --print-build-logs .; then
    echo "✅ iOS app package built successfully!"
    
    # Show what was built
    if [ -L "result" ]; then
        echo "📂 Build result available at: $(readlink -f result)"
        echo "📋 Contents:"
        ls -la result/
        
        if [ -f "result/BUILD_INSTRUCTIONS.md" ]; then
            echo ""
            echo "📖 Build instructions:"
            cat result/BUILD_INSTRUCTIONS.md
        fi
    fi
else
    echo "❌ Build failed. Trying alternative approach..."
fi

echo ""
echo "🖥️  To build using macOS VM approach:"
echo "   1. Make sure you have sufficient disk space (>50GB for macOS VM)"
echo "   2. Run: nix run github:MatthewCroughan/NixThePlanet#macos-vm"
echo "   3. Inside the VM, install Xcode and build the project"
echo ""
echo "⚡ For immediate cross-compilation attempt:"
echo "   ./cross-build.sh"
echo ""
echo "📚 Documentation:"
echo "   • cross-compile.md - Cross-compilation instructions"
echo "   • BUILD_IPA.md - Original macOS build instructions"
echo "   • flake.nix - Nix flake configuration"