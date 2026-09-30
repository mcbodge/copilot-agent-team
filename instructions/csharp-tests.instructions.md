---
description: 'C# test conventions, including the xUnit v3 cancellation-token rule (xUnit1051)'
applyTo: '**/*Tests/**/*.cs, **/*.Test/**/*.cs, **/*Tests.cs, **/*Test.cs'
---

# C# tests

- New or changed public behavior gets tests in the matching test project, mirroring class names (`CatDoor` -> `CatDoorTests`) and following its naming style.
- Match the test framework and assertion library already in use; reuse existing fixtures, builders, and helpers.
- One behavior per test, named for it; Arrange-Act-Assert; parameterize variations; no branching; no shared static state, so tests run in any order.
- Test through public APIs; assert specific values and edge cases; mock only external dependencies, never the code under test.
- Run the narrowest test first, then the affected project; collect coverage only when asked.

## xUnit v3 with warnings as errors (xUnit1051)
- Pass `TestContext.Current.CancellationToken` to every awaited call that accepts a `CancellationToken`, Arrange I/O included: `await File.WriteAllTextAsync(path, content, TestContext.Current.CancellationToken);`.
- When optional parameters precede the token, use a named argument: `SearchAsync("q", cancellationToken: TestContext.Current.CancellationToken)`. A positional token lands in the wrong slot (CS1503).
- For a raw-string argument, the token goes after the closing `"""`.
- `dotnet build <test project> --no-restore` lists every remaining site as `file(line,col)`.
