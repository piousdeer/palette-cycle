# Palette Cycle - iOS App

This directory contains a complete iOS rewrite of the Palette Cycle Android app, featuring Mark Ferrari's animated palette cycling art.

## 🎨 Features

- **Core palette cycling algorithms** converted from Kotlin to Swift
- **iOS native UI** with collection and image selection
- **Network image downloading** from effectgames.com
- **Local caching** of downloaded images
- **Real-time animation** using CADisplayLink
- **Universal support** for iPhone and iPad
- **Portrait and landscape** orientations

## 📱 Project Structure

```
PaletteCycle.xcodeproj/         # Xcode project file
PaletteCycle/
├── Core Engine/
│   ├── Cycle.swift            # Color cycling algorithm (converted from Kotlin)
│   ├── Palette.swift          # Palette manipulation and blending
│   ├── PaletteCycleEngine.swift # Main animation engine
│   └── ImageModels.swift      # JSON data models
├── Image Loading/
│   └── ImageLoader.swift      # Network downloading and caching
├── UI/
│   ├── ViewController.swift   # Main app interface
│   ├── AppDelegate.swift      # App lifecycle
│   └── SceneDelegate.swift    # Scene management
├── Resources/
│   ├── Assets.xcassets/       # App icons and colors
│   ├── Base.lproj/           # Storyboards (Main, LaunchScreen)
│   ├── DefaultImage.json     # Default palette image
│   ├── Timelines.json        # Timeline collections
│   └── ImageCollections.json # Image collections
└── Info.plist               # App configuration
```

## 🔧 Requirements

- **Xcode 15.0+** (macOS only)
- **iOS 17.0+** deployment target
- **Swift 5.9+**
- **macOS** for building IPA files

## 🏗️ Building the App

### Option 1: Xcode (Recommended)

1. **Open in Xcode:**
   ```bash
   open PaletteCycle.xcodeproj
   ```

2. **Select Target Device:**
   - Choose "Any iOS Device (arm64)" for real device
   - Choose iPhone/iPad Simulator for testing

3. **Build and Run:**
   - Press `Cmd+R` to build and run
   - Or use `Product → Run` from menu

4. **Create IPA File:**
   - Use `Product → Archive`
   - Follow archive export wizard
   - Select "Distribute App" → "Custom" → "Enterprise/Ad Hoc"

### Option 2: Command Line (xcodebuild)

```bash
# Build for device
xcodebuild -project PaletteCycle.xcodeproj \
           -scheme PaletteCycle \
           -configuration Release \
           -destination generic/platform=iOS \
           build

# Create archive
xcodebuild -project PaletteCycle.xcodeproj \
           -scheme PaletteCycle \
           -configuration Release \
           -destination generic/platform=iOS \
           archive -archivePath ./PaletteCycle.xcarchive

# Export IPA
xcodebuild -exportArchive \
           -archivePath ./PaletteCycle.xcarchive \
           -exportPath ./export \
           -exportOptionsPlist ExportOptions.plist
```

## 🎯 Key Differences from Android Version

### Architecture Changes
- **UIKit** instead of Android Views
- **CADisplayLink** instead of Handler/HandlerThread
- **URLSession** instead of HttpURLConnection
- **FileManager** instead of Android file I/O
- **CoreGraphics** for bitmap manipulation

### Algorithm Conversions
- **Cycle.kt → Cycle.swift**: Direct 1:1 conversion
- **Palette.kt → Palette.swift**: Adapted for Swift memory model
- **ImageLoader.kt → ImageLoader.swift**: iOS networking patterns
- **PaletteDrawer.kt → PaletteCycleEngine.swift**: iOS animation loops

### UI Adaptations
- **Storyboard-based** interface design
- **UIPickerView** for collection/image selection
- **UIImageView** for displaying animated images
- **Navigation Controller** for iOS navigation patterns

## 🚀 Running the App

1. **Launch** the app from home screen
2. **Select Collection** using the first picker
3. **Choose Image** using the second picker
4. **Tap Play** to start palette cycling animation
5. **Use Settings** to preload images or view about info

## 🔄 Algorithm Validation

The core palette cycling algorithm has been tested and validated:

```swift
// Core algorithm test results
✅ Core palette cycling algorithm test passed!
   Cycle amount for 1000ms: 0.03
   Rate: 10, Range: 0-15
```

## 📊 Technical Details

### Color Cycling Engine
- **Real-time palette manipulation** using Mark Ferrari's techniques
- **BlendShift technology** ported from Joseph Huckaby's code
- **Multi-cycle support** with different rates and patterns
- **Sine wave and ping-pong** cycling modes

### Performance Optimizations
- **Bitmap caching** for smooth animation
- **Background downloading** of image data
- **Memory management** optimized for iOS
- **60fps animation** using CADisplayLink

### Network Architecture
- **Progressive downloading** of image collections
- **GZIP compression** support
- **Local caching** in Documents directory
- **Background tasks** for preloading

## 📝 Development Notes

### Completed Conversions
- ✅ **Cycle.swift** - Core color cycling algorithm
- ✅ **Palette.swift** - Color manipulation and blending
- ✅ **ImageModels.swift** - JSON data structures
- ✅ **ImageLoader.swift** - Network downloading and caching
- ✅ **PaletteCycleEngine.swift** - Animation engine
- ✅ **ViewController.swift** - Main UI implementation
- ✅ **Project structure** - Complete Xcode project

### Key Features Implemented
- ✅ **Real-time animation** with palette cycling
- ✅ **Collection browsing** and image selection
- ✅ **Network image loading** from effectgames.com
- ✅ **Local caching** of downloaded images
- ✅ **iOS-native UI** with storyboards
- ✅ **Universal device support** (iPhone/iPad)

## 🎨 Art Credits

- **Art:** Mark Ferrari
- **Original Algorithm:** Joseph Huckaby (BlendShift technology)
- **Original Website:** http://www.effectgames.com/demos/canvascycle/
- **iOS Implementation:** PiousDeer

## 📄 License

This iOS implementation maintains the same open-source spirit as the original Android version, converted with respect for the original creators' work.