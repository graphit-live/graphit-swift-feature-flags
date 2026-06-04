/// An error thrown while constructing a validated feature flag evaluator.
public enum FeatureFlagError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The snapshot contains semantically invalid feature flag data.
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
