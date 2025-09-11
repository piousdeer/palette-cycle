# Build Instructions for iOS IPA File

## Method 1: Using Xcode (Recommended)

1. **Transfer the project to macOS:**
   ```bash
   # Download PaletteCycle-iOS.zip from this repository
   unzip PaletteCycle-iOS.zip
   cd PaletteCycle-iOS
   ```

2. **Open in Xcode:**
   ```bash
   open PaletteCycle.xcodeproj
   ```

3. **Configure signing:**
   - Select PaletteCycle target
   - Go to "Signing & Capabilities"
   - Set your Team and Bundle Identifier
   - Enable "Automatically manage signing"

4. **Build for device:**
   - Select "Any iOS Device (arm64)" as destination
   - Press Cmd+B to build

5. **Create Archive:**
   - Product → Archive
   - Once archive completes, click "Distribute App"
   - Choose "Custom" → "Enterprise" or "Ad Hoc"
   - Follow export wizard to create IPA

## Method 2: Command Line

```bash
# Configure code signing first in Xcode, then:

# Clean and build
xcodebuild clean -project PaletteCycle.xcodeproj -scheme PaletteCycle

# Create archive
xcodebuild archive \
  -project PaletteCycle.xcodeproj \
  -scheme PaletteCycle \
  -archivePath ./PaletteCycle.xcarchive \
  -destination "generic/platform=iOS"

# Export IPA
xcodebuild -exportArchive \
  -archivePath ./PaletteCycle.xcarchive \
  -exportPath ./export \
  -exportOptionsPlist ExportOptions.plist
```

The IPA file will be created in the export directory as `PaletteCycle.ipa`.

## Distribution

The resulting IPA can be:
- Installed via Xcode Devices window
- Distributed through TestFlight (requires Apple Developer account)
- Sideloaded using tools like AltStore
- Distributed as Enterprise app (requires Enterprise Developer account)

## File Size Estimate

Based on similar iOS apps:
- **App Bundle:** ~5-8 MB
- **With all images cached:** ~50-100 MB
- **IPA file:** ~3-5 MB compressed