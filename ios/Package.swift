// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PaletteCycle",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PaletteCycle",
            targets: ["PaletteCycle"]),
    ],
    targets: [
        .target(
            name: "PaletteCycle",
            dependencies: [],
            path: "PaletteCycle",
            exclude: [
                "Assets.xcassets",
                "Base.lproj",
                "Info.plist",
                "AppDelegate.swift",
                "SceneDelegate.swift", 
                "ViewController.swift",
                "DefaultImage.json",
                "Timelines.json",
                "ImageCollections.json"
            ],
            sources: [
                "Cycle.swift",
                "ImageModels.swift", 
                "Palette.swift",
                "ImageLoader.swift",
                "PaletteCycleEngine.swift"
            ]
        ),
    ]
)
