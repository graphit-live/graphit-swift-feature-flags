// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "GraphitFeatureFlags",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "GraphitFeatureFlags", targets: ["GraphitFeatureFlags"])
    ],
    targets: [
        .target(
            name: "GraphitFeatureFlags",
            dependencies: [],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "GraphitFeatureFlagsTests",
            dependencies: ["GraphitFeatureFlags"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
