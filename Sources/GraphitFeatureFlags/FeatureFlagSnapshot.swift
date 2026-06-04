/// One resolved feature flag entry in a snapshot.
///
/// A `FeatureFlag` contains already-resolved data. It does not fetch, refresh,
/// persist, observe, or track exposure for the flag.
public struct FeatureFlag: Hashable, Codable, Sendable {
    /// The feature flag key.
    public let key: FeatureFlagKey

    /// The resolved value for `key`.
    public let value: FeatureFlagValue

    /// Creates a resolved feature flag entry.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - value: The resolved feature flag value.
    public init(key: FeatureFlagKey, value: FeatureFlagValue) {
        self.key = key
        self.value = value
    }
}

/// Convenience factories for constructing resolved feature flag entries.
public extension FeatureFlag {
    /// Creates a disabled resolved flag entry for `key`.
    ///
    /// - Parameter key: The feature flag key.
    /// - Returns: A resolved flag entry with a disabled value.
    static func disabled(_ key: FeatureFlagKey) -> FeatureFlag {
        FeatureFlag(key: key, value: .disabled)
    }

    /// Creates an enabled resolved flag entry for `key`.
    ///
    /// - Parameter key: The feature flag key.
    /// - Returns: A resolved flag entry with an enabled value.
    static func enabled(_ key: FeatureFlagKey) -> FeatureFlag {
        FeatureFlag(key: key, value: .enabled)
    }

    /// Creates an enabled resolved flag entry with a variant for `key`.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - variant: The resolved variant value.
    /// - Returns: A resolved flag entry with a variant value.
    static func variant(_ key: FeatureFlagKey, _ variant: FeatureFlagVariant) -> FeatureFlag {
        FeatureFlag(key: key, value: .variant(variant))
    }
}

/// An immutable provider-neutral list of resolved feature flags.
///
/// A snapshot is data only. It may be decoded from app- or provider-owned
/// storage and can contain duplicate keys or invalid text until it is validated
/// by constructing a `FeatureFlags` evaluator.
public struct FeatureFlagSnapshot: Hashable, Codable, Sendable {
    /// The resolved flags in source order.
    public let flags: [FeatureFlag]

    /// Creates a snapshot from resolved flag entries.
    ///
    /// This initializer is nonthrowing and does not perform semantic
    /// validation. Invalid text or duplicate keys are rejected only when
    /// constructing a `FeatureFlags` evaluator.
    ///
    /// - Parameter flags: The resolved flags in source order.
    public init(_ flags: [FeatureFlag]) {
        self.flags = flags
    }
}
