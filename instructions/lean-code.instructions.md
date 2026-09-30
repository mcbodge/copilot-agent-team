---
description: 'Lean coding: the smallest correct change, reuse before writing, no speculative code (adapted from Ponytail)'
applyTo: '**/*.cs, **/*.razor, **/*.ts, **/*.tsx, **/*.js, **/*.jsx, **/*.py, **/*.ps1, **/*.sh, **/*.sql'
---

# Lean code

Understand the problem first: read the task and the code it touches, and trace the real flow end to end. Then stop at the first rung that holds:
1. Does it need to be built at all?
2. Does this codebase already have it? Reuse the helper or pattern.
3. Do the standard library or the platform already do it?
4. Does an installed dependency already do it?
5. Only then write the minimum code that works.

- Fix bugs at the root: check every caller of the code you change and fix the shared code once, not one caller at a time.
- No abstractions, options, or extension points nobody asked for; no new dependency a few lines can replace; no boilerplate.
- Deletion over addition, boring over clever, fewest files possible. The shortest correct diff wins; the smallest change in the wrong place is a second bug.
- When two approaches cost the same, pick the one that handles edge cases correctly.
- A deliberate shortcut with a known limit (naive algorithm, coarse lock) gets a one-line comment naming the limit and the upgrade path.
- Never cut corners on understanding the problem, input validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything explicitly requested, or a test for non-trivial logic.
