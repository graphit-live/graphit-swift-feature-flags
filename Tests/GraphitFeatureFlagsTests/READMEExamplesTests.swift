import Foundation
import GraphitFeatureFlags
import Testing

@Suite("READMEExamples")
struct READMEExamplesTests {
    @Test func quickStartExampleCompilesAndEvaluates() throws {
        let flags = try FeatureFlags([
            .enabled(READMEAppFlags.newHome),
            .variant(READMEAppFlags.checkoutExperiment, FeatureFlagVariant("treatment"))
        ])

        #expect(flags.isEnabled(READMEAppFlags.newHome))
        #expect(flags.variant(for: READMEAppFlags.checkoutExperiment) == FeatureFlagVariant("treatment"))
    }

    @Test func codableSnapshotExampleCompilesAndEvaluates() throws {
        let json = #"""
        {
          "flags": [
            { "key": "new-home", "value": true },
            { "key": "legacy-checkout", "value": false },
            { "key": "checkout-experiment", "value": "treatment" }
          ]
        }
        """#

        let data = Data(json.utf8)
        let snapshot = try JSONDecoder().decode(FeatureFlagSnapshot.self, from: data)
        let flags = try FeatureFlags(snapshot: snapshot)

        #expect(flags.isEnabled(READMEAppFlags.newHome))
        #expect(!flags.isEnabled(READMEAppFlags.legacyCheckout, default: true))
        #expect(flags.variant(for: READMEAppFlags.checkoutExperiment) == FeatureFlagVariant("treatment"))
    }

    @Test func readmeMissingDisabledEnabledAndVariantSemanticsHold() throws {
        let flags = try FeatureFlags([
            .disabled(FeatureFlagKey("off")),
            .enabled(FeatureFlagKey("on")),
            .variant(FeatureFlagKey("experiment"), FeatureFlagVariant("treatment"))
        ])

        #expect(!flags.isEnabled(FeatureFlagKey("missing")))
        #expect(flags.isEnabled(FeatureFlagKey("missing"), default: true))
        #expect(!flags.isEnabled(FeatureFlagKey("off"), default: true))
        #expect(flags.isEnabled(FeatureFlagKey("on")))
        #expect(flags.isEnabled(FeatureFlagKey("experiment")))

        #expect(flags.variant(for: FeatureFlagKey("missing")) == nil)
        #expect(flags.variant(
            for: FeatureFlagKey("missing"),
            default: FeatureFlagVariant("control")
        ) == FeatureFlagVariant("control"))
        #expect(flags.variant(
            for: FeatureFlagKey("off"),
            default: FeatureFlagVariant("control")
        ) == nil)
        #expect(flags.variant(
            for: FeatureFlagKey("on"),
            default: FeatureFlagVariant("control")
        ) == nil)
        #expect(flags.variant(for: FeatureFlagKey("experiment")) == FeatureFlagVariant("treatment"))
    }

    @Test func replacingEvaluatorRepresentsUpdatedFlags() throws {
        let initialFlags = try FeatureFlags([
            .disabled(READMEAppFlags.newHome)
        ])
        let updatedFlags = try FeatureFlags([
            .enabled(READMEAppFlags.newHome)
        ])

        #expect(!initialFlags.isEnabled(READMEAppFlags.newHome))
        #expect(updatedFlags.isEnabled(READMEAppFlags.newHome))
    }
}

private enum READMEAppFlags {
    static let newHome = FeatureFlagKey("new-home")
    static let legacyCheckout = FeatureFlagKey("legacy-checkout")
    static let checkoutExperiment = FeatureFlagKey("checkout-experiment")
}
