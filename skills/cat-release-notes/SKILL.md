---
name: cat-release-notes
description: 'Drafts user-facing release notes from the commits between two git refs (default: the latest tag to HEAD), grouped by work item and change type. Use when asked for release notes, a changelog entry, "what changed since", or a summary of a release or sprint.'
---

# Release notes

1. **Range**: use the refs the user gives; otherwise the latest tag (`git describe --tags --abbrev=0`) to `HEAD`, or the whole history when there is no tag. State the range in the output.
2. **Collect**: `git log --no-merges --format="%h%x09%s%x09%b" {from}..{to}`. Group commits by the reference on their last line: a work item (`#<id>` or `AB#<id>`) or a plan (`plan-{N}`, alone or followed by `GOAL-###`); commits without one form their own group.
3. **Enrich** (optional): when the `azure-devops-cli` skill is available, fetch every work item's title and type in one batched query and prefer them over commit subjects. For a plan group, use the `goal` of its file under `docs/plans/` when there is one.
4. **Classify** each group as Breaking, New, Improved, or Fixed. Breaking means removed or renamed behavior, configuration, or API, a data migration, or a changed default. Drop internal-only changes (tests, refactors, CI, formatting, plan-file updates) unless the user asks for a technical changelog.
5. **Write** for users: one line per change saying what they can now do or what no longer goes wrong, in the product's vocabulary; no file names, class names, or commit hashes. End the line with its work item reference, if it has one.
6. **Output**: Markdown with only the sections that have entries, in the order Breaking, New, Improved, Fixed. If the repository has a `CHANGELOG.md`, match its format and ask before writing to it; otherwise reply in chat only.
