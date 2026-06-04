# Task 02 — Evaluator validation and lookup

If implementation shifts from this task/spec, stop and align before continuing.

## Refs

- `implementation/02_public_api_contract.md`
- `implementation/03_validation_and_codable.md`
- `.agents/PUBLIC_API_DESIGN.md`
- `.agents/SWIFT_CONCURRENCY_6_3.md`
- `.agents/TESTING_QUALITY.md`

## Prereqs

- Task 01 done.

## Implement

- `FeatureFlags` immutable evaluator:
  - public `snapshot` source value;
  - private `[FeatureFlagKey: FeatureFlagValue]` lookup dictionary;
  - `init(snapshot:) throws`;
  - `init(_:) throws`;
  - `value(for:)`;
  - `isEnabled(_:default:)`;
  - `variant(for:default:)`.
- `FeatureFlagValidation` private/internal helper for:
  - key text validation;
  - variant text validation;
  - duplicate-key detection;
  - dictionary normalization.
- `FeatureFlagError.description` behavior.

## Required decisions

- Validate key text and variant text before duplicate detection for the current entry.
- Duplicate valid keys throw `FeatureFlagError.duplicateFlag`.
- Invalid text throws `FeatureFlagError.invalidSnapshot`.
- Empty snapshots are valid.
- Lookup keys are not validated and reads never throw.
- Reads perform no I/O, logging, tracking, task creation, clock reads, or mutation.
- `FeatureFlags` remains a plain immutable struct; no actor/lock/task.

## Tests

Add Swift Testing coverage for:

- successful construction from snapshot and array;
- duplicate key rejection;
- invalid key rejection;
- invalid variant rejection;
- agreed mixed-defect precedence where useful;
- empty evaluator lookup defaults;
- missing/default/disabled/enabled/variant lookup semantics;
- invalid lookup keys behave missing and do not throw;
- public `snapshot` equals the source snapshot.

## Verify

```bash
swift build
swift test --filter FeatureFlagsLookup
swift test --filter FeatureFlagValidation
swift test
```

## Definition of done

- Evaluator behavior matches `Spec.md` section 6.
- No side effects in reads.
- No concurrency primitives or unstructured tasks added.
- No Foundation import in core.
