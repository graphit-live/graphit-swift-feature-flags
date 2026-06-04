/// A resolved boolean or variant value for a feature flag.
///
/// Create values with `.disabled`, `.enabled`, or `.variant(_:)`. The type is
/// intentionally not a public enum so callers use the provided projections
/// instead of switching over storage details. A variant value always evaluates
/// as enabled.
public struct FeatureFlagValue: Hashable, Codable, Sendable {
    private enum Storage: Hashable, Sendable {
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
    ///
    /// Disabled values return `false`; enabled and variant values return `true`.
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

    /// Decodes a compact feature flag value from a Boolean or string value.
    ///
    /// Boolean `false` decodes as `.disabled`, Boolean `true` decodes as
    /// `.enabled`, and a string decodes as `.variant(FeatureFlagVariant(string))`.
    /// Variant text is not semantically validated during decoding.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self = boolValue ? .enabled : .disabled
            return
        }

        if let stringValue = try? container.decode(String.self) {
            self = .variant(FeatureFlagVariant(stringValue))
            return
        }

        throw DecodingError.typeMismatch(
            FeatureFlagValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected a Boolean or string feature flag value."
            )
        )
    }

    /// Encodes this value as a compact Boolean or string value.
    ///
    /// Disabled values encode as `false`, enabled values encode as `true`, and
    /// variant values encode as their variant string.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch storage {
        case .disabled:
            try container.encode(false)
        case .enabled:
            try container.encode(true)
        case .variant(let variant):
            try container.encode(variant)
        }
    }
}
