# Package layout

## Manifest target

```swift
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
```

Reason: one public product keeps v1 small. iOS 18 is the primary product target. macOS 15 keeps local SwiftPM builds/tests straightforward on the same modern Swift floor.

No public testing product in v1.

## Source tree

Start flat and small. Do not copy GraphitCache's `Public/Internal` storage tree; this package has no storage engine.

```text
Sources/GraphitFeatureFlags/
  FeatureFlagTextValues.swift      // FeatureFlagKey, FeatureFlagVariant
  FeatureFlagValue.swift
  FeatureFlagSnapshot.swift        // FeatureFlag, FeatureFlagSnapshot
  FeatureFlags.swift
  FeatureFlagError.swift
  FeatureFlagValidation.swift

Tests/GraphitFeatureFlagsTests/
  FeatureFlagTextValueTests.swift
  FeatureFlagValueTests.swift
  FeatureFlagSnapshotTests.swift
  FeatureFlagsLookupTests.swift
  FeatureFlagValidationTests.swift
  CodableTests.swift
  READMEExamplesTests.swift
```

The tree is a guide, not a mandate. Prefer fewer files when fewer files are clearer. Split files only around real cohesive boundaries.

## Import rules

- `Sources/GraphitFeatureFlags`: no imports unless the standard library requires none; do not import `Foundation`.
- Tests may import `Foundation` for `JSONEncoder`, `JSONDecoder`, and `Data`.
- No SwiftUI, UIKit, AppKit, Combine, Observation, OSLog, networking, persistence, GraphitCache, PostHog, or vendor imports in core.

## Access rules

- `public` only for the exact v1 API contract.
- Every public type and public member needs a documentation comment.
- Implementation details stay `internal` or `private`.
- Prefer `private` for helper types such as `CodingKeys` or internal value storage when possible.
- Use `package` only if a future multi-target package creates a real cross-target collaboration need; v1 should not need it.

## No generated code

No code generation, macros, or generated schemas in v1. Apps can define explicit key constants such as:

```swift
enum AppFlags {
    static let newHome = FeatureFlagKey("new-home")
}
```
