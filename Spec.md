# GraphitFeatureFlags Swift SDK — Minimal V1 Product and Engineering Specification

**Version:** Draft 6 minimal snapshot v1  
**Date:** 2026-06-04  
**Primary goal:** a tiny, reliable, provider-agnostic feature flag evaluator for Swift apps and SDKs.  
**Core rule:** GraphitFeatureFlags evaluates already-resolved flag snapshots. It does not fetch, cache, observe, track exposure, persist, identify users, or integrate with a vendor in v1.

---

## 1. Product summary

GraphitFeatureFlags v1 is a **pure immutable snapshot evaluator**.

It supports only:

- strongly typed feature flag keys;
- boolean enabled/disabled flags;
- simple string variants;
- immutable snapshots;
- a validated immutable evaluator;
- cheap synchronous reads;
- compact `Codable` values for app-owned loading or caching.

It intentionally does **not** include provider implementations, provider protocols, networking, PostHog integration, configuration-file loading helpers, caching, persistence, observation streams, exposure analytics, targeting rules, rollout rules, UI adapters, property wrappers, macros, dynamic member lookup, or process-wide singletons in v1.

The v1 public SDK is exactly these seven core types:

- `FeatureFlagKey`;
- `FeatureFlagVariant`;
- `FeatureFlagValue`;
- `FeatureFlag`;
- `FeatureFlagSnapshot`;
- `FeatureFlags`;
- `FeatureFlagError`.

Do not add extra public types unless the v1 contract is explicitly re-reviewed.

The app-facing usage should be boring:

```swift
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

Provider packages can be added later by depending on this core package and producing `FeatureFlagSnapshot` values through concrete package-owned loaders:

```swift
let snapshot = try await postHogLoader.snapshot()
let flags = try FeatureFlags(snapshot: snapshot)
```

The dependency direction is one-way:

```text
GraphitFeatureFlags                 // pure core values and evaluator
GraphitFeatureFlagsPostHog          // depends on GraphitFeatureFlags
GraphitFeatureFlagsConfiguration    // depends on GraphitFeatureFlags
App                                 // composes providers, cache, and evaluator
```

A shared provider protocol should wait until real provider packages prove the common shape.

---

## 2. Platform and toolchain

- Swift 6.3.x.
- Swift language mode 6.
- SwiftPM source package.
- Official v1 product focus: iOS 18+.
- Package also supports macOS 15+ for SwiftPM builds/tests and Mac app use.
- No Linux support claim in v1 unless the repository later adds Linux CI.
- No third-party Swift dependencies.
- Core source uses the Swift standard library only. Do not import Foundation in `Sources/GraphitFeatureFlags` for v1.

GraphitFeatureFlags must not depend on GraphitCache in v1. Snapshots are `Codable` so apps or provider packages can cache them using GraphitCache, files, `UserDefaults`, a database, or another app-owned mechanism. Consumer code, provider packages, README examples, and tests may use Foundation APIs such as `Data`, `URL`, `JSONEncoder`, and `JSONDecoder` when loading or storing snapshots.

---

## 3. Locked v1 decisions

### 3.1 Evaluator, not platform

V1 evaluates resolved flag values. It is not a feature flag platform, vendor client, refresh store, targeting engine, or analytics system.

### 3.2 Snapshot-based core

The core evaluates immutable `FeatureFlagSnapshot` values through a `FeatureFlags` evaluator. Updating flags means constructing a new snapshot/evaluator and replacing it in app-owned state.

No mutable store, actor, stream, global registry, refresh loop, or background task exists in v1.

### 3.3 No providers in core

No PostHog provider, configuration provider, custom backend provider, source protocol, provider registry, vendor abstraction, network transport, retry policy, identity model, or stale/offline policy exists in v1.

Provider packages later own fetch, retry, identity, cancellation, caching, stale fallback, vendor error mapping, and analytics policy. They map their data into `FeatureFlagSnapshot`.

### 3.4 No caching in core

Core does not persist flags or define stale/fallback policy. Cache behavior depends on provider identity, user context, refresh cadence, offline behavior, privacy, and app lifecycle.

### 3.5 Reads have no side effects

Calling `value(for:)`, `isEnabled`, or `variant(for:)` must not log, track exposure, enqueue work, mutate state, notify a provider, refresh data, perform I/O, or read a clock.

### 3.6 No targeting or rollout rules

V1 stores resolved values only. No user context, traits, percentage rollout, segments, prerequisites, date windows, or rule engine exists in core.

### 3.7 Explicit call sites only

No `FeatureFlags.shared`, service locator, property wrapper, macro, dynamic member lookup, task-local dependency, or hidden environment lookup exists in v1.

### 3.8 Similar taste to GraphitCache, not similar complexity

This SDK should share GraphitCache's engineering posture: small public surface, dedicated value types, explicit ownership, deterministic tests, no speculative abstractions.

It should **not** copy GraphitCache's storage architecture. There is no actor, lock, SQLite, file store, lease table, cleanup engine, or `Public/Internal` tree required for v1. This package is pure value validation plus dictionary lookup and should fit in a few source files.

### 3.9 Standard-library-only core

Core implementation uses Swift standard library types and protocols only. `Codable`, `Hashable`, `RawRepresentable`, `Sendable`, and collection types are sufficient for v1.

Foundation-dependent work belongs outside the core target: reading files, resolving bundle resources, using `Data` or `URL`, encoding/decoding JSON bytes, using `UserDefaults`, and composing with GraphitCache are app/provider/test responsibilities.

---

## 4. Concept model

### 4.1 Key

`FeatureFlagKey` is the app-defined identity for one flag.

Use dedicated keys instead of raw strings so call sites do not accidentally pass a variant or unrelated string where a flag key is expected.

```swift
enum AppFlags {
    static let newHome = FeatureFlagKey("new-home")
    static let checkoutExperiment = FeatureFlagKey("checkout-experiment")
}
```

No `ExpressibleByStringLiteral` in v1. This encourages schema constants instead of scattered magic strings.

### 4.2 Value

A value is one of three v1 states:

- disabled;
- enabled;
- enabled with a string variant.

`FeatureFlagValue` is a public immutable struct with factories, not a public enum. This is a locked API decision: callers should use projections instead of exhaustive switches, leaving future value shapes easier to add without source-breaking enum cases.

### 4.3 Variant

`FeatureFlagVariant` is a small string-backed value for simple variants or A/B tests. A variant implies enabled behavior.

### 4.4 Snapshot

`FeatureFlagSnapshot` is provider-neutral data: a list of resolved flags. It does not fetch, refresh, observe, or persist itself.

A snapshot can be invalid as directly initialized or decoded data. Semantic validity is guaranteed only after constructing a `FeatureFlags` evaluator.

### 4.5 Evaluator

`FeatureFlags` is an immutable validated evaluator built from a snapshot. It normalizes by key, rejects duplicate keys, validates text values, and provides cheap synchronous reads.

### 4.6 Missing vs disabled

A missing flag is different from an explicit disabled flag.

- Missing flag: caller default is used.
- Explicit `.disabled`: evaluates false regardless of caller default.
- Explicit `.enabled`: evaluates true.
- Explicit `.variant`: evaluates true and returns that variant.

Lookup keys are not semantically validated because reads do not throw. A lookup key that is absent from the validated evaluator, including an invalid raw key constructed by the caller, behaves as missing.

---

## 5. Public API surface

### 5.1 FeatureFlagKey

```swift
public struct FeatureFlagKey: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String)
    public init(rawValue: String)

    public var description: String { get }
}
```

Codable shape is a single JSON string:

```json
"new-home"
```

It must not use the synthesized object shape:

```json
{ "rawValue": "new-home" }
```

Validation happens when building `FeatureFlags`, not during construction or decoding:

- non-empty;
- no NUL or control characters;
- length <= 256 characters.

Avoid putting secrets, tokens, private user data, or sensitive targeting information in keys if your app logs or displays raw values.

### 5.2 FeatureFlagVariant

```swift
public struct FeatureFlagVariant: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String)
    public init(rawValue: String)

    public var description: String { get }
}
```

Codable shape is a single JSON string:

```json
"treatment"
```

Validation happens when building `FeatureFlags`, not during construction or decoding:

- non-empty;
- no NUL or control characters;
- length <= 256 characters.

No semantic meaning is assigned to variants by core v1. Apps and providers define their own variant names.

### 5.3 FeatureFlagValue

```swift
public struct FeatureFlagValue: Hashable, Codable, Sendable {
    public static let disabled: FeatureFlagValue
    public static let enabled: FeatureFlagValue

    public static func variant(_ variant: FeatureFlagVariant) -> FeatureFlagValue

    public var isEnabled: Bool { get }
    public var variant: FeatureFlagVariant? { get }
}
```

Rules:

- `.disabled.isEnabled == false`;
- `.enabled.isEnabled == true`;
- `.variant(x).isEnabled == true`;
- `.variant(x).variant == x`;
- `.disabled.variant == nil`;
- `.enabled.variant == nil`.

No public initializer is required in v1. Callers create values through `.disabled`, `.enabled`, and `.variant(_)`. `FeatureFlagValue` is intentionally not a public enum; its internal representation may be private and replaceable.

Codable shape is compact and human-editable:

```json
false
true
"treatment"
```

Meaning:

- JSON `false` decodes to `.disabled`;
- JSON `true` decodes to `.enabled`;
- JSON string decodes to `.variant(FeatureFlagVariant(string))`.

Encoding uses the same canonical shape. JSON `null`, numbers, arrays, and objects are unsupported for `FeatureFlagValue` in v1.

### 5.4 FeatureFlag

```swift
public struct FeatureFlag: Hashable, Codable, Sendable {
    public let key: FeatureFlagKey
    public let value: FeatureFlagValue

    public init(key: FeatureFlagKey, value: FeatureFlagValue)
}

public extension FeatureFlag {
    static func disabled(_ key: FeatureFlagKey) -> FeatureFlag
    static func enabled(_ key: FeatureFlagKey) -> FeatureFlag
    static func variant(_ key: FeatureFlagKey, _ variant: FeatureFlagVariant) -> FeatureFlag
}
```

Conveniences exist because they make static snapshots clear without hiding behavior:

```swift
let snapshot = FeatureFlagSnapshot([
    .enabled(AppFlags.newHome),
    .disabled(AppFlags.legacyCheckout),
    .variant(AppFlags.checkoutExperiment, FeatureFlagVariant("treatment"))
])
```

### 5.5 FeatureFlagSnapshot

```swift
public struct FeatureFlagSnapshot: Hashable, Codable, Sendable {
    public let flags: [FeatureFlag]

    public init(_ flags: [FeatureFlag])
}
```

`FeatureFlagSnapshot` is immutable data. Its initializer is nonthrowing. Decoding may throw for malformed Codable shape, but decoding does not reject duplicate keys, invalid keys, or invalid variants. Semantic validation occurs only when constructing `FeatureFlags`.

No empty convenience is required in v1. Callers that need an empty snapshot can pass `[]` explicitly.

No dictionary initializer is included in v1. Callers that already have `[FeatureFlagKey: FeatureFlagValue]` can map it to `[FeatureFlag]` in the ordering that is meaningful for their configuration or tests.

Suggested JSON shape:

```json
{
  "flags": [
    { "key": "new-home", "value": true },
    { "key": "legacy-checkout", "value": false },
    { "key": "checkout-experiment", "value": "treatment" }
  ]
}
```

### 5.6 FeatureFlags

```swift
public struct FeatureFlags: Sendable {
    public let snapshot: FeatureFlagSnapshot

    public init(snapshot: FeatureFlagSnapshot) throws
    public init(_ flags: [FeatureFlag]) throws

    public func value(for key: FeatureFlagKey) -> FeatureFlagValue?

    public func isEnabled(
        _ key: FeatureFlagKey,
        default defaultValue: Bool = false
    ) -> Bool

    public func variant(
        for key: FeatureFlagKey,
        default defaultValue: FeatureFlagVariant? = nil
    ) -> FeatureFlagVariant?
}
```

`FeatureFlags` is immutable and thread-safe by value semantics.

The public `snapshot` is the immutable source snapshot used to build the evaluator. It is useful for tests, debugging, inspection, and external caching composition. The normalized lookup table remains private:

```swift
private let valuesByKey: [FeatureFlagKey: FeatureFlagValue]
```

Rules:

- `value(for:)` returns the stored value or `nil` when missing.
- `isEnabled(_:default:)` returns the stored boolean meaning or `defaultValue` when missing.
- `variant(for:default:)` returns the stored variant or `defaultValue` when missing.
- An explicit `.disabled` returns `nil` from `variant(for:)`, not the default variant.
- An explicit `.enabled` without variant returns `nil` from `variant(for:)`, not the default variant.
- Lookup keys are not validated and reads never throw.
- Reads are synchronous and side-effect-free.
- No public all-flags dictionary view is included in v1; callers can inspect `snapshot.flags` when they need source data.

### 5.7 FeatureFlagError

```swift
public enum FeatureFlagError: Error, Sendable, Hashable, CustomStringConvertible {
    case invalidSnapshot(String)
    case duplicateFlag(FeatureFlagKey)

    public var description: String { get }
}
```

Errors are thrown while constructing a `FeatureFlags` evaluator, not while reading flags.

`invalidSnapshot` is intentionally scoped to the core domain. Core validates resolved snapshots; it does not own provider configuration, files, networking, cache policy, or vendor failures.

No low-level provider, filesystem, network, vendor, analytics, or cache errors exist in core v1.

---

## 6. Required behavior

### 6.1 Snapshot validation

`FeatureFlags.init` validates before creating the evaluator.

Validation rules:

- every key is valid;
- every variant value is valid;
- keys are unique;
- duplicate keys throw `FeatureFlagError.duplicateFlag`;
- invalid text throws `FeatureFlagError.invalidSnapshot`.

Text validation for keys and variants rejects:

- empty strings;
- strings longer than 256 characters;
- Unicode control scalars, including NUL.

The initializer does not perform I/O, spawn tasks, read clocks, use global state, log, or contact providers.

### 6.2 Evaluation semantics

Given:

```swift
let flags = try FeatureFlags([
    .disabled(FeatureFlagKey("off")),
    .enabled(FeatureFlagKey("on")),
    .variant(FeatureFlagKey("experiment"), FeatureFlagVariant("treatment"))
])
```

Expected behavior:

```swift
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

### 6.3 Static bundled configuration

Core supports static app-delivered configuration through normal `Codable` values, without owning bundle/resource lookup helpers. This is app/provider code and may import Foundation; the core target does not:

```swift
let data = try Data(contentsOf: configurationURL)
let snapshot = try JSONDecoder().decode(FeatureFlagSnapshot.self, from: data)
let flags = try FeatureFlags(snapshot: snapshot)
```

The SDK does not decide where `configurationURL` comes from and does not provide `Data`, `URL`, bundle, or file-loading helpers.

### 6.4 Provider-produced snapshots

A future provider package maps external data into core values:

```swift
public struct PostHogFlagSnapshotLoader: Sendable {
    public func snapshot() async throws -> FeatureFlagSnapshot {
        let response = try await client.fetchFlags()
        return FeatureFlagSnapshot(response.flags.map { flag in
            FeatureFlag(key: FeatureFlagKey(flag.key), value: mappedValue(flag))
        })
    }
}
```

Then apps compose:

```swift
let snapshot = try await loader.snapshot()
let flags = try FeatureFlags(snapshot: snapshot)
```

The provider owns fetch, retry, identity, caching, stale fallback, cancellation semantics, vendor error mapping, and any analytics policy.

### 6.5 Caching composition

Core values are cache-friendly:

```swift
let data = try JSONEncoder().encode(snapshot)
try await cacheBucket.setData(data, for: FeatureFlagCacheKeys.snapshot)
```

But GraphitFeatureFlags v1 does not import or depend on GraphitCache.

### 6.6 Concurrency and cancellation

All public values are `Sendable`.

`FeatureFlags` reads are synchronous and safe from concurrent tasks because the evaluator is immutable.

No actor, lock, task, async API, or cancellation behavior is required in core v1.

---

## 7. Internal architecture

V1 internals should be almost boring:

```text
FeatureFlags
  ├─ public immutable snapshot
  └─ private valuesByKey dictionary

FeatureFlagValidation
  ├─ key validation
  ├─ variant validation
  └─ duplicate-key validation
```

Implementation rules:

- no actor;
- no lock;
- no task;
- no singleton;
- no provider registry;
- no service locator;
- no generated code;
- no Foundation import in core source;
- no vendor imports;
- no GraphitCache import;
- no UI framework imports;
- no GraphitCache-style storage implementation tree.

Suggested source tree:

```text
Sources/GraphitFeatureFlags/
  FeatureFlagTextValues.swift      // FeatureFlagKey, FeatureFlagVariant
  FeatureFlagValue.swift
  FeatureFlagSnapshot.swift        // FeatureFlag, FeatureFlagSnapshot
  FeatureFlags.swift
  FeatureFlagError.swift
  FeatureFlagValidation.swift

Tests/GraphitFeatureFlagsTests/
  FeatureFlagValueTests.swift
  FeatureFlagSnapshotTests.swift
  FeatureFlagsLookupTests.swift
  FeatureFlagValidationTests.swift
  CodableTests.swift
  READMEExamplesTests.swift
```

The tree is a guide, not a mandate. Prefer fewer files when fewer files are clearer.

Suggested manifest:

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

---

## 8. Testing strategy

Use Swift Testing for v1 behavior tests.

High-signal tests:

1. key and variant raw value, description, equality, `Codable` string shape;
2. `FeatureFlagValue` factories, projections, equality, and compact `Codable` bool/string shape;
3. snapshot `Codable` object shape;
4. successful evaluator construction;
5. duplicate key rejection;
6. invalid key and variant rejection during evaluator construction;
7. missing/default/disabled/enabled/variant lookup semantics;
8. invalid lookup keys behave missing and do not throw;
9. README examples compile.

Do not add test infrastructure beyond what these tests need. No mock frameworks, provider fakes, clocks, temporary directories, or public testing product are required in core v1.

---

## 9. Deferred decisions and non-goals

Do not add placeholder public APIs for these areas in v1.

### 9.1 Providers

Deferred:

- provider protocol;
- `FeatureFlagProvider`, `FeatureFlagSource`, `FeatureFlagClient`, or similar abstractions;
- provider registry;
- PostHog integration;
- static configuration provider package;
- custom backend client;
- network transport;
- retry/backoff;
- refresh cadence;
- identity/user context;
- stale/offline policy.

Reason: the common provider shape is not proven yet. Provider packages can expose concrete snapshot loaders and map their data into `FeatureFlagSnapshot` without any core provider protocol.

### 9.2 Caching and persistence

Deferred:

- built-in caching;
- built-in persistence;
- GraphitCache dependency;
- `UserDefaults` helpers;
- file loading helpers;
- bundle/resource lookup helpers;
- stale snapshot policy;
- cache key naming policy.

Reason: cache behavior depends on provider identity, user context, offline behavior, privacy, storage constraints, and app lifecycle. Core values are `Codable`; apps and future provider packages decide storage.

### 9.3 Targeting and rule evaluation

Deferred:

- user traits/properties model;
- percentage rollout;
- bucketing/hash rollout;
- segment matching;
- prerequisite flags;
- environment matching;
- date windows;
- rule engine;
- evaluation reason/details API.

Reason: v1 evaluates already-resolved values.

### 9.4 Observation and live updates

Deferred:

- mutable flag store;
- actor-backed state owner;
- async refresh API;
- observation streams;
- callbacks;
- Combine publishers;
- background refresh tasks;
- app lifecycle hooks.

Reason: apps replace a `FeatureFlags` value in app-owned state when new flags arrive.

### 9.5 Exposure tracking and instrumentation

Deferred:

- exposure tracking;
- analytics event sink;
- impression events;
- evaluation callbacks;
- OSLog adapter;
- metrics hooks;
- automatic logging.

Reason: reads must have no side effects. Exposure tracking requires privacy, batching, delivery, retry, failure, deduplication, and lifecycle policy.

### 9.6 UI and syntax sugar

Deferred:

- SwiftUI/UIKit/AppKit adapters;
- `ObservableObject` or Observation models;
- property wrappers;
- macros;
- dynamic member lookup;
- global environment lookups;
- process-wide singleton.

Reason: explicit evaluator values are boring and hard to misuse.

### 9.7 Schema generation and typed conveniences

Deferred:

- generated flag schema API;
- macro-generated keys;
- string-literal key/variant conformance;
- public dictionary initializer;
- public all-flags dictionary view on `FeatureFlags`;
- typed variant enum machinery;
- public testing helper product.

Reason: apps can define simple key constants today. Generated schemas and typed variant helpers can be useful later, but should not become the main human-facing API by accident.

---

## 10. Engineering quality bar

- Swift 6 language mode.
- iOS 18+ and macOS 15+ package floor.
- One public product: `GraphitFeatureFlags`.
- No third-party dependencies.
- Swift standard library only in core source; no Foundation import.
- No GraphitCache dependency in core.
- Public APIs are documented.
- Public values are `Sendable`.
- Evaluator is immutable.
- Reads are synchronous and nonthrowing.
- Lookup keys are not validated and missing/invalid lookup keys behave missing.
- No hidden global mutable state.
- No service locator.
- No public provider abstraction before real providers exist.
- No networking, storage, cache, analytics, or UI imports in core.
- No fire-and-forget work.
- No public API outside this spec without explicit alignment.
- Public v1 surface remains exactly the seven core types listed in the product summary.

GraphitFeatureFlags v1 should be small enough to understand in minutes and stable enough to serve as the common value/evaluation layer for static, PostHog, and custom-provider integrations later.
