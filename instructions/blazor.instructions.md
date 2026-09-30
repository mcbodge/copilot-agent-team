---
description: 'Blazor Server and MudBlazor UI conventions'
applyTo: '**/*.razor, **/*.razor.cs, **/*.razor.css'
---

# Blazor and MudBlazor

- **MudBlazor APIs**: confirm component parameters, events, and enum values with the `mudblazor` MCP server before writing markup. If it isn't available, say so; never invent an API.
- **Thin components**: business rules, persistence, queries, and permission decisions belong in the application, domain, or infrastructure layers.
- **DbContext safety**: a Blazor Server circuit is long-lived and can run handlers concurrently, so never share one `DbContext` across concurrent operations. Dispatch through the repository's scoped request pattern (for example a scoped mediator) or create short-lived contexts with `IDbContextFactory<T>`.
- **Authorization**: use the repository's permission constants and policy names in `AuthorizeView` and `[Authorize]`; server-side checks stay authoritative.
- **Workflow states**: handle loading, disabled, validation, empty, error, and success states.
- **Markup**: MudBlazor components over custom HTML and CSS; CSS isolation (`.razor.css`) when styling is unavoidable; `@key` in loops, `Virtualize` for large lists; dispose subscriptions and timers.
- **Safety**: no secrets in components; `MarkupString` only for trusted content.
