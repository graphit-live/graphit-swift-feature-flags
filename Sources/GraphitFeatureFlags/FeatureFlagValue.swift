/// A resolved boolean or variant value for a feature flag.
public struct FeatureFlagValue: Hashable, Codable, Sendable {
    private enum Storage: Hashable, Codable, Sendable {
        case disabled
        case enabled
        case variant(FeatureFlagVariant)
    }

    private let storage: Storage

    private init(storage: Storage) {
        self.storage = storage
    }

    /// A resolved disabled feature flag value.
    public static let disabled = FeatureFlagValue(storage: .disabled)

    /// A resolved enabled feature flag value without a variant.
    public static let enabled = FeatureFlagValue(storage: .enabled)

    /// Creates a resolved enabled feature flag value with a string variant.
    ///
    /// - Parameter variant: The resolved variant value.
    /// - Returns: A feature flag value that evaluates as enabled and carries `variant`.
    public static func variant(_ variant: FeatureFlagVariant) -> FeatureFlagValue {
        FeatureFlagValue(storage: .variant(variant))
    }

    /// Whether this value evaluates as enabled.
    public var isEnabled: Bool {
        switch storage {
        case .disabled:
            false
        case .enabled, .variant:
            true
        }
    }

    /// The resolved variant, or `nil` when the value is disabled or enabled without a variant.
    public var variant: FeatureFlagVariant? {
        switch storage {
        case .disabled, .enabled:
            nil
        case .variant(let variant):
            variant
        }
    }
}
