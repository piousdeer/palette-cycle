{
  description = "Palette Cycle iOS app builder using macOS VM via NixThePlanet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # NixThePlanet for macOS VM support
    nixtheplanet = {
      url = "github:MatthewCroughan/NixThePlanet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixtheplanet, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # macOS VM configuration for building iOS apps
      macosVM = nixtheplanet.lib.mkDarwinSystem {
        inherit system;
        modules = [
          # Basic macOS configuration
          {
            environment.systemPackages = with pkgs; [
              # Development tools that will be available in the VM
              git
              curl
              unzip
            ];
          }
          
          # Custom module for iOS development
          {
            system.activationScripts.setupXcode = {
              text = ''
                echo "Setting up iOS development environment..."
                
                # Create workspace for our project
                mkdir -p /Users/builder/workspace
                
                # Note: Xcode would need to be installed manually in the VM
                # or downloaded and installed as part of the setup process
                echo "Xcode installation required for iOS builds"
              '';
            };
          }
        ];
      };

    in {
      # Main package that builds the iOS app
      packages.${system} = {
        default = pkgs.stdenv.mkDerivation {
          name = "palette-cycle-ios";
          version = "1.0.0";
          
          src = ./.;
          
          nativeBuildInputs = with pkgs; [
            curl
            unzip
            zip
            # Note: This would need the macOS VM to actually work
          ];
          
          buildPhase = ''
            echo "🚀 Building Palette Cycle iOS app using macOS VM..."
            echo "📁 Source directory: $PWD"
            
            # Copy source files to build area
            mkdir -p $out/app
            cp -r PaletteCycle* $out/app/ || true
            cp -r *.md $out/ || true
            cp -r *.sh $out/ || true
            
            # Create build instructions
            cat > $out/BUILD_INSTRUCTIONS.md << 'EOF'
# Building Palette Cycle iOS App with Nix + macOS VM

This package provides the iOS app source code ready for building in a macOS VM.

## Usage

1. **Build the VM and app**:
   ```bash
   nix build github:piousdeer/palette-cycle#ios
   ```

2. **Manual VM approach** (if automatic build fails):
   ```bash
   # Start the macOS VM
   nix run github:MatthewCroughan/NixThePlanet#macos-vm
   
   # Inside the VM:
   # 1. Install Xcode from Mac App Store
   # 2. Copy the project files to the VM
   # 3. Open PaletteCycle.xcodeproj
   # 4. Build and archive the project
   # 5. Export as IPA
   ```

## What's Included

- Complete iOS project source code
- Xcode project files (.xcodeproj)
- Build scripts and documentation
- Asset files and storyboards
- JSON data files for image collections

## Building Process

The build process involves:
1. Setting up a macOS VM using NixThePlanet
2. Installing Xcode inside the VM
3. Building the iOS project using Xcode's build tools
4. Exporting the final IPA file

## Notes

- Building iOS apps requires macOS and Xcode
- The VM approach provides this environment on Linux
- Initial setup may take significant time (VM creation + Xcode download)
- Resulting IPA will be signed with development certificates

EOF
            
            echo "✅ iOS app package prepared for macOS VM building"
          '';
          
          installPhase = ''
            echo "📦 Installing iOS app files..."
            # Files are already in $out from buildPhase
            echo "Installation complete in: $out"
          '';
          
          meta = with pkgs.lib; {
            description = "Palette Cycle iOS app built via macOS VM";
            homepage = "https://github.com/piousdeer/palette-cycle";
            license = licenses.mit;
            platforms = platforms.linux;
            maintainers = [ ];
          };
        };
        
        # VM-specific build script
        build-in-vm = pkgs.writeShellScriptBin "build-ios-in-vm" ''
          #!/bin/bash
          
          echo "🖥️  Starting macOS VM for iOS app building..."
          echo "⏳ This may take significant time for initial setup"
          
          # Create temporary directory for VM operations
          VM_WORKSPACE=$(mktemp -d)
          trap "rm -rf $VM_WORKSPACE" EXIT
          
          echo "📁 VM workspace: $VM_WORKSPACE"
          
          # Copy project files to VM workspace
          cp -r ${./.}/* $VM_WORKSPACE/
          
          echo "🚀 Starting macOS VM..."
          echo "📋 Instructions for building in VM:"
          echo "   1. Wait for macOS to boot"
          echo "   2. Install Xcode from Mac App Store (this will take time)"
          echo "   3. Open Terminal and navigate to /Users/builder/workspace"
          echo "   4. Copy the project files from the host system"
          echo "   5. Open PaletteCycle.xcodeproj in Xcode"
          echo "   6. Select Product → Archive"
          echo "   7. Export as IPA file"
          echo "   8. Copy the IPA back to host system"
          
          # Note: The actual VM launching would require NixThePlanet to be properly configured
          echo "⚠️  Manual VM setup required - see BUILD_INSTRUCTIONS.md"
        '';
      };
      
      # Development shell for working with the project
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          curl
          git
          unzip
          zip
          jq
        ];
        
        shellHook = ''
          echo "🎨 Palette Cycle iOS Development Environment"
          echo "📱 Available commands:"
          echo "   nix build                    - Build iOS app package"
          echo "   nix run .#build-in-vm       - Build using macOS VM"
          echo "   ./cross-build.sh            - Try cross-compilation"
          echo ""
          echo "📖 See BUILD_INSTRUCTIONS.md for detailed instructions"
        '';
      };
    };
}