# Deferred features and non-goals

Do not add placeholders for deferred features in v1. Public API should stay exactly the seven core types.

## Providers

Deferred:

- provider protocol;
- `FeatureFlagProvider`, `FeatureFlagSource`, `FeatureFlagClient`, or similar abstractions;
- provider registry;
- PostHog integration;
- static configuration provider package;
- custom backend client;
- network transport;
- retry/backoff;
- refresh cadence;
- identity/user context;
- stale/offline policy.

Reason: the common provider shape is not proven. Future provider packages can expose concrete snapshot loaders and map data into `FeatureFlagSnapshot`.

## Caching and persistence

Deferred:

- built-in caching;
- built-in persistence;
- GraphitCache dependency;
- `UserDefaults` helpers;
- file loading helpers;
- bundle/resource lookup helpers;
- stale snapshot policy;
- cache key naming policy.

Reason: cache behavior depends on provider identity, user context, offline behavior, privacy, storage constraints, and app lifecycle. Core values are `Codable`; apps and provider packages decide storage.

## Targeting and rule evaluation

Deferred:

- user traits/properties model;
- percentage rollout;
- bucketing/hash rollout;
- segment matching;
- prerequisite flags;
- environment matching;
- date windows;
- rule engine;
- evaluation reason/details API.

Reason: v1 evaluates already-resolved values.

## Observation and live updates

Deferred:

- mutable flag store;
- actor-backed state owner;
- async refresh API;
- observation streams;
- callbacks;
- Combine publishers;
- background refresh tasks;
- app lifecycle hooks.

Reason: apps replace a `FeatureFlags` value in app-owned state when new flags arrive.

## Exposure tracking and instrumentation

Deferred:

- exposure tracking;
- analytics event sink;
- impression events;
- evaluation callbacks;
- OSLog adapter;
- metrics hooks;
- automatic logging.

Reason: reads must have no side effects. Exposure tracking requires privacy, batching, delivery, retry, failure, deduplication, and lifecycle policy.

## UI and syntax sugar

Deferred:

- SwiftUI/UIKit/AppKit adapters;
- `ObservableObject` or Observation models;
- property wrappers;
- macros;
- dynamic member lookup;
- global environment lookups;
- process-wide singleton.

Reason: explicit evaluator values are boring and hard to misuse.

## Schema generation and typed conveniences

Deferred:

- generated flag schema API;
- macro-generated keys;
- string-literal key/variant conformance;
- public dictionary initializer;
- public all-flags dictionary view on `FeatureFlags`;
- typed variant enum machinery;
- public testing helper product.

Reason: apps can define simple key constants today. Generated schemas and typed variant helpers may be useful later, but should not become the human-facing API by accident.
