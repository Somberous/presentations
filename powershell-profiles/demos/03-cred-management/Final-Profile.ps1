#######################################################
#  Final-Profile.ps1
#  Copy this block into your $PROFILE to get automatic
#  credential loading every time PowerShell starts.
#
#  To open your profile:  notepad $PROFILE
#######################################################


# ── Credential store path ─────────────────────────────────────────────────────
#  Point this at wherever you keep your .xml credential files.
#  Create the folder first if it doesn't exist.

$Global:CliXmlPath = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Documents\PowerShell\Credentials"

if (-not (Test-Path $Global:CliXmlPath)) {
    New-Item -ItemType Directory -Path $Global:CliXmlPath -Force | Out-Null
}


# ── Import-CliXmlCredentials ──────────────────────────────────────────────────
#  Scans the credential folder on every shell start and loads every .xml file
#  into a global variable named after the file. Drop a new file in the folder
#  and it's automatically available next session — no profile changes needed.

function Import-CliXmlCredentials {
    [CmdletBinding()]
    param(
        [System.IO.DirectoryInfo]$Path = $Global:CliXmlPath
    )

    try {
        $files = Get-ChildItem -Path $Path -Filter '*.xml' -ErrorAction Stop
    } catch {
        Write-Warning "Credential folder not found: $Path"
        return
    }

    foreach ($file in $files) {
        try {
            $varName = $file.BaseName
            $cred    = Import-Clixml -Path $file.FullName
            New-Variable -Name $varName -Value $cred -Scope Global -Force
        } catch {
            Write-Warning "Failed to import $($file.Name): $_"
        }
    }
}


# ── Get-LoadedCliXmlCredentials ───────────────────────────────────────────────
#  See which credentials are currently loaded in your session.

function Get-LoadedCliXmlCredentials {
    Get-Variable |
        Where-Object { $_.Value -is [pscredential] } |
        Select-Object Name, @{ Name = 'Username'; Expression = { $_.Value.UserName } }
}


# ── New-CliXmlEntry ───────────────────────────────────────────────────────────
#  Save a new credential to the store. Run once per account, never again.
#
#  Usage:  New-CliXmlEntry -Name 'adminCred'
#          New-CliXmlEntry -Name 'svcCred' -Credential $myCred

function New-CliXmlEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [pscredential]$Credential,

        [Parameter()]
        [System.IO.DirectoryInfo]$Path = $Global:CliXmlPath
    )

    if (-not $Credential) {
        $Credential = Get-Credential -Message "Enter credentials to save as '$Name'"
    }

    $outPath = Join-Path $Path.FullName "$Name.xml"
    $Credential | Export-Clixml -Path $outPath
    Write-Host "Saved to $outPath" -ForegroundColor Green
}


# ── Remove-CliXmlCredentials ──────────────────────────────────────────────────
#  Unload all credentials from the current session without deleting the files.

function Remove-CliXmlCredentials {
    Get-LoadedCliXmlCredentials | ForEach-Object {
        Remove-Variable -Name $_.Name -Scope Global -ErrorAction SilentlyContinue
    }
    Write-Host "Cleared all loaded credentials from session." -ForegroundColor DarkGray
}


# ── Auto-load on profile start ────────────────────────────────────────────────
#  This is the one line that makes it all automatic.

Import-CliXmlCredentials
