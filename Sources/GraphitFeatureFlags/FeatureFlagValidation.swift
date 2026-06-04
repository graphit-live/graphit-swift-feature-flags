enum FeatureFlagValidation {
    private static let maximumTextLength = 256

    static func normalizedValues(
        from snapshot: FeatureFlagSnapshot
    ) throws -> [FeatureFlagKey: FeatureFlagValue] {
        var valuesByKey: [FeatureFlagKey: FeatureFlagValue] = [:]
        valuesByKey.reserveCapacity(snapshot.flags.count)

        for flag in snapshot.flags {
            try validateKey(flag.key)

            if let variant = flag.value.variant {
                try validateVariant(variant)
            }

            if valuesByKey[flag.key] != nil {
                throw FeatureFlagError.duplicateFlag(flag.key)
            }

            valuesByKey[flag.key] = flag.value
        }

        return valuesByKey
    }

    private static func validateKey(_ key: FeatureFlagKey) throws {
        try validateText(key.rawValue, fieldName: "Feature flag key")
    }

    private static func validateVariant(_ variant: FeatureFlagVariant) throws {
        try validateText(variant.rawValue, fieldName: "Feature flag variant")
    }

    private static func validateText(_ text: String, fieldName: String) throws {
        if text.isEmpty {
            throw FeatureFlagError.invalidSnapshot("\(fieldName) must not be empty.")
        }

        if text.count > maximumTextLength {
            throw FeatureFlagError.invalidSnapshot(
                "\(fieldName) must not exceed \(maximumTextLength) characters."
            )
        }

        if text.unicodeScalars.contains(where: isControlScalar) {
            throw FeatureFlagError.invalidSnapshot("\(fieldName) must not contain control characters.")
        }
    }

    private static func isControlScalar(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value <= 0x1F || scalar.value == 0x7F || (0x80...0x9F).contains(scalar.value)
    }
}
