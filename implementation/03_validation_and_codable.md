# Validation and Codable

## Text validation

`FeatureFlags.init` validates all text needed by the evaluator.

Key validation:

- non-empty;
- length <= 256 characters;
- no NUL or Unicode control scalars.

Variant validation:

- non-empty;
- length <= 256 characters;
- no NUL or Unicode control scalars.

Control scalars should include C0 controls, DEL, and C1 controls:

```text
scalar.value <= 0x1F || scalar.value == 0x7F || (0x80...0x9F).contains(scalar.value)
```

Use `String.count` for the v1 character limit. Do not normalize, trim, lowercase, or otherwise rewrite caller data.

## Snapshot validation flow

`FeatureFlags.init(snapshot:)` should:

1. create an empty private dictionary `[FeatureFlagKey: FeatureFlagValue]`;
2. iterate `snapshot.flags` in source order;
3. validate the flag key text;
4. validate the variant text when the value has a variant;
5. reject duplicate keys;
6. store the key/value in the dictionary;
7. assign the original snapshot and normalized dictionary after validation succeeds.

`FeatureFlags.init(_:)` delegates through `FeatureFlagSnapshot` or the same validation helper.

## Error precedence

For snapshots with multiple simultaneous defects:

- invalid key or variant text throws `FeatureFlagError.invalidSnapshot` before duplicate-key reporting for that invalid flag;
- duplicate keys throw `FeatureFlagError.duplicateFlag` when all text for the duplicate entries being considered is valid.

Tests should not rely on incidental details beyond this rule.

## Evaluation semantics

For a stored value:

- `.disabled` means `isEnabled == false` and no variant;
- `.enabled` means `isEnabled == true` and no variant;
- `.variant(x)` means `isEnabled == true` and variant `x`.

Missing lookup:

- `value(for:)` returns `nil`;
- `isEnabled(_:default:)` returns the provided default, defaulting to `false`;
- `variant(for:default:)` returns the provided default, defaulting to `nil`.

Explicit stored values override variant defaults:

- explicit `.disabled` returns `nil` from `variant(for:default:)`;
- explicit `.enabled` returns `nil` from `variant(for:default:)`;
- only a missing key returns the default variant.

Lookup keys are not validated and reads never throw.

## Codable shapes

### Key and variant

Encode/decode as single-value strings:

```json
"new-home"
"treatment"
```

Do not use synthesized raw-value object shapes.

### Value

Encode/decode as a single-value bool or string:

```json
false
true
"treatment"
```

Meaning:

- `false` -> `.disabled`;
- `true` -> `.enabled`;
- string -> `.variant(FeatureFlagVariant(string))`.

Unsupported value shapes:

- `null`;
- numbers;
- arrays;
- objects.

Variant strings decoded through `FeatureFlagValue` are not semantically validated until `FeatureFlags` construction.

### Flag

Use object shape:

```json
{ "key": "new-home", "value": true }
```

### Snapshot

Use object shape:

```json
{
  "flags": [
    { "key": "new-home", "value": true },
    { "key": "legacy-checkout", "value": false },
    { "key": "checkout-experiment", "value": "treatment" }
  ]
}
```

## Implementation notes

- Keep custom `Codable` implementations tiny and local to the relevant type.
- `FeatureFlagValue` may use a private nested enum or private storage value; do not expose the representation.
- Error messages should help diagnose invalid snapshots, but tests should primarily assert error cases rather than full strings.
- No Foundation APIs are needed for core Codable implementations.
