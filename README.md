# GraphitFeatureFlags

GraphitFeatureFlags is a tiny Swift SDK for evaluating already-resolved feature flag snapshots. V1 is a pure immutable resolved-snapshot evaluator: it does not fetch, cache, persist, observe, identify users, track exposure, or integrate with vendors.

The public v1 surface is intentionally small:

- `FeatureFlagKey`
- `FeatureFlagVariant`
- `FeatureFlagValue`
- `FeatureFlag`
- `FeatureFlagSnapshot`
- `FeatureFlags`
- `FeatureFlagError`

## Platform and toolchain

- Swift 6.3.x
- Swift language mode 6
- iOS 18+ primary support
- macOS 15+ package support for SwiftPM builds/tests and Mac app use
- No Linux support claim in v1
- No third-party Swift dependencies
- Core source does not import Foundation

## Installation

Add this package with Swift Package Manager and depend on the `GraphitFeatureFlags` library product.

```swift
dependencies: [
    .package(url: "<package-url>", from: "0.1.0")
]
```

```swift
.product(name: "GraphitFeatureFlags", package: "graphit-swift-feature-flags")
```

## Quick start

Define app-owned keys once and build an immutable evaluator from resolved values:

```swift
import GraphitFeatureFlags

enum AppFlags {
    static let newHome = FeatureFlagKey("new-home")
    static let checkoutExperiment = FeatureFlagKey("checkout-experiment")
}

let flags = try FeatureFlags([
    .enabled(AppFlags.newHome),
    .variant(AppFlags.checkoutExperiment, FeatureFlagVariant("treatment"))
])

if flags.isEnabled(AppFlags.newHome) {
    showNewHome()
}

let checkoutVariant = flags.variant(for: AppFlags.checkoutExperiment)
```

`FeatureFlagKey` and `FeatureFlagVariant` are dedicated types so call sites do not accidentally pass unrelated raw strings where a flag key or variant is expected. They are intentionally not string literals in v1; prefer app-defined constants.

Avoid putting secrets, tokens, private user data, or sensitive targeting information in keys or variants if your app logs or displays raw values.

## Codable snapshots

Snapshots are `Codable` so apps or provider packages can load, store, or cache them outside the core SDK.

```json
{
  "flags": [
    { "key": "new-home", "value": true },
    { "key": "legacy-checkout", "value": false },
    { "key": "checkout-experiment", "value": "treatment" }
  ]
}
```

App/provider code may use Foundation APIs such as `Data`, `URL`, `JSONDecoder`, file loading, or `UserDefaults`, and may compose with GraphitCache, a database, or another app-owned storage system. The core target does not provide file, bundle, URL, resource, `UserDefaults`, GraphitCache, or persistence helpers.

```swift
import Foundation
import GraphitFeatureFlags

let data = try Data(contentsOf: configurationURL)
let snapshot = try JSONDecoder().decode(FeatureFlagSnapshot.self, from: data)
let flags = try FeatureFlags(snapshot: snapshot)
```

## Evaluation semantics

Missing flags are different from explicit disabled flags:

```swift
let flags = try FeatureFlags([
    .disabled(FeatureFlagKey("off")),
    .enabled(FeatureFlagKey("on")),
    .variant(FeatureFlagKey("experiment"), FeatureFlagVariant("treatment"))
])

flags.isEnabled(FeatureFlagKey("missing")) == false
flags.isEnabled(FeatureFlagKey("missing"), default: true) == true
flags.isEnabled(FeatureFlagKey("off"), default: true) == false
flags.isEnabled(FeatureFlagKey("on")) == true
flags.isEnabled(FeatureFlagKey("experiment")) == true

flags.variant(for: FeatureFlagKey("missing")) == nil
flags.variant(for: FeatureFlagKey("missing"), default: FeatureFlagVariant("control")) == FeatureFlagVariant("control")
flags.variant(for: FeatureFlagKey("off"), default: FeatureFlagVariant("control")) == nil
flags.variant(for: FeatureFlagKey("on"), default: FeatureFlagVariant("control")) == nil
flags.variant(for: FeatureFlagKey("experiment")) == FeatureFlagVariant("treatment")
```

A variant implies enabled behavior. Explicit `.disabled` and `.enabled` without a variant return `nil` from `variant(for:default:)`; only a missing key returns the default variant.

Lookup keys are not validated and reads never throw. A lookup key that is absent from the evaluator, including invalid raw key text, behaves as missing.

## Updating flags

`FeatureFlags` is immutable. To update flags, construct a new `FeatureFlagSnapshot` and `FeatureFlags` value, then replace the evaluator in app-owned state.

There is no mutable store, actor, observation stream, refresh loop, or process-wide singleton in v1.

## Validation and errors

`FeatureFlagSnapshot` construction and decoding are nonvalidating for semantic rules. Validation happens when constructing `FeatureFlags`.

The evaluator rejects:

- empty keys or variants
- keys or variants longer than 256 characters
- keys or variants containing Unicode control scalars
- duplicate keys

Construction throws `FeatureFlagError.invalidSnapshot` for invalid text and `FeatureFlagError.duplicateFlag` for duplicate keys. Reads are synchronous, nonthrowing, immutable, and side-effect-free.

## Non-goals in v1

GraphitFeatureFlags v1 does not include:

- provider APIs or provider registries
- PostHog or vendor integration
- networking, fetching, retry, refresh, or identity APIs
- caching, persistence, file loading, bundle loading, or `UserDefaults` helpers
- GraphitCache integration in core
- observation streams, callbacks, Combine, or async update APIs
- exposure tracking, analytics events, logging, metrics, or instrumentation hooks
- targeting rules, rollout rules, segments, or user traits
- SwiftUI, UIKit, AppKit, or Observation adapters
- globals, service locators, `FeatureFlags.shared`, property wrappers, macros, dynamic member lookup, or task-local dependency lookup

Future provider packages can depend on this core package and produce `FeatureFlagSnapshot` values through their own concrete loaders.
