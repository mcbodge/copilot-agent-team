#!/usr/bin/env bash
# Update the Copilot Agent Team and its external companion tools.
#
# Pulls the latest from this clone, copies the agents, instructions, skills, and hooks
# into your user profile, removes copies a rename superseded so the picker never lists
# two of the same agent, and updates playwright-cli, the azure-devops-cli skill, and
# graphify when their CLIs are installed. Run it from anywhere; it locates its own repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"
COPILOT="$HOME/.copilot"

echo "==> Updating copilot-agent-team from $REPO"

# 1. Pull the latest.
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" pull --ff-only || echo "git pull failed; continuing with the copy." >&2
else
  echo "No .git directory in $REPO; skipping git pull." >&2
fi

# 2. Copy this repo's pieces into the user profile.
mkdir -p "$COPILOT/agents" "$COPILOT/skills" "$COPILOT/hooks" "$COPILOT/instructions"
cp "$REPO"/agents/*.agent.md "$COPILOT/agents/"
cp -R "$REPO"/skills/* "$COPILOT/skills/"
cp "$REPO"/hooks/git-guard/git-guard.ps1 "$REPO"/hooks/git-guard/git-guard.sh "$COPILOT/hooks/"
chmod +x "$COPILOT/hooks/git-guard.sh"
cp "$REPO"/instructions/*.instructions.md "$COPILOT/instructions/"
# Refresh the global git-guard hook only if you opted into it.
if [ -f "$COPILOT/hooks/git-guard.json" ]; then
  cp "$REPO/hooks/git-guard/hooks.json" "$COPILOT/hooks/git-guard.json"
fi

# VS Code / Insiders user prompts (instructions with applyTo).
case "$(uname -s)" in
  Darwin) BASE="$HOME/Library/Application Support" ;;
  *)      BASE="$HOME/.config" ;;
esac
for dir in "$BASE/Code/User/prompts" "$BASE/Code - Insiders/User/prompts"; do
  if [ -d "$dir" ]; then cp "$REPO"/instructions/*.instructions.md "$dir/"; fi
done

# 3. Remove copies superseded by the cat- rename so the picker never lists two.
for name in code-reviewer code-simplifier csharp-engineer debugger implementation-planner \
            mudblazor-engineer plan-executor pr-feedback-resolver tdd-cycle tdd-green tdd-red \
            tdd-refactor work-item-planner; do
  rm -f "$COPILOT/agents/$name.agent.md"
done
rm -rf "$COPILOT/skills/release-notes"

# 4. Update external companion tools when their CLIs are present (best effort).
if command -v npm >/dev/null 2>&1; then
  npm install -g @playwright/cli@latest || echo "playwright-cli update failed." >&2
  if command -v playwright-cli >/dev/null 2>&1; then
    playwright-cli install --skills || true
  fi
else
  echo "npm not found; skipping playwright-cli." >&2
fi
if command -v gh >/dev/null 2>&1; then
  gh skills install github/awesome-copilot azure-devops-cli || echo "azure-devops-cli update failed." >&2
else
  echo "GitHub CLI (gh) not found; skipping the azure-devops-cli skill." >&2
fi
if command -v uv >/dev/null 2>&1; then
  uv tool upgrade graphifyy 2>/dev/null || uv tool install graphifyy || echo "graphify update failed." >&2
else
  echo "uv not found; skipping graphify." >&2
fi

echo "==> Done."
