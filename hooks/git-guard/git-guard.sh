#!/bin/sh
# git-guard: PreToolUse hook that denies force pushes and bulk staging in terminal commands.
cmd=$(sed -E -n 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -n 1)
[ -n "$cmd" ] || exit 0

# Quoted text (commit messages, echo) can't trigger a rule; JSON-escaped newlines separate commands.
cmd=$(printf '%s' "$cmd" | sed -e 's/\\"[^"]*\\"//g' -e "s/'[^']*'//g" -e 's/\\n/;/g')

git='(^|[[:space:];&|(])git(\.exe)?([[:space:]]+(-C[[:space:]]+[^[:space:]]+|-c[[:space:]]+[^[:space:]]+|--[[:alnum:]-]+(=[^[:space:]]+)?))*[[:space:]]+'
tail='[^;&|]*[[:space:]]'
end='([[:space:];&|)]|$)'

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"git-guard: %s","additionalContext":"Stage the files you changed by explicit path (git add <path>) and push without --force. If a force push is really needed, ask the user to run it."}}\n' "$1"
  exit 0
}

matches() { printf '%s\n' "$cmd" | grep -Eq "$1"; }

matches "${git}push${tail}(--force|-[[:alpha:]]*f|\\+[^[:space:]])" && deny 'force push rewrites shared history.'
matches "${git}add${tail}(--all|--update|-[[:alpha:]]*[Au][[:alpha:]]*|\\.|:/)${end}" && deny 'bulk staging can commit unrelated files.'
matches "${git}commit${tail}(--all|-[[:alpha:]]*a[[:alpha:]]*)${end}" && deny 'git commit -a stages every tracked change.'
exit 0
