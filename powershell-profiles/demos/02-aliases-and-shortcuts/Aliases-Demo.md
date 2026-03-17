# 02 — Aliases & Shortcuts

---

## Example 1 — Built-in aliases

PowerShell ships with aliases already — you've probably been using them without knowing it.

**See what's already there:**

```powershell
Get-Alias | Select-Object -First 20 | Format-Table -AutoSize | Out-Host
```

**Look up what a specific alias points to:**

```powershell
Get-Alias ls | Format-Table -AutoSize | Out-Host
Get-Alias cd | Format-Table -AutoSize | Out-Host
Get-Alias cls | Format-Table -AutoSize | Out-Host
```

**Or look it up the other way — what aliases exist for a given cmdlet?**

```powershell
Get-Alias -Definition Get-ChildItem
Get-Alias -Definition Set-Location
Get-Alias -Definition Clear-Host
```

---

## Example 2 — Simple alias: shortening a long cmdlet name

`New-Alias` creates a shorthand for any cmdlet. One line and you never type the full name again.

**Before — the full name every time:**

```powershell
Get-Help Get-Process -Online
```

**Create the alias:**

```powershell
New-Alias -Name gh -Value Get-Help
Get-Alias gh
```

**After — same cmdlet, same parameters, shorter name:**

```powershell
gh Get-Process -Online
Reset-AliasDemo
```

---

## Example 3 — Alias + wrapper function: baking in parameters

Aliases can only point to a command name — not a command with parameters. This will not work:

```powershell
# Set-Alias -Name syslog -Value "Get-EventLog -LogName System"  ← invalid
```

The fix is a thin wrapper function, then alias that.

**Create the wrapper and confirm it works:**

```powershell
function Get-SystemEventLog { Get-EventLog -LogName System -Newest 10 }
Get-SystemEventLog
```

**Alias the wrapper:**

```powershell
Set-Alias -Name syslog -Value Get-SystemEventLog
Get-Alias syslog
```

**After — one word, zero parameters:**

```powershell
syslog
Reset-AliasDemo
```

---

## Example 4 — Real-world: Azure context switching

Without aliases, switching Azure context means typing `Set-AzContext` with raw subscription and tenant GUIDs every single time.

**Before — the real cmdlet, raw GUIDs every session:**

```powershell
Start-Section "EXAMPLE 4 — Azure Aliases  |  BEFORE"
Set-AzContext -Subscription '00000000-aaaa-bbbb-cccc-111111111111' -Tenant '00000000-dddd-eeee-ffff-222222222222'
Set-AzContext -Subscription '00000000-aaaa-bbbb-cccc-333333333333' -Tenant '00000000-dddd-eeee-ffff-444444444444'
Set-AzContext -Subscription '00000000-aaaa-bbbb-cccc-555555555555' -Tenant '00000000-dddd-eeee-ffff-666666666666'
Complete-Section
```

**The wrapper function — encode the GUIDs once, accept a friendly name. This is what goes in `$PROFILE`:**

```powershell
Start-Section "EXAMPLE 4 — Azure Aliases  |  WRAPPER FUNCTION"
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
    Set-AzContext -Subscription $info.Sub -Tenant $info.Tenant
}

function Set-AzContextToProduction  { Set-AzContextTo -Environment Production  }
function Set-AzContextToTest        { Set-AzContextTo -Environment Test        }
function Set-AzContextToDevelopment { Set-AzContextTo -Environment Development }

Set-AzContextTo -Environment Production
Complete-Section
```

**Alias each wrapper to a single word:**

```powershell
Start-Section "EXAMPLE 4 — Azure Aliases  |  CREATE ALIASES"
Set-Alias -Name azprod -Value Set-AzContextToProduction
Set-Alias -Name aztest -Value Set-AzContextToTest
Set-Alias -Name azdev  -Value Set-AzContextToDevelopment

Get-Alias az* | Format-Table Name, Definition -AutoSize | Out-Host
Complete-Section
```

**After — one word per environment:**

```powershell
Start-Section "EXAMPLE 4 — Azure Aliases  |  AFTER"
azprod
aztest
azdev
Reset-AliasDemo
Complete-Section
```

---

## Example 5 — `go`: directory shortcuts with tab completion

Navigating deep paths is tedious even with normal tab completion.

**Before — full paths every time:**

```powershell
Set-Location "$ENV:USERPROFILE\Documents"
Set-Location "$ENV:USERPROFILE\Downloads"
Set-Location "$ENV:TEMP"
```

**The `go` function:**

```powershell
function go {
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$Name
    )

    if ($global:DirShortcuts.ContainsKey($Name)) {
        Set-Location $global:DirShortcuts[$Name]
        Write-Host "  Changed directory to '$Name': $($global:DirShortcuts[$Name])" -ForegroundColor Green
    } else {
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

$DirShortcuts
```

**After — short names with tab completion:**

```powershell
go documents
go downloads
go temp
```

> **Tab completion:** type `go ` then press `Tab` — all shortcuts appear as completions. This is registered via `Register-ArgumentCompleter` in the module and makes it feel like a native shell feature.
