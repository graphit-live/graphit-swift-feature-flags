import Foundation
import GraphitFeatureFlags
import Testing

@Suite("FeatureFlagValue")
struct FeatureFlagValueTests {
    @Test func factoriesAndProjectionsExposeResolvedMeaning() {
        let treatment = FeatureFlagVariant("treatment")
        let variantValue = FeatureFlagValue.variant(treatment)

        #expect(!FeatureFlagValue.disabled.isEnabled)
        #expect(FeatureFlagValue.enabled.isEnabled)
        #expect(variantValue.isEnabled)

        #expect(FeatureFlagValue.disabled.variant == nil)
        #expect(FeatureFlagValue.enabled.variant == nil)
        #expect(variantValue.variant == treatment)
    }

    @Test func equalityAndHashingUseResolvedValue() {
        let treatment = FeatureFlagVariant("treatment")
        let sameTreatment = FeatureFlagVariant(rawValue: "treatment")
        let control = FeatureFlagVariant("control")

        #expect(FeatureFlagValue.disabled == FeatureFlagValue.disabled)
        #expect(FeatureFlagValue.enabled == FeatureFlagValue.enabled)
        #expect(FeatureFlagValue.disabled != FeatureFlagValue.enabled)
        #expect(FeatureFlagValue.variant(treatment) == FeatureFlagValue.variant(sameTreatment))
        #expect(FeatureFlagValue.variant(treatment) != FeatureFlagValue.variant(control))

        let values: Set<FeatureFlagValue> = [
            .disabled,
            .disabled,
            .enabled,
            .variant(treatment),
            .variant(sameTreatment),
            .variant(control)
        ]
        #expect(values.count == 4)
    }

    @Test func valueCodableUsesCompactBoolAndStringShapes() throws {
        #expect(try encodedJSONString(FeatureFlagValue.disabled) == "false")
        #expect(try encodedJSONString(FeatureFlagValue.enabled) == "true")
        #expect(try encodedJSONString(FeatureFlagValue.variant(FeatureFlagVariant("treatment"))) == #""treatment""#)

        let disabled = try JSONDecoder().decode(FeatureFlagValue.self, from: Data("false".utf8))
        let enabled = try JSONDecoder().decode(FeatureFlagValue.self, from: Data("true".utf8))
        let variant = try JSONDecoder().decode(
            FeatureFlagValue.self,
            from: Data(#""treatment""#.utf8)
        )

        #expect(disabled == .disabled)
        #expect(enabled == .enabled)
        #expect(variant == .variant(FeatureFlagVariant("treatment")))
    }

    @Test func stringValueDecodingDoesNotValidateVariantText() throws {
        let emptyVariant = try JSONDecoder().decode(FeatureFlagValue.self, from: Data("\"\"".utf8))
        let controlVariant = try JSONDecoder().decode(
            FeatureFlagValue.self,
            from: Data(#""bad\u0000value""#.utf8)
        )

        #expect(emptyVariant == .variant(FeatureFlagVariant("")))
        #expect(controlVariant == .variant(FeatureFlagVariant("bad\u{0000}value")))
    }

    @Test func unsupportedValueCodableShapesFail() {
        let unsupportedJSON = [
            "null",
            "0",
            "1",
            "[]",
            "{}",
            #"{"rawValue":"treatment"}"#
        ]

        for json in unsupportedJSON {
            var didThrow = false

            do {
                _ = try JSONDecoder().decode(FeatureFlagValue.self, from: Data(json.utf8))
            } catch {
                didThrow = true
            }

            #expect(didThrow)
        }
    }
}

private func encodedJSONString<Value: Encodable>(_ value: Value) throws -> String {
    let data = try JSONEncoder().encode(value)
    return try #require(String(data: data, encoding: .utf8))
}
