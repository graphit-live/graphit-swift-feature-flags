/// A strongly typed identity for a resolved feature flag.
///
/// Use `FeatureFlagKey` constants instead of passing raw strings through your
/// application. Construction and decoding do not validate the text; semantic
/// validation happens when constructing a `FeatureFlags` evaluator.
///
/// Avoid putting secrets, tokens, private user data, or sensitive targeting
/// information in keys if your app logs or displays raw values.
public struct FeatureFlagKey: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    /// The caller-defined string identity for the flag.
    public let rawValue: String

    /// Creates a feature flag key from raw key text.
    ///
    /// This initializer does not validate `rawValue`. Invalid or duplicate keys
    /// are rejected only when constructing a `FeatureFlags` evaluator.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a feature flag key from raw key text.
    ///
    /// This initializer does not validate `rawValue`. Invalid or duplicate keys
    /// are rejected only when constructing a `FeatureFlags` evaluator.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The raw key text.
    public var description: String {
        rawValue
    }

    /// Decodes a feature flag key from a single string value.
    ///
    /// Decoding does not validate key text. Semantic validation happens when
    /// constructing a `FeatureFlags` evaluator.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    /// Encodes the key as a single string value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// A strongly typed string variant for a resolved feature flag value.
///
/// A variant has no package-defined semantics beyond being a string-backed
/// value. When a `FeatureFlagValue` contains a variant, that flag evaluates as
/// enabled. Construction and decoding do not validate the text; semantic
/// validation happens when constructing a `FeatureFlags` evaluator.
///
/// Avoid putting secrets, tokens, private user data, or sensitive targeting
/// information in variants if your app logs or displays raw values.
public struct FeatureFlagVariant: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible {
    /// The caller- or provider-defined string value for the variant.
    public let rawValue: String

    /// Creates a feature flag variant from raw variant text.
    ///
    /// This initializer does not validate `rawValue`. Invalid variants are
    /// rejected only when constructing a `FeatureFlags` evaluator.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a feature flag variant from raw variant text.
    ///
    /// This initializer does not validate `rawValue`. Invalid variants are
    /// rejected only when constructing a `FeatureFlags` evaluator.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The raw variant text.
    public var description: String {
        rawValue
    }

    /// Decodes a feature flag variant from a single string value.
    ///
    /// Decoding does not validate variant text. Semantic validation happens when
    /// constructing a `FeatureFlags` evaluator.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    /// Encodes the variant as a single string value.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
