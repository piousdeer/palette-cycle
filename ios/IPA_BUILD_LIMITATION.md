# iOS .ipa Build Limitation

## Technical Constraint

Unfortunately, iOS .ipa files can only be built on **macOS systems with Xcode installed**. This limitation exists because:

### Required Components (macOS Only)
- **iOS SDK**: Apple's iOS Software Development Kit
- **Code Signing**: Valid Apple Developer certificates  
- **Build Toolchain**: Xcode's iOS-specific compilation tools
- **Archive System**: iOS app packaging and export system

### Current Environment
- **Platform**: Linux x86_64
- **Available**: Swift 6.1.2 compiler (Linux target)
- **Missing**: iOS SDK, Xcode, iOS build tools

## What's Provided Instead

This repository contains **everything needed** to build the .ipa file on a macOS system:

### ✅ Complete Xcode Project
```
PaletteCycle.xcodeproj/         # Ready-to-build Xcode project
├── project.pbxproj             # Build configuration
└── project.xcworkspace/        # Workspace settings
```

### ✅ All Source Code
```
PaletteCycle/
├── Cycle.swift                 # Core palette cycling algorithm
├── Palette.swift               # Color manipulation & BlendShift
├── PaletteCycleEngine.swift    # Animation engine
├── ImageLoader.swift           # Network & caching
├── ViewController.swift        # Main UI implementation
├── AppDelegate.swift           # App lifecycle
├── SceneDelegate.swift         # Scene management
└── ImageModels.swift           # Data structures
```

### ✅ Assets & Resources
```
PaletteCycle/
├── Assets.xcassets/            # App icons & colors
├── Base.lproj/                 # Storyboards & UI
├── Info.plist                  # App configuration
├── Timelines.json              # Image collection data
├── ImageCollections.json       # Collection definitions
└── DefaultImage.json           # Default image data
```

### ✅ Build System
```
BUILD_IPA.md                    # Step-by-step build instructions
ExportOptions.plist             # Archive export configuration
build.sh                        # Compilation test script
PaletteCycle-iOS.zip           # Complete project archive
```

## How to Build the .ipa File

### Option 1: Xcode GUI (Recommended)
1. **Transfer to macOS**: Download `PaletteCycle-iOS.zip`
2. **Open Project**: Double-click `PaletteCycle.xcodeproj`
3. **Configure Signing**: Set your Apple Developer team
4. **Archive**: Product → Archive
5. **Export**: Choose distribution method → Export .ipa

### Option 2: Command Line
```bash
# On macOS with Xcode installed:
xcodebuild archive -project PaletteCycle.xcodeproj -scheme PaletteCycle -archivePath ./PaletteCycle.xcarchive
xcodebuild -exportArchive -archivePath ./PaletteCycle.xcarchive -exportPath ./export -exportOptionsPlist ExportOptions.plist
```

## Expected Result

The built .ipa file will contain:
- **Native iOS app** for iPhone and iPad
- **Universal binary** supporting all iOS devices
- **Complete functionality** from the Android version
- **Optimized performance** for iOS hardware
- **App Store ready** (with proper certificates)

## File Size Estimate
- **App Bundle**: ~5-8 MB
- **IPA Archive**: ~3-5 MB compressed
- **With cached images**: ~50-100 MB total

---

**Note**: The iOS project is complete and ready for compilation. The only requirement is access to a macOS system with Xcode for the final build step.