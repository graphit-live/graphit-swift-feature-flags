/// An immutable evaluator for a validated feature flag snapshot.
public struct FeatureFlags: Sendable {
    /// The immutable source snapshot used to create this evaluator.
    public let snapshot: FeatureFlagSnapshot

    private let valuesByKey: [FeatureFlagKey: FeatureFlagValue]

    /// Creates an evaluator from a snapshot of resolved feature flags.
    ///
    /// - Parameter snapshot: The immutable source snapshot to evaluate.
    /// - Throws: `FeatureFlagError` when the snapshot is semantically invalid.
    public init(snapshot: FeatureFlagSnapshot) throws {
        self.snapshot = snapshot
        self.valuesByKey = [:]
    }

    /// Creates an evaluator from resolved feature flag entries.
    ///
    /// - Parameter flags: The resolved flag entries in source order.
    /// - Throws: `FeatureFlagError` when the resulting snapshot is semantically invalid.
    public init(_ flags: [FeatureFlag]) throws {
        try self.init(snapshot: FeatureFlagSnapshot(flags))
    }

    /// Returns the resolved value for a key.
    ///
    /// - Parameter key: The feature flag key to read.
    /// - Returns: The resolved value, or `nil` when the key is missing.
    public func value(for key: FeatureFlagKey) -> FeatureFlagValue? {
        valuesByKey[key]
    }

    /// Returns whether a feature flag is enabled.
    ///
    /// - Parameters:
    ///   - key: The feature flag key to read.
    ///   - defaultValue: The value returned when `key` is missing.
    /// - Returns: The resolved enabled state, or `defaultValue` when the key is missing.
    public func isEnabled(
        _ key: FeatureFlagKey,
        default defaultValue: Bool = false
    ) -> Bool {
        value(for: key)?.isEnabled ?? defaultValue
    }

    /// Returns the resolved variant for a feature flag.
    ///
    /// - Parameters:
    ///   - key: The feature flag key to read.
    ///   - defaultValue: The variant returned when `key` is missing.
    /// - Returns: The resolved variant, or `defaultValue` when the key is missing.
    public func variant(
        for key: FeatureFlagKey,
        default defaultValue: FeatureFlagVariant? = nil
    ) -> FeatureFlagVariant? {
        guard let value = value(for: key) else {
            return defaultValue
        }

        return value.variant
    }
}
