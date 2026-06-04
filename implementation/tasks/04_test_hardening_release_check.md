# Task 04 — Test hardening and release check

If implementation shifts from this task/spec, stop and align before continuing.

## Refs

- `implementation/04_testing_strategy.md`
- `.agents/TESTING_QUALITY.md`
- `.agents/SWIFT_CONCURRENCY_6_3.md`
- `.agents/PACKAGE_RELEASE.md`

## Prereqs

- Implementation feature-complete.

## Implement/check

- Remove low-value duplicate tests.
- Add missing high-signal tests from `implementation/04_testing_strategy.md`.
- Audit public API for accidental deferred types, protocols, helpers, or conveniences.
- Audit imports to ensure `Sources/GraphitFeatureFlags` does not import Foundation or platform/vendor packages.
- Audit for accidental globals, singleton state, tasks, actors, locks, service locators, property wrappers, macros, dynamic member lookup, provider seams, or cache APIs.
- Run debug and release builds.

## Quality gates

- deterministic tests;
- no real network;
- no filesystem dependency beyond normal package/test execution;
- tests parallel-safe by default;
- failures assert public behavior;
- no concurrency warnings;
- no public API outside `Spec.md` without explicit alignment.

## Verify

```bash
swift package describe
swift build
swift build -c release
swift test
swift test --parallel
```

If `swift test --parallel` exposes a real issue, fix test isolation; do not serialize the whole suite without alignment.

## Definition of done

- Meaningful coverage of handwritten core behavior.
- No concurrency warnings.
- Public API remains exactly seven core types.
- Known untested risks documented as follow-up.
- Test count justified by regression value, not coverage vanity.
