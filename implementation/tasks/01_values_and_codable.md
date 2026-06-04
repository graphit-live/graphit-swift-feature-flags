# Task 01 — Values and Codable

If implementation shifts from this task/spec, stop and align before continuing.

## Refs

- `implementation/02_public_api_contract.md`
- `implementation/03_validation_and_codable.md`
- `.agents/PUBLIC_API_DESIGN.md`
- `.agents/TESTING_QUALITY.md`

## Prereqs

- Task 00 done.

## Implement

Full behavior for:

- `FeatureFlagKey` raw value, description, `RawRepresentable`, `Hashable`, `Sendable`, and single-string `Codable`;
- `FeatureFlagVariant` raw value, description, `RawRepresentable`, `Hashable`, `Sendable`, and single-string `Codable`;
- `FeatureFlagValue` `.disabled`, `.enabled`, `.variant(_)`, projections, equality/hashability, `Sendable`, and compact bool/string `Codable`;
- `FeatureFlag` initializer and convenience factories;
- `FeatureFlagSnapshot` initializer and object-shaped `Codable`.

## Required decisions

- Key and variant construction/decoding do not validate.
- `FeatureFlagValue` has no public initializer.
- `FeatureFlagValue` is not a public enum.
- JSON string value decodes to `.variant(FeatureFlagVariant(string))` even when the string is semantically invalid; evaluator construction validates later.
- Unsupported `FeatureFlagValue` JSON shapes fail decoding.

## Do not implement

- `FeatureFlags` semantic validation beyond placeholders if already needed for compile;
- provider/loading/caching APIs;
- Foundation import in core;
- `ExpressibleByStringLiteral`;
- extra public conveniences.

## Tests

Add Swift Testing coverage for:

- text value raw value/description/equality/Codable string shape;
- value factories/projections/equality/Codable bool/string shapes;
- unsupported value Codable shapes;
- flag convenience factories;
- snapshot preserves flags and Codable object shape;
- decoded invalid text remains decodable before evaluator validation.

## Verify

```bash
swift build
swift test --filter FeatureFlagTextValue
swift test --filter FeatureFlagValue
swift test --filter FeatureFlagSnapshot
swift test --filter Codable
```

## Definition of done

- Public value behavior matches spec.
- Compact Codable shapes match spec.
- No semantic validation occurs during construction or decoding.
- No Foundation import in core.
