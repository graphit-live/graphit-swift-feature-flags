# Public API contract

All public declarations require documentation comments. Public values are `Sendable` where specified. Do not add public symbols outside this contract without explicit alignment.

## `FeatureFlagKey`

```swift
public struct FeatureFlagKey: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String)
    public init(rawValue: String)

    public var description: String { get }
}
```

Rules:

- Dedicated key type prevents raw-string mixups at call sites.
- No `ExpressibleByStringLiteral` in v1.
- Construction and decoding are nonvalidating.
- Semantic validation happens only when constructing `FeatureFlags`.
- Codable shape is a single JSON string, not `{ "rawValue": ... }`.

## `FeatureFlagVariant`

```swift
public struct FeatureFlagVariant: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let rawValue: String

    public init(_ rawValue: String)
    public init(rawValue: String)

    public var description: String { get }
}
```

Rules:

- Dedicated variant type prevents accidentally passing unrelated strings where a variant is expected.
- No `ExpressibleByStringLiteral` in v1.
- Construction and decoding are nonvalidating.
- Semantic validation happens only when constructing `FeatureFlags`.
- Codable shape is a single JSON string.

## `FeatureFlagValue`

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

- No public initializer in v1.
- Intentionally not a public enum; callers use projections instead of exhaustive switches.
- `.disabled.isEnabled == false`.
- `.enabled.isEnabled == true`.
- `.variant(x).isEnabled == true`.
- `.variant(x).variant == x`.
- `.disabled.variant == nil`.
- `.enabled.variant == nil`.
- Codable shape is compact: `false`, `true`, or a JSON string for variants.
- JSON `null`, numbers, arrays, and objects are unsupported.

## `FeatureFlag`

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

Rules:

- Immutable resolved flag entry.
- Codable object shape uses `key` and `value` fields.
- Convenience factories are allowed because they make static snapshots clear without hiding behavior.

## `FeatureFlagSnapshot`

```swift
public struct FeatureFlagSnapshot: Hashable, Codable, Sendable {
    public let flags: [FeatureFlag]

    public init(_ flags: [FeatureFlag])
}
```

Rules:

- Immutable provider-neutral data.
- Initializer is nonthrowing.
- Decoding may throw for malformed Codable shape only.
- Decoding does not reject duplicate keys, invalid keys, or invalid variants.
- Semantic validation happens only when constructing `FeatureFlags`.
- No public empty convenience and no dictionary initializer in v1.

## `FeatureFlags`

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

Rules:

- Immutable validated evaluator.
- `snapshot` exposes the immutable source snapshot used to build the evaluator.
- The normalized lookup table stays private.
- Reads are synchronous, nonthrowing, and side-effect-free.
- Lookup keys are not validated; absent or invalid lookup keys behave as missing.
- No public all-flags dictionary view in v1.

## `FeatureFlagError`

```swift
public enum FeatureFlagError: Error, Sendable, Hashable, CustomStringConvertible {
    case invalidSnapshot(String)
    case duplicateFlag(FeatureFlagKey)

    public var description: String { get }
}
```

Rules:

- Thrown while constructing `FeatureFlags`, never while reading.
- Scoped to core snapshot validation only.
- Does not include provider, filesystem, network, cache, analytics, or vendor failures.
