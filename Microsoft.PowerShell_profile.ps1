# ============================================================
#  Claude Code Workspace Profile — Refael
#  Full replacement for $PROFILE
#  Entry points: ccode (workspace), qline (quota line per project)
#  Skills come from the official plugin system (/plugin), not from here.
# ============================================================

# Protocol version. Bump this number whenever the template below
# changes. Any project whose CLAUDE.md carries an older or missing
# version gets upgraded automatically on next ccode.
# CHANGED v5 -> v6: LEDGER-archive.md restored as the single allowed
# exception to the 3-file rule. Archive stays fully out of context.
# NOTE: quota line added to the profile without a version bump. The
# CLAUDE.md template is unchanged, so no project rewrite is needed.
$script:ProtocolVersion = 6

# ------------------------------------------------------------
# 1. Global rules — ~/.claude/CLAUDE.md
# ------------------------------------------------------------
function Sync-ClaudeGlobalRules {
    $globalMd = "$env:USERPROFILE\.claude\CLAUDE.md"
    $rules = @'
# Global Rules — apply in every project, every session

## Writing Style
* No em dashes and no hyphens as stylistic separators in any prose, docs, or commit messages. Use commas or periods.
* No AI-typical phrasing: no "Certainly", "Great question", "Let's dive in", no summary closers, no hedging filler.
* Plain direct sentences. Short. No decorative transitions.

## Hebrew / RTL
* When responding in Hebrew, do not mix English words mid-sentence. Keep sentences purely Hebrew or purely English.
* Technical terms, file names, commands, and code identifiers go in backticks or on their own line, never inline inside a Hebrew sentence.
* Prefer full Hebrew sentences with code blocks separated below them.

## Documentation Language & Secrecy
* LEDGER.md and CLAUDE.md content is written in English only. No Hebrew inside these files.
* README.md is bilingual: full English section first, full Hebrew section below it.
* README.md must NEVER mention LEDGER.md, CLAUDE.md, the lifecycle protocol, or any AI workflow. It describes the project only, as if written by a human developer.

## Skills & Plugins
* Skills are installed as official plugins: superpowers, caveman, humanizer, everything-claude-code.
* Plugin commands may be namespaced, for example /humanizer:humanizer. Type / to list what is available.
* superpowers workflow entry point: /brainstorm
* After plugin changes: run /reload-plugins. Never install or update plugins on your own initiative.

## Git & GitHub
* If the current folder is not a git repository, initialize one and create a baseline commit before any work.
* GitHub MCP is available. Creating a remote repository via MCP is allowed when the user asks for it.
* Commit after every meaningful change with a descriptive message. Never batch commits at session end.
* Never add Co-Authored-By lines or any AI attribution to commit messages.
* Never push without an explicit instruction from the user.
'@
    New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude" | Out-Null
    Set-Content -Path $globalMd -Value $rules -Encoding UTF8
    Write-Host "[Global] ~/.claude/CLAUDE.md synced." -ForegroundColor Cyan
}

# ------------------------------------------------------------
# 2. Project state backup
#    LEDGER.md and CLAUDE.md are gitignored by design, so this is
#    their only safety net. Runs on every ccode, before anything
#    else touches the project, including rule 6 deletions.
# ------------------------------------------------------------
function Backup-ProjectState {
    $root = Get-Location
    $projectName = Split-Path $root -Leaf
    $backupDir = Join-Path "$env:USERPROFILE\.claude\backups" $projectName
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    # LEDGER.md and CLAUDE.md are the real targets. The last three are
    # NEVER created by this system: they are old-protocol leftovers that
    # rule 6 deletes after merging into LEDGER.md, so they get one final
    # backup here, right before that deletion.
    $targets = @("LEDGER.md", "LEDGER-archive.md", "CLAUDE.md", "STATUS.md", "PROGRESS.md", "DECISIONS.md")

    $copied = 0
    foreach ($f in $targets) {
        $src = Join-Path $root $f
        if (Test-Path $src) {
            New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
            Copy-Item $src (Join-Path $backupDir "$stamp-$f")
            $copied++
        }
    }
    if ($copied -eq 0) { return }

    # Rotation: keep the 20 most recent snapshots per project.
    $groups = Get-ChildItem $backupDir -File |
              Group-Object { $_.Name.Substring(0, 15) } |
              Sort-Object Name -Descending
    if ($groups.Count -gt 20) {
        $groups | Select-Object -Skip 20 | ForEach-Object {
            $_.Group | Remove-Item -Force
        }
    }
    Write-Host "[Backup] $copied state file(s) -> $backupDir" -ForegroundColor Cyan
}

# ------------------------------------------------------------
# 3. Git bootstrap — runs on every ccode, idempotent
# ------------------------------------------------------------
function Initialize-GitWorkspace {
    $root = Get-Location

    # Sentinel line '# ccode-managed' detects an old or partial block,
    # secrets patterns added so the baseline commit cannot grab them.
    $gitignorePath = Join-Path $root ".gitignore"
    $ignoreRules = @(
    	"# ccode-managed",
    	"# MD files stay local except README, versioned docs, and the governance record",
    	"*.md",
    	"!README.md",
    	"!docs/**/*.md",
    	"!LEDGER.md",
       	"",
    	"# Build artifacts",
    	"*.ex5",
    	"",
    	"# Secrets",
    	".env",
    	".env.*",
    	"*.pem",
    	"*.key",
    	"*.pfx",
    	"*.p12",
    	"secrets.*",
    	"credentials.*",
    	"",
    	"# Junk",
    	"__pycache__/",
    	"*.pyc",
    	".venv/",
    	"node_modules/",
    	"*.log",
    	"",
    	"# Owner profile backups of CLAUDE.md, local config residue",
    	"CLAUDE.md.bak*",
    	".claude/worktrees/",
    	".claude/settings.local.json"
    )
    if (-not (Test-Path $gitignorePath)) {
        Set-Content -Path $gitignorePath -Value ($ignoreRules -join "`n") -Encoding UTF8
        Write-Host "[Git] .gitignore created." -ForegroundColor Cyan
    } elseif (-not (Select-String -Path $gitignorePath -Pattern '^# ccode-managed$' -Quiet)) {
        Add-Content -Path $gitignorePath -Value ("`n" + ($ignoreRules -join "`n"))
        Write-Host "[Git] .gitignore updated to managed block." -ForegroundColor Cyan
    }

    if (-not (Test-Path (Join-Path $root ".git"))) {
        git init | Out-Null
        Write-Host "[Git] Repository initialized." -ForegroundColor Cyan
    }

    $hooksDir = git rev-parse --git-path hooks 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $hooksDir) { $hooksDir = Join-Path $root ".git\hooks" }
    # git returns a relative path here. Root it, .NET file APIs resolve relative
    # paths against the process cwd, not the PowerShell location.
    if (-not [System.IO.Path]::IsPathRooted($hooksDir)) { $hooksDir = Join-Path $root $hooksDir }
    New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null
    $hookPath = Join-Path $hooksDir "commit-msg"
    $hookLines = @(
        '#!/bin/sh',
        "sed -i -e '/Co-Authored-By: Claude/Id' \",
        "       -e '/Co-Authored-By:.*noreply@anthropic.com/Id' \",
        "       -e '/Generated with \[Claude Code\]/Id' \",
        "       -e '/Generated with Claude Code/Id' `"`$1`"",
        "exit 0"
    )
    $hookScript = ($hookLines -join "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($hookPath, $hookScript, $utf8NoBom)

    # Git silently skips a hook without the executable bit, set it (best effort)
    try {
        $bashCmd = Get-Command bash.exe -ErrorAction SilentlyContinue
        if ($bashCmd) {
            & $bashCmd.Source -c "chmod +x '$($hookPath -replace '\\', '/')'" 2>$null
        }
    } catch { }

    # Verify the hook really strips trailers, through git's own dispatcher.
    # Needs git 2.36 or newer for 'git hook run'.
    $null = (git --version) -match '(\d+)\.(\d+)'
    $hookRunAvailable = ([int]$Matches[1] -gt 2) -or ([int]$Matches[1] -eq 2 -and [int]$Matches[2] -ge 36)
    if ($hookRunAvailable) {
        $probePath = Join-Path $env:TEMP ("commit-msg-probe-" + [guid]::NewGuid().ToString('N') + ".txt")
        $probeLines = @(
            "test: hook verification",
            "",
            "🤖 Generated with [Claude Code](https://claude.com/claude-code)",
            "",
            "Co-Authored-By: Claude <noreply@anthropic.com>"
        )
        [System.IO.File]::WriteAllText($probePath, ($probeLines -join "`n") + "`n", $utf8NoBom)
        $hookOutput = git hook run commit-msg -- $probePath 2>&1
        $probeAfter = [System.IO.File]::ReadAllText($probePath)
        Remove-Item $probePath -Force -ErrorAction SilentlyContinue
        if ($probeAfter -notmatch 'Co-Authored-By' -and $probeAfter -notmatch 'Generated with') {
            Write-Host "[Git] commit-msg hook verified, trailers stripped." -ForegroundColor Green
        } else {
            Write-Host "[Git] WARNING: commit-msg hook did not strip trailers." -ForegroundColor Red
            if ($hookOutput) { Write-Host "[Git] git output: $($hookOutput -join ' ')" -ForegroundColor Red }
        }
    } else {
        Write-Host "[Git] git older than 2.36, 'git hook run' unavailable, verification skipped." -ForegroundColor Cyan
    }

    git rev-parse HEAD 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        git add -A

        # Staged-secrets safety net for the baseline commit. Catches
        # what .gitignore missed, for example an already-existing id_rsa.
        $staged = git diff --cached --name-only
        $suspicious = @($staged | Where-Object {
            $_ -match '(^|/)\.env($|\.)' -or
            $_ -match '\.(pem|key|pfx|p12)$' -or
            $_ -match 'id_rsa|id_ed25519|id_ecdsa' -or
            $_ -match 'secret|credential'
        })
        if ($suspicious.Count -gt 0) {
            foreach ($f in $suspicious) { git reset -q -- $f }
            Write-Host "[Git] WARNING: excluded from baseline commit (possible secrets):" -ForegroundColor Red
            $suspicious | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
            Write-Host "[Git] Review them. Add manually only if they are safe." -ForegroundColor Red
        }

        git commit -m "baseline: initial snapshot of workspace" | Out-Null
        Write-Host "[Git] Baseline commit created." -ForegroundColor Green
    } else {
        $dirty = git status --porcelain
        if ($dirty) {
            Write-Host "[Git] Uncommitted changes:" -ForegroundColor Yellow
            git status --short
        } else {
            Write-Host "[Git] Clean. HEAD: $(git log -1 --format='%h %s')" -ForegroundColor Green
        }
    }
}

# ------------------------------------------------------------
# 4. Project template (single source of truth for CLAUDE.md)
# ------------------------------------------------------------
function Get-ClaudeProjectTemplate {
    $t = @'
<!-- PROTOCOL_VERSION: __VER__ -->
You operate under a strict, file-based lifecycle management protocol. There are exactly 2 management files: `README.md` and `LEDGER.md`. You must enforce them as your absolute roadmap and source of truth.

Exactly 3 markdown files exist in the workspace root: `README.md`, `LEDGER.md`, and this `CLAUDE.md`. Single allowed exception: `LEDGER-archive.md`, created automatically the first time an entry is archived. Never create any other markdown file, in the root or anywhere else, unless the user explicitly asks for one.

Global persona, writing style, Hebrew/RTL rules, skills, and git discipline are defined in ~/.claude/CLAUDE.md and always apply. Do not duplicate them here.

## Execution Rules:

1. **Bootstrap on Demand:** Upon initialization, scan the workspace root. If `README.md` or `LEDGER.md` is missing, create it immediately using the exact structure defined below.
2. **Context Alignment:** Before writing any code, modifying files, or answering queries, read `LEDGER.md` in full to align with the current architecture, open issues, and locked decisions. Never read `LEDGER-archive.md` unless the user asks about old history.
3. **Automated Synchronization:** Update `LEDGER.md` autonomously at the end of every task or interaction, without being asked:
   * **New problem / blocker discovered:** add an entry to the ISSUES section.
   * **Task completed / code changed:** move or add the entry under the ACTIONS section with a date.
   * **Architectural choice made or path rejected:** add a locked entry to the DECISIONS section.
   * **Global stack / direction change:** update `README.md`.
4. **Language & Secrecy:** LEDGER.md is written in English only. README.md is bilingual, full English section first, full Hebrew section below it. README.md must never reference LEDGER.md, this protocol, or any AI involvement. It reads as a standard human-written project readme.
5. **Decision Permanence:** Entries in the DECISIONS section marked FINAL are locked. Never re-suggest, reopen, or argue against them in any future session. Single exception: the human user may reopen a FINAL entry by explicitly writing `unlock decision` together with the entry name. Only a direct user instruction counts. Never suggest, hint at, or initiate an unlock yourself.
6. **Legacy Migration:** If `STATUS.md`, `PROGRESS.md`, or `DECISIONS.md` exist in the workspace root, consolidate their full content into `LEDGER.md` under the matching sections, translate any Hebrew to English, preserve every FINAL decision, then delete the three legacy files. Do this once, immediately, before any other work.

Do not wait for explicit permission or a separate command to update the state. Maintain this loop seamlessly in the background across all terminal operations.

# LEDGER.md — single management file, three sections, entry format is the 3-line Protocol:

```
Issue:  [what / why]
Action: [what was done or what is planned]
Status: [OPEN | IN PROGRESS | DONE | BLOCKED | FINAL]
```

## Section 1: ISSUES (current state)
* Everything open right now: bugs, blockers, things waiting on someone, items needing review
* The next best action always sits at the top of this section
* Entries move to ACTIONS when resolved
* Lets a new session restart without scrolling through old chats

## Section 2: ACTIONS (dated log)
* Chronological record, newest first, each entry dated YYYY-MM-DD
* What was worked on, what changed, what was tried, what worked and what did not
* Never edited retroactively, append only
* Entries older than 90 days are condensed to one line each, `YYYY-MM-DD | what was done | outcome`, and moved to `LEDGER-archive.md`. Perform this silently as part of regular ledger updates. FINAL decisions are never archived, they stay in DECISIONS forever.

## Section 3: DECISIONS (locked log)
* Decisions already made, the reasoning, and the options rejected
* Each entry marked FINAL or REVISIT
* FINAL entries are permanently closed, never reopened by any AI in any session
* Keeps the project from going in circles across different AI chats

---

# README.md
* Explains what the project is, who it is for, why it matters
* Stores background context that does not change every session: links, references, constraints, examples
* Should only change when the bigger project direction changes
* Bilingual: full English section first, then a full Hebrew section
* Never mentions LEDGER.md, this protocol, or AI. Standard human-written readme only.
'@
    return $t.Replace('__VER__', $script:ProtocolVersion)
}

# ------------------------------------------------------------
# 5. CLAUDE.md validation — decide: keep / replace / rewrite
# ------------------------------------------------------------
function Test-ClaudeProtocol {
    param([string]$Path)

    if (-not (Test-Path $Path)) { return "MISSING" }

    $content = Get-Content -Path $Path -Raw

    # Version marker check
    if ($content -match '<!-- PROTOCOL_VERSION: (\d+) -->') {
        $found = [int]$Matches[1]
        if ($found -lt $script:ProtocolVersion) { return "OUTDATED" }
        # Structural sanity even on current version (user may have hand-edited)
        $required = @('LEDGER.md', 'ISSUES', 'ACTIONS', 'DECISIONS', 'Decision Permanence')
        foreach ($token in $required) {
            if ($content -notmatch [regex]::Escape($token)) { return "CORRUPT" }
        }
        return "CURRENT"
    }

    # No marker at all: legacy template (4-file or 5-file era) or foreign file
    return "LEGACY"
}

function Update-ClaudeProtocol {
    param([string]$Path, [string]$State)

    # Backup whatever exists before overwriting
    if (Test-Path $Path) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        Copy-Item $Path "$Path.bak-$stamp"
        Write-Host "[Protocol] Existing CLAUDE.md backed up (CLAUDE.md.bak-$stamp)." -ForegroundColor Yellow
    }
    Set-Content -Path $Path -Value (Get-ClaudeProjectTemplate) -Encoding UTF8
    Write-Host "[Protocol] CLAUDE.md $State -> replaced with v$script:ProtocolVersion." -ForegroundColor Cyan
}

# ------------------------------------------------------------
# 6. Main entry — ccode
#    No injected opening prompts, ever. claude always launches
#    clean and waits for your first message. CLAUDE.md is
#    auto-loaded by Claude Code, so Bootstrap (rule 1) and
#    Legacy Migration (rule 6) trigger on your first message.
#    All status goes to the console via Write-Host only.
# ------------------------------------------------------------
function Start-ClaudeWorkspace {
    # --- Task 0: global rules, always ---
    Sync-ClaudeGlobalRules

    # --- Guard: don't inject a project into a random folder ---
    $root = Get-Location

    # Hard blocklist: these are never projects. Extension sniffing lies
    # here (Downloads always contains some .json or .md), so refuse flat.
    $blockedRoots = @(
        $env:USERPROFILE,
        (Join-Path $env:USERPROFILE "Downloads"),
        (Join-Path $env:USERPROFILE "Desktop"),
        (Join-Path $env:USERPROFILE "Documents"),
        (Join-Path $env:USERPROFILE "OneDrive")
    )
    if ($blockedRoots -contains $root.Path.TrimEnd('\')) {
        Write-Host "[Guard] '$root' is a system folder, not a project. cd into a project folder first." -ForegroundColor Red
        return
    }
    $codeExtensions = @(".py", ".mq5", ".md", ".json", ".js", ".ts", ".cs",
                        ".rs", ".go", ".ps1", ".html", ".css", ".yaml",
                        ".yml", ".toml", ".sql", ".ipynb")
    $looksLikeProject = (Test-Path ".git") -or (Test-Path "CLAUDE.md") -or
                        (Get-ChildItem -File -ErrorAction SilentlyContinue |
                         Where-Object { $_.Extension -in $codeExtensions } |
                         Select-Object -First 1)
    if (-not $looksLikeProject) {
        $confirm = Read-Host "[Guard] '$root' doesn't look like a project. Bootstrap here? (y/N)"
        if ($confirm -ne 'y') { Write-Host "Aborted." -ForegroundColor Yellow; return }
    }

    # --- Task 1: backup first, before anything can touch state files ---
    Backup-ProjectState

    # --- Task 2: git, always ---
    Initialize-GitWorkspace

    # --- Task 3: CLAUDE.md check. Console notices only, no prompts. ---
    $claudeMdPath = Join-Path $root "CLAUDE.md"
    $state = Test-ClaudeProtocol -Path $claudeMdPath

    $legacyFiles = @("STATUS.md", "PROGRESS.md", "DECISIONS.md") |
                   Where-Object { Test-Path (Join-Path $root $_) }

    switch ($state) {
        "CURRENT" {
            Write-Host "[Protocol] CLAUDE.md v$script:ProtocolVersion verified." -ForegroundColor Green
        }
        "MISSING" {
            Set-Content -Path $claudeMdPath -Value (Get-ClaudeProjectTemplate) -Encoding UTF8
            Write-Host "[Protocol] CLAUDE.md provisioned (v$script:ProtocolVersion). Bootstrap runs on your first message." -ForegroundColor Cyan
        }
        default {
            # OUTDATED / LEGACY / CORRUPT — replace, keep backup
            Update-ClaudeProtocol -Path $claudeMdPath -State $state
        }
    }

    if ($legacyFiles) {
        Write-Host "[Protocol] Legacy files present: $($legacyFiles -join ', ')." -ForegroundColor Yellow
        Write-Host "[Protocol] Rule 6 migration runs with your first message. Approve the deletions when asked, or the notice repeats next session." -ForegroundColor Yellow
    }

    # --- Launch: always clean, always with your own args ---
    claude @args
}

Set-Alias ccode Start-ClaudeWorkspace

# ------------------------------------------------------------
# 7. Quota line — per-project statusline activation
#    Source: https://github.com/www8351/Claude_Quota_Line
#    The repo is cloned ONCE to ~/.claude/quota-line-src and the
#    script copied to ~/.claude/quota-line/statusline.ps1. That is
#    the shared engine, one copy for the whole machine.
#    Activation is per project: a statusLine block is merged into
#    the project's .claude/settings.local.json. The global
#    ~/.claude/settings.json is NEVER touched, so projects without
#    qline show no quota line at all.
#    Usage:
#      qline                 activate in the current project
#      qline -Off            remove from the current project
#      qline -NoUpdate       activate without git pull on the source
#      qline -ExtraArgs "…"  pass statusline.ps1 parameters through
# ------------------------------------------------------------
function Set-QuotaLine {
    param(
        [switch]$Off,
        [switch]$NoUpdate,
        [string]$ExtraArgs = "-Align right"
    )
    $root      = Get-Location
    $localJson = Join-Path $root ".claude\settings.local.json"

    if ($Off) {
        if (Test-Path $localJson) {
            $cfg = Get-Content $localJson -Raw | ConvertFrom-Json
            if ($cfg.PSObject.Properties['statusLine']) {
                $cfg.PSObject.Properties.Remove('statusLine')
                $cfg | ConvertTo-Json -Depth 10 | Set-Content $localJson -Encoding UTF8
                Write-Host "[Quota] statusLine removed from this project." -ForegroundColor Yellow
            } else {
                Write-Host "[Quota] No statusLine in this project. Nothing to do." -ForegroundColor Cyan
            }
        } else {
            Write-Host "[Quota] No local settings file. Nothing to do." -ForegroundColor Cyan
        }
        return
    }

    # --- Ensure shared engine exists and is current ---
    $srcDir    = "$env:USERPROFILE\.claude\quota-line-src"
    $scriptDir = "$env:USERPROFILE\.claude\quota-line"
    if (Test-Path (Join-Path $srcDir ".git")) {
        if (-not $NoUpdate) { git -C $srcDir pull --quiet 2>$null }
    } else {
        git clone --quiet --depth 1 https://github.com/www8351/Claude_Quota_Line $srcDir
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[Quota] Clone failed. Check network and retry." -ForegroundColor Red
            return
        }
    }
    New-Item -ItemType Directory -Force -Path $scriptDir | Out-Null
    Copy-Item (Join-Path $srcDir "statusline.ps1") $scriptDir -Force

    # --- Build the command. pwsh preferred, PS 5.1 fallback ---
    $shell = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }
    $cmd = "$shell -NoProfile -ExecutionPolicy Bypass -File `"$scriptDir\statusline.ps1`" $ExtraArgs"

    # --- Merge into project-local settings, never global ---
    New-Item -ItemType Directory -Force -Path (Join-Path $root ".claude") | Out-Null
    $cfg = if (Test-Path $localJson) {
        Get-Content $localJson -Raw | ConvertFrom-Json
    } else {
        [pscustomobject]@{}
    }
    $block = [pscustomobject]@{ type = "command"; command = $cmd }
    if ($cfg.PSObject.Properties['statusLine']) { $cfg.statusLine = $block }
    else { $cfg | Add-Member -NotePropertyName statusLine -NotePropertyValue $block }
    $cfg | ConvertTo-Json -Depth 10 | Set-Content $localJson -Encoding UTF8

    # --- Self-repair: keep the local settings file out of git even in
    #     projects whose .gitignore predates this profile version ---
    $gi = Join-Path $root ".gitignore"
    if ((Test-Path $gi) -and -not (Select-String -Path $gi -Pattern '^\.claude/settings\.local\.json$' -Quiet)) {
        Add-Content -Path $gi -Value "`n.claude/settings.local.json"
        Write-Host "[Quota] .gitignore updated with local settings exclusion." -ForegroundColor Cyan
    }

    Write-Host "[Quota] statusLine active for '$((Split-Path $root -Leaf))'. Restart Claude Code." -ForegroundColor Green
}

Set-Alias qline Set-QuotaLine