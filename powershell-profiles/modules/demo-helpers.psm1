#######################################################
#  Demo-Helpers.psm1
#  Shared helper module for all presentation demos.
#  Import from any demo folder:
#    Import-Module "..\modules\Demo-Helpers.psm1" -Force
#######################################################


# ════════════════════════════════════════════════════
#  SHARED UTILITIES
# ════════════════════════════════════════════════════

function Start-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  $('─' * 56)" -ForegroundColor DarkGray
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "  $('─' * 56)" -ForegroundColor DarkGray
    Write-Host ""
}

function Complete-Section {
    Write-Host ""
}

function Wait-ForKeyPress {
    param([string]$Message = 'Press any key to continue, or escape to exit...')
    Write-Host "`n$Message" -ForegroundColor DarkGray
    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    Write-Host ""
    if ($key.VirtualKeyCode -eq 27 -or # Escape
        ($key.VirtualKeyCode -eq 67 -and $key.ControlKeyState -match 'LeftCtrlPressed|RightCtrlPressed')) {
        # Ctrl+C
        Write-Host "  Exiting demo.`n" -ForegroundColor DarkGray
        exit
    }
}


# ════════════════════════════════════════════════════
#  01 — $PSDefaultParameterValues
# ════════════════════════════════════════════════════

# ── Show-FileEncoding ─────────────────────────────────────────────────────────

function Show-FileEncoding {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hex = ($bytes[0..3] | ForEach-Object { '0x{0:X2}' -f $_ }) -join '  '

    Write-Host "  First bytes: $hex" -ForegroundColor DarkGray

    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Host "  BOM detected  →  UTF-8 ✓  Special characters are safe.`n" -ForegroundColor Green
    }
    else {
        Write-Host "  No BOM  →  ASCII  ✗  0x23 0x54 0x59 0x50 = # T Y P = the #TYPE header.`n" -ForegroundColor Red
    }
}


# ── Mock Get-ADUser ───────────────────────────────────────────────────────────

function Get-ADUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Filter,
        [string[]]$Properties
    )

    $allUsers = @(
        [PSCustomObject]@{
            SamAccountName    = 'jsmith'
            Name              = 'John Smith'
            GivenName         = 'John'
            Surname           = 'Smith'
            UserPrincipalName = 'jsmith@contoso.com'
            DistinguishedName = 'CN=John Smith,OU=Users,DC=contoso,DC=com'
            ObjectClass       = 'user'
            ObjectGUID        = [guid]::NewGuid()
            SID               = 'S-1-5-21-3623811015-3361044348-30300820-1013'
            Enabled           = $true
            EmailAddress      = 'john.smith@contoso.com'
            Department        = 'Information Technology'
            Manager           = 'CN=Jane Doe,OU=Users,DC=contoso,DC=com'
            Title             = 'Senior Systems Administrator'
            LastLogonDate     = (Get-Date).AddDays(-2)
            PasswordLastSet   = (Get-Date).AddDays(-45)
        }
        [PSCustomObject]@{
            SamAccountName    = 'fjones'
            Name              = 'François Jones'
            GivenName         = 'François'
            Surname           = 'Jones'
            UserPrincipalName = 'fjones@contoso.com'
            DistinguishedName = 'CN=François Jones,OU=Users,DC=contoso,DC=com'
            ObjectClass       = 'user'
            ObjectGUID        = [guid]::NewGuid()
            SID               = 'S-1-5-21-3623811015-3361044348-30300820-1014'
            Enabled           = $true
            EmailAddress      = 'francois.jones@contoso.com'
            Department        = 'Finance'
            Manager           = 'CN=Jane Doe,OU=Users,DC=contoso,DC=com'
            Title             = 'Financial Analyst'
            LastLogonDate     = (Get-Date).AddDays(-1)
            PasswordLastSet   = (Get-Date).AddDays(-10)
        }
    )

    $defaultProperties = @(
        'SamAccountName', 'Name', 'GivenName', 'Surname',
        'UserPrincipalName', 'DistinguishedName', 'ObjectClass', 'ObjectGUID', 'SID', 'Enabled'
    )

    $requestedProperties = if (-not $Properties) {
        $defaultProperties
    }
    elseif ($Properties -contains '*') {
        $allUsers[0].PSObject.Properties.Name
    }
    else {
        ($defaultProperties + $Properties) | Select-Object -Unique
    }

    $filterString = $Filter.ToString().Trim()
    $samMatch = [regex]::Match($filterString, "SamAccountName\s+-eq\s+'([^']+)'")

    $matchedUsers = if ($samMatch.Success) {
        $allUsers | Where-Object { $_.SamAccountName -eq $samMatch.Groups[1].Value }
    }
    else {
        $allUsers
    }

    foreach ($user in $matchedUsers) {
        $result = [ordered]@{}
        foreach ($prop in $requestedProperties) { $result[$prop] = $user.$prop }
        [PSCustomObject]$result
    }
}


# ── Mock Connect-MgGraph ──────────────────────────────────────────────────────

function Connect-MgGraph {
    [CmdletBinding()]
    param([string[]]$Scopes)

    Write-Host "  Welcome To Microsoft Graph!" -ForegroundColor Green
    if ($Scopes) {
        Write-Host "  Connected with scopes:" -ForegroundColor DarkGray
        $Scopes | ForEach-Object { Write-Host "    - $_" -ForegroundColor DarkGray }
    }
    else {
        Write-Host "  Connected with scopes:" -ForegroundColor DarkGray
        Write-Host "    (none provided — using defaults from `$PSDefaultParameterValues)" -ForegroundColor DarkGray
    }
    Write-Host ""
}


# ── Cleanup ───────────────────────────────────────────────────────────────────

function Reset-Example1 {
    $global:PSDefaultParameterValues.Remove('Export-Csv:NoTypeInformation')
    $global:PSDefaultParameterValues.Remove('Export-Csv:Encoding')
    Remove-Item "$ENV:TEMP\procs_before.csv", "$ENV:TEMP\procs_after.csv" -ErrorAction SilentlyContinue
}

function Reset-Example2 { $global:PSDefaultParameterValues.Remove('Get-ADUser:Properties') }
function Reset-Example3 { $global:PSDefaultParameterValues.Remove('Connect-MgGraph:Scopes') }
function Reset-Example4 { $global:PSDefaultParameterValues.Remove('*:WhatIf') }
function Reset-Example5 { $global:PSDefaultParameterValues.Remove('Format-Table:Wrap') }

function Reset-AllExamples { $global:PSDefaultParameterValues.Clear() }


# ════════════════════════════════════════════════════
#  02 — Aliases & Shortcuts
# ════════════════════════════════════════════════════

# ── Mock Azure functions ──────────────────────────────────────────────────────

#  Set-AzContext mimics the real Az module cmdlet output so the demo runs
#  without Az installed. Set-AzContextTo is the real wrapper you'd use in
#  production — it calls Set-AzContext exactly as the real version would.

function Set-AzContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Subscription,
        [Parameter(Mandatory)][string]$Tenant
    )

    $names = @{
        '00000000-aaaa-bbbb-cccc-111111111111' = 'Contoso-Production'
        '00000000-aaaa-bbbb-cccc-333333333333' = 'Contoso-Test'
        '00000000-aaaa-bbbb-cccc-555555555555' = 'Contoso-Development'
    }
    $name = $names[$Subscription] ?? $Subscription

    [PSCustomObject]@{
        Name           = $name
        Account        = 'admin@contoso.com'
        SubscriptionId = $Subscription
        TenantId       = $Tenant
        Environment    = 'AzureCloud'
    }
}
function Set-AzContextTo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Production', 'Test', 'Development')]
        [string]$Environment
    )

    $envMap = @{
        Production  = @{ Sub = '00000000-aaaa-bbbb-cccc-111111111111'; Tenant = '00000000-dddd-eeee-ffff-222222222222' }
        Test        = @{ Sub = '00000000-aaaa-bbbb-cccc-333333333333'; Tenant = '00000000-dddd-eeee-ffff-444444444444' }
        Development = @{ Sub = '00000000-aaaa-bbbb-cccc-555555555555'; Tenant = '00000000-dddd-eeee-ffff-666666666666' }
    }

    $info = $envMap[$Environment]
    Write-Host "  Connecting to Azure — Environment : $Environment" -ForegroundColor DarkGray
    Write-Host "  Subscription  : $($info.Sub)" -ForegroundColor DarkGray
    Write-Host "  Tenant        : $($info.Tenant)" -ForegroundColor DarkGray
    Write-Host "  Context set to $Environment successfully.`n" -ForegroundColor Green
}

function Set-AzContextToProduction { Set-AzContextTo -Environment Production }
function Set-AzContextToTest { Set-AzContextTo -Environment Test }
function Set-AzContextToDevelopment { Set-AzContextTo -Environment Development }


# ── Directory shortcuts ───────────────────────────────────────────────────────

$Global:DirShortcuts = @{
    documents = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Documents"
    desktop   = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Desktop"
    downloads = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Downloads"
    temp      = [System.IO.DirectoryInfo]"$ENV:TEMP"
    profile   = [System.IO.DirectoryInfo](Split-Path $PROFILE)
}

function go {
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$Name
    )

    if ($global:DirShortcuts.ContainsKey($Name)) {
        Set-Location $global:DirShortcuts[$Name]
        Write-Host "  Changed directory to '$Name': $($global:DirShortcuts[$Name])" -ForegroundColor Green
    }
    else {
        Write-Warning "No shortcut named '$Name'. Available shortcuts:"
        $global:DirShortcuts.Keys | Sort-Object | ForEach-Object { "  - $_" }
    }
}

Register-ArgumentCompleter -CommandName go -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    $global:DirShortcuts.Keys |
    Where-Object { $_ -like "$wordToComplete*" } |
    Sort-Object |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}


# ── Cleanup ───────────────────────────────────────────────────────────────────

function Reset-AliasDemo {
    @('syslog', 'azprod', 'aztest', 'azdev', 'gh') | ForEach-Object {
        if (Get-Alias $_ -ErrorAction SilentlyContinue) {
            Remove-Alias $_ -Force -ErrorAction SilentlyContinue
        }
    }
}


# ════════════════════════════════════════════════════
#  03 — Credential Management
# ════════════════════════════════════════════════════

$Global:CliXmlPath = [System.IO.DirectoryInfo]"$ENV:TEMP\demo-creds"


# ── Import-CliXmlCredentials ──────────────────────────────────────────────────

function Import-CliXmlCredentials {
    [CmdletBinding()]
    param(
        [System.IO.DirectoryInfo]$Path = $global:CliXmlPath
    )

    try {
        $files = Get-ChildItem -Path $Path -Filter '*.xml' -ErrorAction Stop
    }
    catch {
        Write-Error "Could not find credential folder: $Path"
        return
    }

    foreach ($file in $files) {
        try {
            $varName = $file.BaseName
            $cred = Import-Clixml -Path $file.FullName
            New-Variable -Name $varName -Value $cred -Scope Global -Force
            Write-Host "  Loaded `$$varName" -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to import $($file.Name): $_"
        }
    }
}


# ── Get-LoadedCliXmlCredentials ───────────────────────────────────────────────

function Get-LoadedCliXmlCredentials {
    Get-Variable |
    Where-Object { $_.Value -is [pscredential] } |
    Select-Object Name, @{ Name = 'Username'; Expression = { $_.Value.UserName } }
}


# ── New-CliXmlEntry ───────────────────────────────────────────────────────────

function New-CliXmlEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [pscredential]$Credential,

        [Parameter()]
        [System.IO.DirectoryInfo]$Path = $global:CliXmlPath
    )

    if (-not $Credential) {
        $Credential = Get-Credential -Message "Enter credentials to save as '$Name'"
    }

    $outPath = Join-Path $Path.FullName "$Name.xml"
    $Credential | Export-Clixml -Path $outPath
    Write-Host "  Saved to $outPath" -ForegroundColor Green
}


# ── Remove-CliXmlCredentials ──────────────────────────────────────────────────

function Remove-CliXmlCredentials {
    Get-LoadedCliXmlCredentials | ForEach-Object {
        Remove-Variable -Name $_.Name -Scope Global -ErrorAction SilentlyContinue
    }
    Write-Host "  Cleared all loaded credentials from session." -ForegroundColor DarkGray
}


# ── Cleanup ───────────────────────────────────────────────────────────────────

function Reset-CredDemo {
    Remove-CliXmlCredentials
    if (Test-Path $global:CliXmlPath) {
        Remove-Item $global:CliXmlPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}


# ════════════════════════════════════════════════════
#  04 — PSReadLine
# ════════════════════════════════════════════════════

function Reset-PSReadLineDemo {
    Set-PSReadLineOption -PredictionSource None
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineKeyHandler -Key UpArrow   -Function PreviousHistory
    Set-PSReadLineKeyHandler -Key DownArrow -Function NextHistory
}


# ════════════════════════════════════════════════════
#  05 — Extras
# ════════════════════════════════════════════════════

function Reset-ExtrasDemo {
    $global:PSDefaultParameterValues.Remove('Start-Transcript:Path')
    $global:ErrorView = 'ConciseView'
    # Restore default prompt
    Remove-Item Function:\prompt -ErrorAction SilentlyContinue
}


Export-ModuleMember -Function * -Variable DirShortcuts, CliXmlPath