<#
    Obsidian notes git auto-sync.

    Commits every change in the notes repository, then pushes the current
    branch to the configured remotes. Designed for unattended execution
    (shutdown / logon): it never shows a prompt and never blocks the caller -
    push failures, missing credentials and network errors are logged and ignored.

    Manual use:
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File git-autosync.ps1
#>
[CmdletBinding()]
param(
    [string]$Repo = 'D:\ObsidianStorage',
    [string[]]$PushUrls = @(
        'https://github.com/mofei1116/StudyNotes.git',
        'https://gitee.com/mofei_auriga/study-notes.git'
    ),
    [int]$PushTimeoutSeconds = 40,
    [switch]$ForcePush
)

$ErrorActionPreference = 'Continue'

$script:LogFile = Join-Path $PSScriptRoot 'sync.log'
$script:PendingFile = Join-Path $PSScriptRoot 'push.pending'

function Write-SyncLog {
    param([string]$Message)
    try {
        if ((Test-Path -LiteralPath $script:LogFile) -and ((Get-Item -LiteralPath $script:LogFile).Length -gt 1MB)) {
            Move-Item -LiteralPath $script:LogFile -Destination ($script:LogFile + '.1') -Force -ErrorAction SilentlyContinue
        }
        Add-Content -LiteralPath $script:LogFile -Encoding UTF8 -ErrorAction SilentlyContinue -Value (
            '[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message)
    }
    catch {
        # Logging must never break the sync.
    }
}

function Invoke-GitCommand {
    param([string[]]$Arguments)
    $output = & git.exe @Arguments 2>&1
    $code = $LASTEXITCODE
    $text = ($output | ForEach-Object { [string]$_ }) -join "`n"
    return [pscustomobject]@{ ExitCode = $code; Text = $text }
}

function Invoke-GitPush {
    param([string]$Url, [string]$Branch, [int]$TimeoutSeconds)

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git.exe'
    $startInfo.Arguments = '-C "{0}" -c credential.interactive=false push --porcelain --no-verify "{1}" {2}:{2}' -f $Repo, $Url, $Branch
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    $startInfo.WorkingDirectory = $Repo

    $process = $null
    try {
        $process = [System.Diagnostics.Process]::Start($startInfo)
        if ($process -eq $null) {
            return [pscustomobject]@{ Ok = $false; Detail = 'could not start git.exe' }
        }

        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            try { $process.Kill() } catch { }
            try { $process.WaitForExit(5000) | Out-Null } catch { }
            return [pscustomobject]@{ Ok = $false; Detail = ('timed out after {0}s' -f $TimeoutSeconds) }
        }

        $process.WaitForExit()
        $stdout = ''
        $stderr = ''
        try { $stdout = [string]$stdoutTask.Result } catch { }
        try { $stderr = [string]$stderrTask.Result } catch { }

        $exitCode = $process.ExitCode
        if ($exitCode -eq 0) {
            $summary = (($stdout -replace '\s+', ' ').Trim())
            if (-not $summary) { $summary = 'up to date' }
            return [pscustomobject]@{ Ok = $true; Detail = $summary }
        }

        $detail = (($stderr + ' ' + $stdout) -replace '\s+', ' ').Trim()
        if ($detail.Length -gt 400) { $detail = $detail.Substring(0, 400) }
        return [pscustomobject]@{ Ok = $false; Detail = ('exit {0}: {1}' -f $exitCode, $detail) }
    }
    catch {
        return [pscustomobject]@{ Ok = $false; Detail = $_.ToString() }
    }
}

Write-SyncLog '--- sync start ---'

if (-not (Test-Path -LiteralPath (Join-Path $Repo '.git'))) {
    Write-SyncLog ("skip: '{0}' is not a git working tree" -f $Repo)
    exit 0
}

# Unattended: never raise a credential prompt (there may be no desktop at all).
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'

$mutex = New-Object System.Threading.Mutex($false, 'Local\ObsidianGitAutoSync_Sync')
$hasLock = $false
try {
    $hasLock = $mutex.WaitOne(20000)
}
catch [System.Threading.AbandonedMutexException] {
    $hasLock = $true
}
if (-not $hasLock) {
    Write-SyncLog 'skip: another sync is already running'
    exit 0
}

Push-Location -LiteralPath $Repo
try {
    $branch = (& git.exe rev-parse --abbrev-ref HEAD 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $branch) {
        Write-SyncLog 'skip: cannot resolve the current branch'
        exit 0
    }
    $branch = ([string]$branch).Trim()

    $status = (& git.exe status --porcelain 2>$null)
    $changes = @($status | Where-Object { $_ -ne $null -and "$_" -ne '' })

    $committed = $false
    if ($changes.Count -gt 0) {
        Write-SyncLog ("changes detected: {0} path(s)" -f $changes.Count)

        $add = Invoke-GitCommand @('-C', $Repo, 'add', '--all')
        if ($add.ExitCode -ne 0) {
            Write-SyncLog ("git add failed ({0}): {1}" -f $add.ExitCode, $add.Text)
            exit 0
        }

        $message = 'auto-sync: notes backup {0} on {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $env:COMPUTERNAME
        $commit = Invoke-GitCommand @('-C', $Repo, '-c', 'commit.gpgsign=false', 'commit', '--no-verify', '-m', $message)
        if ($commit.ExitCode -ne 0) {
            Write-SyncLog ("git commit failed ({0}): {1}" -f $commit.ExitCode, $commit.Text)
            exit 0
        }
        $committed = $true
        Write-SyncLog ('committed: ' + $message)
    }
    else {
        Write-SyncLog 'no local changes'
    }

    # Push when something was committed, or when a previous push is still owed.
    $pending = Test-Path -LiteralPath $script:PendingFile
    if (-not $committed -and -not $pending -and -not $ForcePush) {
        Write-SyncLog 'nothing to push'
        exit 0
    }

    if ($branch -eq 'HEAD') {
        Write-SyncLog 'skip push: detached HEAD'
        exit 0
    }

    $ok = 0
    foreach ($url in $PushUrls) {
        Write-SyncLog ('push -> ' + $url)
        $result = Invoke-GitPush -Url $url -Branch $branch -TimeoutSeconds $PushTimeoutSeconds
        if ($result.Ok) {
            $ok++
            Write-SyncLog ('push OK: ' + $url)
        }
        else {
            Write-SyncLog ('push FAILED (ignored): ' + $url + ' :: ' + $result.Detail)
        }
    }

    if ($ok -eq $PushUrls.Count) {
        Remove-Item -LiteralPath $script:PendingFile -Force -ErrorAction SilentlyContinue
    }
    else {
        'some remotes are still behind' | Set-Content -LiteralPath $script:PendingFile -Encoding ASCII -ErrorAction SilentlyContinue
    }
    Write-SyncLog ('done: {0}/{1} remote(s) updated' -f $ok, $PushUrls.Count)
}
finally {
    Pop-Location
    try { $mutex.ReleaseMutex() } catch { }
}

exit 0
