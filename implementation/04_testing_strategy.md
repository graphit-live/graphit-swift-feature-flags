# Testing strategy

Goal: prove behavior that callers and maintainers care about. Avoid vanity coverage and implementation trivia.

## Frameworks

- Use Swift Testing for v1 behavior tests.
- Tests may import `Foundation` for `JSONEncoder`, `JSONDecoder`, and `Data`.
- No XCTest required in v1 unless a future benchmark lane is added.
- No sleeps, clocks, temp directories, mock frameworks, provider fakes, or public testing product are required for core v1.

## Suites

### Text value tests

Cover:

- `FeatureFlagKey` raw value, `RawRepresentable`, equality, hashing, description;
- `FeatureFlagVariant` raw value, `RawRepresentable`, equality, hashing, description;
- key and variant Codable single-string shape;
- construction/decoding does not validate empty or control-character strings.

### Value tests

Cover:

- `.disabled`, `.enabled`, and `.variant(_)` factories;
- `isEnabled` and `variant` projections;
- equality and hashing;
- compact Codable shapes: `false`, `true`, and string;
- unsupported value Codable shapes fail.

### Snapshot tests

Cover:

- `FeatureFlag` initializer and convenience factories;
- `FeatureFlagSnapshot` preserves source order and flags;
- snapshot Codable object shape;
- snapshot decoding allows duplicate keys and invalid text until evaluator construction.

### Evaluator lookup tests

Cover:

- successful evaluator construction from snapshot and array;
- `value(for:)` stored/missing semantics;
- `isEnabled(_:default:)` missing/default/disabled/enabled/variant semantics;
- `variant(for:default:)` missing/default/disabled/enabled/variant semantics;
- invalid lookup keys behave missing and do not throw;
- source `snapshot` is exposed unchanged.

### Validation tests

Cover:

- invalid key rejection during `FeatureFlags` construction;
- invalid variant rejection during `FeatureFlags` construction;
- duplicate valid key rejection;
- agreed mixed-defect precedence where useful;
- empty snapshots produce an evaluator with missing defaults.

### README examples tests

Cover:

- app-defined key constants compile;
- static snapshot example compiles and evaluates;
- Codable/static configuration example compiles using Foundation in tests, not core.

## Minimal verification commands

```bash
swift package describe
swift build
swift build -c release
swift test
```

Useful focused filters after tests exist:

```bash
swift test --filter FeatureFlagValue
swift test --filter FeatureFlagsLookup
swift test --filter Codable
swift test --filter Validation
```

## Quality bar per test

- Proves public behavior, not private implementation steps.
- Deterministic input and assertions.
- No real network or filesystem dependency beyond in-memory `Data` encoding/decoding.
- Parallel-safe by default.
- Clear failure assertions.
- Avoid exact error-message assertions unless message wording is intentionally part of a test scenario.

## Do not add

- protocols only for mocks;
- broad mock framework;
- provider fakes;
- temp-directory helpers;
- clocks;
- tests for hidden private dictionary shape;
- tests that require Foundation in core source.
