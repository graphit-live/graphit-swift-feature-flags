/// An immutable evaluator for a validated feature flag snapshot.
///
/// `FeatureFlags` performs semantic validation once during construction and then
/// provides cheap synchronous reads. Reads never validate lookup keys, throw,
/// perform I/O, log, track exposure, mutate state, or start background work.
///
/// To update flags, construct a new `FeatureFlags` value from a new snapshot and
/// replace it in app-owned state.
public struct FeatureFlags: Sendable {
    /// The immutable source snapshot used to create this evaluator.
    public let snapshot: FeatureFlagSnapshot

    private let valuesByKey: [FeatureFlagKey: FeatureFlagValue]

    /// Creates an evaluator from a snapshot of resolved feature flags.
    ///
    /// The initializer validates keys, variants, and duplicate keys before the
    /// evaluator can be used. Empty snapshots are valid.
    ///
    /// - Parameter snapshot: The immutable source snapshot to evaluate.
    /// - Throws: `FeatureFlagError` when the snapshot is semantically invalid.
    public init(snapshot: FeatureFlagSnapshot) throws {
        let valuesByKey = try FeatureFlagValidation.normalizedValues(from: snapshot)

        self.snapshot = snapshot
        self.valuesByKey = valuesByKey
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
    /// Lookup keys are not validated. A missing key, including an invalid lookup
    /// key that is absent from the evaluator, returns `nil`.
    ///
    /// - Parameter key: The feature flag key to read.
    /// - Returns: The resolved value, or `nil` when the key is missing.
    public func value(for key: FeatureFlagKey) -> FeatureFlagValue? {
        valuesByKey[key]
    }

    /// Returns whether a feature flag is enabled.
    ///
    /// Missing flags return `defaultValue`. Explicit disabled flags return
    /// `false` regardless of the default, and variant flags return `true`.
    /// Lookup keys are not validated.
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
    /// Missing flags return `defaultValue`. Explicit disabled flags and enabled
    /// flags without a variant return `nil`, not the default variant. Lookup
    /// keys are not validated.
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
