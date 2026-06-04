/// An error thrown while constructing a validated feature flag evaluator.
///
/// These errors describe core snapshot validation only. Provider, filesystem,
/// network, cache, analytics, and vendor failures are outside the v1 core API.
public enum FeatureFlagError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The snapshot contains semantically invalid feature flag data.
    ///
    /// This case is used for invalid key or variant text, such as empty values,
    /// overlong values, or values containing Unicode control scalars.
    case invalidSnapshot(String)

    /// The snapshot contains more than one entry for the same key.
    case duplicateFlag(FeatureFlagKey)

    /// A human-readable description of the validation error.
    public var description: String {
        switch self {
        case .invalidSnapshot(let message):
            "Invalid feature flag snapshot: \(message)"
        case .duplicateFlag(let key):
            "Duplicate feature flag: \(key.rawValue)"
        }
    }
}
