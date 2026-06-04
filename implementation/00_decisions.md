# Locked decisions — minimal v1

Change process: if implementation conflicts with this file or `Spec.md`, stop and align. Do not silently drift.

## Product scope

- Implement `Spec.md` Draft 6 minimal snapshot v1.
- V1 is a pure immutable resolved-snapshot evaluator.
- Core evaluates already-resolved flag values only.
- Apps and future provider packages own loading, fetching, caching, persistence, identity, refresh, stale fallback, exposure tracking, and analytics.
- Official product focus: iOS 18+.
- Package also supports macOS 15+ for SwiftPM builds/tests and Mac app use.
- No Linux support claim in v1.
- No third-party Swift packages.
- Core target source imports Swift standard library only. Do not import Foundation in `Sources/GraphitFeatureFlags`.
- Tests, README examples, and future provider packages may import Foundation to encode/decode bytes or load resources.
- No GraphitCache dependency in v1.

## Public surface

The v1 public SDK surface is exactly these seven public types:

1. `FeatureFlagKey`
2. `FeatureFlagVariant`
3. `FeatureFlagValue`
4. `FeatureFlag`
5. `FeatureFlagSnapshot`
6. `FeatureFlags`
7. `FeatureFlagError`

Do not add extra public types, public protocols, public helpers, public testing products, public adapters, or public convenience namespaces unless the v1 contract is explicitly re-reviewed.

Static member conveniences specified on existing public types are allowed:

- `FeatureFlagValue.disabled`
- `FeatureFlagValue.enabled`
- `FeatureFlagValue.variant(_:)`
- `FeatureFlag.disabled(_:)`
- `FeatureFlag.enabled(_:)`
- `FeatureFlag.variant(_:_:)`

## Package

- SwiftPM source package.
- Swift tools version: 6.3.
- Swift language mode: 6.
- Public product: `GraphitFeatureFlags` only.
- Targets: `GraphitFeatureFlags`, `GraphitFeatureFlagsTests`.
- Platforms: `.iOS(.v18)`, `.macOS(.v15)`.
- No linker settings.
- No resources required in v1.

## Implementation posture

Build in small vertical behavior slices:

1. package and compile-ready public API shell;
2. public values and compact Codable behavior;
3. evaluator validation and lookup semantics;
4. documentation and README audit;
5. release hardening.

Prefer plain structs, private helpers, and direct validation. Do not build abstraction layers before behavior needs them.

## Validation and error precedence

`FeatureFlags.init` validates text values before accepting them into the normalized lookup table.

For snapshots with multiple simultaneous defects:

- invalid key or variant text throws `FeatureFlagError.invalidSnapshot` before duplicate-key reporting for that invalid flag;
- duplicate keys throw `FeatureFlagError.duplicateFlag` when all text for the duplicate entries being considered is valid;
- tests should cover clear invalid-text and duplicate cases, and avoid over-specifying mixed-defect ordering beyond this rule.

Reason: text validity is the prerequisite for a normalized evaluator; duplicate detection is meaningful only for otherwise valid flag entries.

## Explicit non-behavior

Core does not:

- fetch or refresh flags;
- define provider protocols;
- define provider registries;
- import or wrap PostHog or any vendor;
- cache or persist snapshots;
- load files, bundles, URLs, resources, or `UserDefaults`;
- observe changes or stream updates;
- track exposure or log reads;
- evaluate targeting or rollout rules;
- own identity/user context;
- create tasks, actors, locks, or background work;
- provide globals, service locators, macros, property wrappers, dynamic member lookup, or task-local dependencies.

Reads are synchronous, nonthrowing, immutable, and side-effect-free.
