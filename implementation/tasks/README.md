# Task index

Each task is independently assignable after prerequisites. Required in every task: read `implementation/README.md`, `implementation/00_decisions.md`, relevant design docs, task file, and companion guides. If implementation shifts from task/spec, stop and align before continuing.

Minimal v1 scope: pure immutable snapshot evaluator. No providers, no caching, no persistence, no Foundation in core, no observation, no exposure tracking, no UI adapters, no globals, no tasks, no actors, no locks, no public testing product.

## Vertical order

0. Bootstrap package and API shell.
1. Values and Codable.
2. Evaluator validation and lookup.
3. Public docs and README audit.
4. Test hardening and release check.

Why this order: every slice proves user-visible behavior before adding private detail. The implementation should remain small enough to understand in minutes.
