#######################################################
#  Final-Profile.ps1  —  05-extras
#  Copy this block into your $PROFILE.
#
#  To open your profile:  notepad $PROFILE
#######################################################


# ── Start-Transcript default ──────────────────────────────────────────────────

$transcriptDir = "$ENV:USERPROFILE\Documents\Transcripts"
if (-not (Test-Path $transcriptDir)) {
    New-Item -ItemType Directory -Path $transcriptDir -Force | Out-Null
}

$PSDefaultParameterValues['Start-Transcript:Path'] = {
    "$ENV:USERPROFILE\Documents\Transcripts\$(Get-Date -Format 'yyyy-MM-dd').txt"
}

# Uncomment to auto-start a transcript every session:
# Start-Transcript


# ── Error view ────────────────────────────────────────────────────────────────

$ErrorView = 'ConciseView'

Set-PSReadLineOption -Colors @{
    Error = "`e[31m"   # plain red foreground, no background block
}


# ── Custom prompt ─────────────────────────────────────────────────────────────

function prompt {
    $path   = $ExecutionContext.SessionState.Path.CurrentLocation
    $time   = Get-Date -Format 'HH:mm:ss'
    $branch = ''

    if (Get-Command git -ErrorAction SilentlyContinue) {
        $b = git branch --show-current 2>$null
        if ($b) { $branch = " `e[33m($b)`e[0m" }
    }

    "`n`e[36m$time`e[0m  `e[32m$path`e[0m$branch`n`e[0m> "
}
