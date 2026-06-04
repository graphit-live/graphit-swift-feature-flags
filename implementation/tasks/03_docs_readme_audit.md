# Task 03 — Public docs and README audit

If implementation shifts from this task/spec, stop and align before continuing.

## Refs

- `implementation/02_public_api_contract.md`
- `implementation/05_deferred_features.md`
- `.agents/PUBLIC_API_DESIGN.md`
- `.agents/PACKAGE_RELEASE.md`

## Prereqs

- Public API behavior mostly complete.

## Implement

- Audit/add documentation comments for every public type and public member.
- Create or update root `README.md` with minimal user docs.
- Compile-check examples where practical through tests.

## README must mention

- Swift 6.3.x and Swift language mode 6.
- iOS 18+ primary support and macOS 15+ package support.
- No Linux support claim in v1.
- Core is a pure immutable resolved-snapshot evaluator.
- No providers, networking, fetching, caching, persistence, observation, exposure tracking, targeting, UI adapters, globals, property wrappers, macros, or dynamic member lookup.
- Core source does not import Foundation.
- Apps/provider packages own loading and may use `JSONDecoder`, files, `UserDefaults`, GraphitCache, or other storage outside core.
- Why `FeatureFlagKey` and `FeatureFlagVariant` are dedicated types instead of raw strings.
- Missing vs explicit disabled semantics.
- Variants imply enabled behavior.
- Updating flags means constructing a new `FeatureFlags` value and replacing it in app-owned state.
- Keys/variants should not contain secrets or sensitive data if apps log/display raw values.

## Do not implement

- provider APIs;
- GraphitCache integration;
- bundle/file loading helpers;
- observation or UI adapters;
- instrumentation/events;
- public testing helper product;
- public APIs beyond the seven v1 types.

## Verify

```bash
swift build
swift test
```

## Definition of done

- Every public symbol has a documentation comment.
- README matches implemented API and minimal-v1 decisions.
- Examples do not show deferred APIs.
- README examples are covered by compile tests where practical.
