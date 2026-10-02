// swift-tools-version: 5.9
import PackageDescription

// A local-only test harness for the same Models and ViewModels used by the iOS target.
// Run on macOS 14+ with Xcode 15+; no third-party dependencies are resolved.
let package = Package(
    name: "FuelControlLogic",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [.library(name: "FuelControlLogic", targets: ["FuelControlLogic"])],
    targets: [
        .target(name: "FuelControlLogic", path: "FuelControl",
                exclude: ["App", "Components", "Screens", "Assets.xcassets", "Preview Content",
                          "FuelControlApp.swift", "Info.plist", "Theme/ViewModifiers.swift"],
                sources: ["Models", "ViewModels", "Theme/Theme.swift", "Theme/Formatters.swift"]),
        .testTarget(name: "FuelControlLogicTests", dependencies: ["FuelControlLogic"], path: "Tests")
    ]
)
