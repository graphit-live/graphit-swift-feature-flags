import GraphitFeatureFlags
import Testing

@Suite("FeatureFlagsLookup")
struct FeatureFlagsLookupTests {
    @Test func constructsFromSnapshotAndExposesSourceSnapshot() throws {
        let snapshot = FeatureFlagSnapshot(sampleEntries)

        let flags = try FeatureFlags(snapshot: snapshot)

        #expect(flags.snapshot == snapshot)
        #expect(flags.value(for: SampleKeys.on) == .enabled)
    }

    @Test func constructsFromFlagArray() throws {
        let flags = try FeatureFlags(sampleEntries)

        #expect(flags.snapshot == FeatureFlagSnapshot(sampleEntries))
        #expect(flags.value(for: SampleKeys.off) == .disabled)
        #expect(flags.value(for: SampleKeys.experiment) == .variant(SampleVariants.treatment))
    }

    @Test func valueForReturnsStoredValueOrNilWhenMissing() throws {
        let flags = try sampleEvaluator()

        #expect(flags.value(for: SampleKeys.off) == .disabled)
        #expect(flags.value(for: SampleKeys.on) == .enabled)
        #expect(flags.value(for: SampleKeys.experiment) == .variant(SampleVariants.treatment))
        #expect(flags.value(for: SampleKeys.missing) == nil)
    }

    @Test func isEnabledUsesStoredMeaningOrMissingDefault() throws {
        let flags = try sampleEvaluator()

        #expect(!flags.isEnabled(SampleKeys.missing))
        #expect(flags.isEnabled(SampleKeys.missing, default: true))

        #expect(!flags.isEnabled(SampleKeys.off))
        #expect(!flags.isEnabled(SampleKeys.off, default: true))

        #expect(flags.isEnabled(SampleKeys.on))
        #expect(flags.isEnabled(SampleKeys.experiment))
    }

    @Test func variantForUsesVariantAndOnlyMissingDefault() throws {
        let flags = try sampleEvaluator()

        #expect(flags.variant(for: SampleKeys.missing) == nil)
        #expect(flags.variant(for: SampleKeys.missing, default: SampleVariants.control) == SampleVariants.control)

        #expect(flags.variant(for: SampleKeys.off) == nil)
        #expect(flags.variant(for: SampleKeys.off, default: SampleVariants.control) == nil)

        #expect(flags.variant(for: SampleKeys.on) == nil)
        #expect(flags.variant(for: SampleKeys.on, default: SampleVariants.control) == nil)

        #expect(flags.variant(for: SampleKeys.experiment) == SampleVariants.treatment)
        #expect(flags.variant(for: SampleKeys.experiment, default: SampleVariants.control) == SampleVariants.treatment)
    }

    @Test func invalidLookupKeysBehaveAsMissingAndDoNotThrow() throws {
        let flags = try sampleEvaluator()
        let invalidKeys = [
            FeatureFlagKey(""),
            FeatureFlagKey("bad\u{0000}key"),
            FeatureFlagKey(String(repeating: "x", count: 257))
        ]

        for key in invalidKeys {
            #expect(flags.value(for: key) == nil)
            #expect(flags.isEnabled(key, default: true))
            #expect(flags.variant(for: key, default: SampleVariants.control) == SampleVariants.control)
        }
    }
}

private enum SampleKeys {
    static let off = FeatureFlagKey("off")
    static let on = FeatureFlagKey("on")
    static let experiment = FeatureFlagKey("experiment")
    static let missing = FeatureFlagKey("missing")
}

private enum SampleVariants {
    static let treatment = FeatureFlagVariant("treatment")
    static let control = FeatureFlagVariant("control")
}

private let sampleEntries: [FeatureFlag] = [
    .disabled(SampleKeys.off),
    .enabled(SampleKeys.on),
    .variant(SampleKeys.experiment, SampleVariants.treatment)
]

private func sampleEvaluator() throws -> FeatureFlags {
    try FeatureFlags(sampleEntries)
}
