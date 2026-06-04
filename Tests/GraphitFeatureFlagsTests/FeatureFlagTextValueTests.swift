import Foundation
import GraphitFeatureFlags
import Testing

@Suite("FeatureFlagTextValue")
struct FeatureFlagTextValueTests {
    @Test func keyRawValueDescriptionEqualityAndHashing() {
        let key = FeatureFlagKey("new-home")
        let sameKey = FeatureFlagKey(rawValue: "new-home")
        let otherKey = FeatureFlagKey("checkout-experiment")

        #expect(key.rawValue == "new-home")
        #expect(sameKey.rawValue == "new-home")
        #expect(key.description == "new-home")
        #expect(key == sameKey)
        #expect(key != otherKey)
        #expect(Set([key, sameKey, otherKey]).count == 2)
    }

    @Test func variantRawValueDescriptionEqualityAndHashing() {
        let variant = FeatureFlagVariant("treatment")
        let sameVariant = FeatureFlagVariant(rawValue: "treatment")
        let otherVariant = FeatureFlagVariant("control")

        #expect(variant.rawValue == "treatment")
        #expect(sameVariant.rawValue == "treatment")
        #expect(variant.description == "treatment")
        #expect(variant == sameVariant)
        #expect(variant != otherVariant)
        #expect(Set([variant, sameVariant, otherVariant]).count == 2)
    }

    @Test func keyCodableUsesSingleStringShape() throws {
        let encoded = try encodedJSONString(FeatureFlagKey("new-home"))
        #expect(encoded == #""new-home""#)

        let decoded = try JSONDecoder().decode(
            FeatureFlagKey.self,
            from: Data(#""checkout-experiment""#.utf8)
        )
        #expect(decoded == FeatureFlagKey("checkout-experiment"))
    }

    @Test func variantCodableUsesSingleStringShape() throws {
        let encoded = try encodedJSONString(FeatureFlagVariant("treatment"))
        #expect(encoded == #""treatment""#)

        let decoded = try JSONDecoder().decode(
            FeatureFlagVariant.self,
            from: Data(#""control""#.utf8)
        )
        #expect(decoded == FeatureFlagVariant("control"))
    }

    @Test func constructionAndDecodingDoNotValidateText() throws {
        let invalidTexts = [
            "",
            "bad\u{0000}value",
            String(repeating: "x", count: 257)
        ]

        for text in invalidTexts {
            #expect(FeatureFlagKey(text).rawValue == text)
            #expect(FeatureFlagVariant(text).rawValue == text)

            let encodedText = try JSONEncoder().encode(text)
            let decodedKey = try JSONDecoder().decode(FeatureFlagKey.self, from: encodedText)
            let decodedVariant = try JSONDecoder().decode(FeatureFlagVariant.self, from: encodedText)

            #expect(decodedKey.rawValue == text)
            #expect(decodedVariant.rawValue == text)
        }
    }
}

private func encodedJSONString<Value: Encodable>(_ value: Value) throws -> String {
    let data = try JSONEncoder().encode(value)
    return try #require(String(data: data, encoding: .utf8))
}
