import Foundation
import GraphitFeatureFlags
import Testing

@Suite("FeatureFlagSnapshot")
struct FeatureFlagSnapshotTests {
    @Test func flagInitializerStoresKeyAndValue() {
        let key = FeatureFlagKey("new-home")
        let flag = FeatureFlag(key: key, value: .enabled)

        #expect(flag.key == key)
        #expect(flag.value == .enabled)
    }

    @Test func flagConvenienceFactoriesCreateResolvedEntries() {
        let disabledKey = FeatureFlagKey("legacy-checkout")
        let enabledKey = FeatureFlagKey("new-home")
        let variantKey = FeatureFlagKey("checkout-experiment")
        let treatment = FeatureFlagVariant("treatment")

        #expect(FeatureFlag.disabled(disabledKey) == FeatureFlag(key: disabledKey, value: .disabled))
        #expect(FeatureFlag.enabled(enabledKey) == FeatureFlag(key: enabledKey, value: .enabled))
        #expect(FeatureFlag.variant(variantKey, treatment) == FeatureFlag(
            key: variantKey,
            value: .variant(treatment)
        ))
    }

    @Test func snapshotPreservesSourceOrderAndFlags() {
        let flags: [FeatureFlag] = [
            .enabled(FeatureFlagKey("new-home")),
            .disabled(FeatureFlagKey("legacy-checkout")),
            .variant(FeatureFlagKey("checkout-experiment"), FeatureFlagVariant("treatment"))
        ]

        let snapshot = FeatureFlagSnapshot(flags)

        #expect(snapshot.flags == flags)
    }

    @Test func snapshotCodableUsesObjectShape() throws {
        let snapshot = FeatureFlagSnapshot([
            .enabled(FeatureFlagKey("new-home")),
            .disabled(FeatureFlagKey("legacy-checkout")),
            .variant(FeatureFlagKey("checkout-experiment"), FeatureFlagVariant("treatment"))
        ])

        let encoded = try encodedJSONString(snapshot)
        #expect(encoded == #"{"flags":[{"key":"new-home","value":true},{"key":"legacy-checkout","value":false},{"key":"checkout-experiment","value":"treatment"}]}"#)

        let decoded = try JSONDecoder().decode(FeatureFlagSnapshot.self, from: Data(encoded.utf8))
        #expect(decoded == snapshot)
    }

    @Test func snapshotDecodingAllowsDuplicateKeysAndInvalidText() throws {
        let json = #"{"flags":[{"key":"","value":""},{"key":"","value":true},{"key":"bad\u0001key","value":"bad\u0000variant"}]}"#

        let snapshot = try JSONDecoder().decode(FeatureFlagSnapshot.self, from: Data(json.utf8))

        #expect(snapshot.flags.count == 3)
        #expect(snapshot.flags[0] == FeatureFlag(
            key: FeatureFlagKey(""),
            value: .variant(FeatureFlagVariant(""))
        ))
        #expect(snapshot.flags[1] == FeatureFlag(key: FeatureFlagKey(""), value: .enabled))
        #expect(snapshot.flags[2] == FeatureFlag(
            key: FeatureFlagKey("bad\u{0001}key"),
            value: .variant(FeatureFlagVariant("bad\u{0000}variant"))
        ))
    }
}

private func encodedJSONString<Value: Encodable>(_ value: Value) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    let data = try encoder.encode(value)
    return try #require(String(data: data, encoding: .utf8))
}
