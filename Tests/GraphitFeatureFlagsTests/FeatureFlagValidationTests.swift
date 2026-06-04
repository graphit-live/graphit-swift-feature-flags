import GraphitFeatureFlags
import Testing

@Suite("FeatureFlagValidation")
struct FeatureFlagValidationTests {
    @Test func emptySnapshotsAreValidAndUseMissingDefaults() throws {
        let flags = try FeatureFlags([])
        let missingKey = FeatureFlagKey("missing")
        let defaultVariant = FeatureFlagVariant("control")

        #expect(flags.snapshot == FeatureFlagSnapshot([]))
        #expect(flags.value(for: missingKey) == nil)
        #expect(!flags.isEnabled(missingKey))
        #expect(flags.isEnabled(missingKey, default: true))
        #expect(flags.variant(for: missingKey) == nil)
        #expect(flags.variant(for: missingKey, default: defaultVariant) == defaultVariant)
    }

    @Test func duplicateValidKeysAreRejected() {
        let key = FeatureFlagKey("new-home")

        let error = thrownError {
            _ = try FeatureFlags([
                .enabled(key),
                .disabled(key)
            ])
        }

        #expect(isDuplicateFlagError(error, key: key))
    }

    @Test func invalidKeysAreRejectedDuringEvaluatorConstruction() {
        let invalidKeys = [
            FeatureFlagKey(""),
            FeatureFlagKey(String(repeating: "k", count: 257)),
            FeatureFlagKey("bad\u{0000}key"),
            FeatureFlagKey("bad\u{001F}key"),
            FeatureFlagKey("bad\u{007F}key"),
            FeatureFlagKey("bad\u{0085}key")
        ]

        for key in invalidKeys {
            let error = thrownError {
                _ = try FeatureFlags([.enabled(key)])
            }

            #expect(isInvalidSnapshotError(error))
        }
    }

    @Test func invalidVariantsAreRejectedDuringEvaluatorConstruction() {
        let key = FeatureFlagKey("experiment")
        let invalidVariants = [
            FeatureFlagVariant(""),
            FeatureFlagVariant(String(repeating: "v", count: 257)),
            FeatureFlagVariant("bad\u{0000}variant"),
            FeatureFlagVariant("bad\u{001F}variant"),
            FeatureFlagVariant("bad\u{007F}variant"),
            FeatureFlagVariant("bad\u{009F}variant")
        ]

        for variant in invalidVariants {
            let error = thrownError {
                _ = try FeatureFlags([.variant(key, variant)])
            }

            #expect(isInvalidSnapshotError(error))
        }
    }

    @Test func maximumLengthKeyAndVariantAreAccepted() throws {
        let key = FeatureFlagKey(String(repeating: "k", count: 256))
        let variant = FeatureFlagVariant(String(repeating: "v", count: 256))

        let flags = try FeatureFlags([.variant(key, variant)])

        #expect(flags.value(for: key) == .variant(variant))
    }

    @Test func invalidTextOnCurrentEntryTakesPrecedenceOverDuplicateDetection() {
        let key = FeatureFlagKey("experiment")

        let error = thrownError {
            _ = try FeatureFlags([
                .enabled(key),
                .variant(key, FeatureFlagVariant(""))
            ])
        }

        #expect(isInvalidSnapshotError(error))
    }

    @Test func errorDescriptionsAreHumanReadable() {
        let duplicateKey = FeatureFlagKey("new-home")

        #expect(FeatureFlagError.invalidSnapshot("Feature flag key must not be empty.").description.contains(
            "Invalid feature flag snapshot"
        ))
        #expect(FeatureFlagError.invalidSnapshot("Feature flag key must not be empty.").description.contains(
            "must not be empty"
        ))
        #expect(FeatureFlagError.duplicateFlag(duplicateKey).description.contains("Duplicate feature flag"))
        #expect(FeatureFlagError.duplicateFlag(duplicateKey).description.contains("new-home"))
    }
}

private func thrownError(_ body: () throws -> Void) -> (any Error)? {
    do {
        try body()
        return nil
    } catch {
        return error
    }
}

private func isInvalidSnapshotError(_ error: (any Error)?) -> Bool {
    guard let featureFlagError = error as? FeatureFlagError else {
        return false
    }

    if case .invalidSnapshot = featureFlagError {
        return true
    }

    return false
}

private func isDuplicateFlagError(_ error: (any Error)?, key expectedKey: FeatureFlagKey) -> Bool {
    guard let featureFlagError = error as? FeatureFlagError else {
        return false
    }

    if case .duplicateFlag(let key) = featureFlagError {
        return key == expectedKey
    }

    return false
}
