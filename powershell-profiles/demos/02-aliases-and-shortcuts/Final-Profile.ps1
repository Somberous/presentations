#######################################################
#  Final-Profile.ps1
#  Copy this block into your $PROFILE to make all of
#  today's aliases and shortcuts load every session.
#
#  To open your profile:  notepad $PROFILE
#######################################################


# ── Directory shortcuts ───────────────────────────────────────────────────────

$Global:DirShortcuts = @{
    documents = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Documents"
    desktop   = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Desktop"
    downloads = [System.IO.DirectoryInfo]"$ENV:USERPROFILE\Downloads"
    temp      = [System.IO.DirectoryInfo]"$ENV:TEMP"
    profile   = [System.IO.DirectoryInfo](Split-Path $PROFILE)
    # Add your own:
    # scripts = [System.IO.DirectoryInfo]"C:\path\to\scripts"
}

function go {
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$Name
    )

    if ($Global:DirShortcuts.ContainsKey($Name)) {
        Set-Location $Global:DirShortcuts[$Name]
        Write-Host "  Changed directory to '$Name': $($Global:DirShortcuts[$Name])" -ForegroundColor Green
    } else {
        Write-Warning "No shortcut named '$Name'. Available shortcuts:"
        $Global:DirShortcuts.Keys | Sort-Object | ForEach-Object { "  - $_" }
    }
}

Register-ArgumentCompleter -CommandName go -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    $Global:DirShortcuts.Keys |
        Where-Object { $_ -like "$wordToComplete*" } |
        Sort-Object |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}


# ── Azure context switching ───────────────────────────────────────────────────

function Set-AzContextTo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Production', 'Test', 'Development')]
        [string]$Environment
    )
    # Replace with your real subscription/tenant IDs
    $envMap = @{
        Production  = @{ Sub = '<prod-subscription-id>';  Tenant = '<prod-tenant-id>'  }
        Test        = @{ Sub = '<test-subscription-id>';  Tenant = '<test-tenant-id>'  }
        Development = @{ Sub = '<dev-subscription-id>';   Tenant = '<dev-tenant-id>'   }
    }
    $info = $envMap[$Environment]
    Connect-AzAccount -Subscription $info.Sub -Tenant $info.Tenant
}

function Set-AzContextToProduction  { Set-AzContextTo -Environment Production  }
function Set-AzContextToTest        { Set-AzContextTo -Environment Test        }
function Set-AzContextToDevelopment { Set-AzContextTo -Environment Development }

Set-Alias -Name azprod -Value Set-AzContextToProduction
Set-Alias -Name aztest -Value Set-AzContextToTest
Set-Alias -Name azdev  -Value Set-AzContextToDevelopment


# ── Useful shorthand aliases ──────────────────────────────────────────────────

New-Alias -Name gh     -Value Get-Help
function Get-SystemEventLog { Get-EventLog -LogName System -Newest 10 }
Set-Alias -Name syslog -Value Get-SystemEventLog
