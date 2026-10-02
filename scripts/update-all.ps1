<#
.SYNOPSIS
  Update the Copilot Agent Team and its external companion tools.
.DESCRIPTION
  Pulls the latest from this clone, copies the agents, instructions, skills, and hooks
  into your user profile, removes copies a rename superseded so the picker never lists
  two of the same agent, and updates playwright-cli, the azure-devops-cli skill, and
  graphify when their CLIs are installed. Run it from anywhere; it locates its own repo.
#>

# Native tools (git/npm/gh/uv) print progress to stderr; keep that from aborting the run.
$ErrorActionPreference = 'Continue'
$PSNativeCommandUseErrorActionPreference = $false

$repo    = Split-Path -Parent $PSScriptRoot
$copilot = Join-Path $HOME '.copilot'

function Copy-Instructions {
    param([string]$Dir)
    if (Test-Path $Dir) { Copy-Item "$repo\instructions\*.instructions.md" $Dir -Force -ErrorAction Stop }
}

Write-Host "==> Updating copilot-agent-team from $repo" -ForegroundColor Cyan

# 1. Pull the latest.
if (Test-Path (Join-Path $repo '.git')) {
    git -C $repo pull --ff-only
    if ($LASTEXITCODE -ne 0) { Write-Warning "git pull exited $LASTEXITCODE; continuing with the copy." }
} else {
    Write-Warning "No .git directory in $repo; skipping git pull."
}

# 2. Copy this repo's pieces into the user profile.
New-Item -ItemType Directory -Force "$copilot\agents", "$copilot\skills", "$copilot\hooks", "$copilot\instructions" | Out-Null
Copy-Item "$repo\agents\*.agent.md" "$copilot\agents" -Force -ErrorAction Stop
Copy-Item "$repo\skills\*" "$copilot\skills" -Recurse -Force -ErrorAction Stop
Copy-Item "$repo\hooks\git-guard\git-guard.ps1", "$repo\hooks\git-guard\git-guard.sh" "$copilot\hooks" -Force -ErrorAction Stop
# Refresh the global git-guard hook only if you opted into it.
if (Test-Path "$copilot\hooks\git-guard.json") { Copy-Item "$repo\hooks\git-guard\hooks.json" "$copilot\hooks\git-guard.json" -Force }
# Instructions: the CLI reads ~/.copilot/instructions; VS Code reads the profile's prompts folder.
Copy-Instructions "$copilot\instructions"
Copy-Instructions "$env:APPDATA\Code\User\prompts"
Copy-Instructions "$env:APPDATA\Code - Insiders\User\prompts"

# 3. Remove copies superseded by the cat- rename so the picker never lists two.
$old = 'code-reviewer','code-simplifier','csharp-engineer','debugger','implementation-planner',
       'mudblazor-engineer','plan-executor','pr-feedback-resolver','tdd-cycle','tdd-green',
       'tdd-red','tdd-refactor','work-item-planner'
foreach ($name in $old) { Remove-Item "$copilot\agents\$name.agent.md" -ErrorAction SilentlyContinue }
Remove-Item "$copilot\skills\release-notes" -Recurse -ErrorAction SilentlyContinue

# 4. Update external companion tools when their CLIs are present.
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install -g '@playwright/cli@latest'
    if (Get-Command playwright-cli -ErrorAction SilentlyContinue) { playwright-cli install --skills }
} else { Write-Warning "npm not found; skipping playwright-cli." }

if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh skills install github/awesome-copilot azure-devops-cli
} else { Write-Warning "GitHub CLI (gh) not found; skipping the azure-devops-cli skill." }

if (Get-Command uv -ErrorAction SilentlyContinue) {
    uv tool upgrade graphifyy
    if ($LASTEXITCODE -ne 0) { uv tool install graphifyy }
} else { Write-Warning "uv not found; skipping graphify." }

Write-Host "==> Done." -ForegroundColor Green
