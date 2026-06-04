/// A strongly typed identity for a resolved feature flag.
public struct FeatureFlagKey: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    /// The caller-defined string identity for the flag.
    public let rawValue: String

    /// Creates a feature flag key from raw key text.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a feature flag key from raw key text.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The raw key text.
    public var description: String {
        rawValue
    }
}

/// A strongly typed string variant for a resolved feature flag value.
public struct FeatureFlagVariant: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    /// The caller- or provider-defined string value for the variant.
    public let rawValue: String

    /// Creates a feature flag variant from raw variant text.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a feature flag variant from raw variant text.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The raw variant text.
    public var description: String {
        rawValue
    }
}
