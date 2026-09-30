# git-guard: PreToolUse hook that denies force pushes and bulk staging in terminal commands.
$ErrorActionPreference = 'Stop'
try {
    $command = ([Console]::In.ReadToEnd() | ConvertFrom-Json).tool_input.command
} catch {
    exit 0
}
if ($command -isnot [string]) { exit 0 }

# Quoted text (commit messages, echo) can't trigger a rule.
$scan = $command -replace '"[^"]*"|''[^'']*''', ''

$git = '(?:^|[\s;&|(])git(?:\.exe)?(?:\s+(?:-C\s+\S+|-c\s+\S+|--[\w-]+(?:=\S+)?))*\s+'
$tail = '[^;&|\r\n]*?\s'
$end = '(?=[\s;&|)]|$)'
$rules = [ordered]@{
    "${git}push$tail(?:--force|-[a-zA-Z]*f|\+\S)"                         = 'force push rewrites shared history.'
    "${git}add$tail(?:--all|--update|-[a-zA-Z]*[Au][a-zA-Z]*|\.|:/)$end" = 'bulk staging can commit unrelated files.'
    "${git}commit$tail(?:--all|-[a-zA-Z]*a[a-zA-Z]*)$end"                 = 'git commit -a stages every tracked change.'
}

foreach ($rule in $rules.GetEnumerator()) {
    if ($scan -cmatch $rule.Key) {
        @{
            hookSpecificOutput = @{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = "git-guard: $($rule.Value)"
                additionalContext        = 'Stage the files you changed by explicit path (git add <path>) and push without --force. If a force push is really needed, ask the user to run it.'
            }
        } | ConvertTo-Json -Compress -Depth 3
        exit 0
    }
}
exit 0
