#######################################################
#  Run-Demo.ps1
#  Runs all demo blocks in sequence.
#  Open the relevant .md file for context and notes.
#######################################################

Set-Location $PSScriptRoot
Import-Module "..\modules\Demo-Helpers.psm1" -Force


#region 01 - $PSDefaultParameterValues

Reset-AllExamples
Start-Section "01 — `$PSDefaultParameterValues  |  SETUP COMPLETE"
Complete-Section
Wait-ForKeyPress

# Example 1 — Export-Csv
$beforeFile = "$ENV:TEMP\procs_before.csv"
$afterFile = "$ENV:TEMP\procs_after.csv"

Start-Section "EXAMPLE 1 — Export-Csv  |  BEFORE"
Start-Process powershell.exe -ArgumentList (
    "-NoProfile -Command `"Get-Process | Select-Object Name,CPU | Export-Csv '$beforeFile'`""
) -Wait -WindowStyle Hidden -WhatIf:$false
Show-FileEncoding $beforeFile
Get-Content $beforeFile | Select-Object -First 4
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Export-Csv  |  SET DEFAULTS"
$PSDefaultParameterValues['Export-Csv:NoTypeInformation'] = $true
$PSDefaultParameterValues['Export-Csv:Encoding'] = 'UTF8'
$PSDefaultParameterValues
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Export-Csv  |  AFTER"
Start-Process powershell.exe -ArgumentList (
    "-NoProfile -Command `"Get-Process | Select-Object Name,CPU | Export-Csv '$afterFile' -NoTypeInformation -Encoding UTF8`""
) -Wait -WindowStyle Hidden -WhatIf:$false
Show-FileEncoding $afterFile
Get-Content $afterFile | Select-Object -First 4
Reset-Example1
Complete-Section
Wait-ForKeyPress

# Example 2 — Get-ADUser
Start-Section "EXAMPLE 2 — Get-ADUser  |  BEFORE"
Get-ADUser -Filter { $_.SamAccountName -eq 'jsmith' } |
Select-Object Name, EmailAddress, Department, Title, LastLogonDate
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — Get-ADUser  |  SET DEFAULTS"
$PSDefaultParameterValues['Get-ADUser:Properties'] = @(
    'EmailAddress', 'Department', 'Manager',
    'Title', 'LastLogonDate', 'PasswordLastSet', 'Enabled'
)
$PSDefaultParameterValues
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — Get-ADUser  |  AFTER"
Get-ADUser -Filter { $_.SamAccountName -eq 'jsmith' } |
Select-Object Name, EmailAddress, Department, Title, LastLogonDate
Get-ADUser -Filter { $_.SamAccountName -eq 'fjones' } |
Select-Object Name, EmailAddress, Department, Title, LastLogonDate
Reset-Example2
Complete-Section
Wait-ForKeyPress

# Example 3 — Connect-MgGraph
Start-Section "EXAMPLE 3 — Connect-MgGraph  |  BEFORE"
Connect-MgGraph -Scopes 'User.Read.All', 'Group.Read.All', 'Directory.Read.All', 'AuditLog.Read.All'
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — Connect-MgGraph  |  SET DEFAULTS"
$PSDefaultParameterValues['Connect-MgGraph:Scopes'] = @(
    'User.Read.All', 'Group.Read.All',
    'Directory.Read.All', 'AuditLog.Read.All'
)
$PSDefaultParameterValues
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — Connect-MgGraph  |  AFTER"
Connect-MgGraph
Reset-Example3
Complete-Section
Wait-ForKeyPress

# Example 4 — *:WhatIf
Start-Section "EXAMPLE 4 — *:WhatIf  |  BEFORE"
'placeholder' | Out-File "$ENV:TEMP\demo-delete-me.txt" -WhatIf:$false
'placeholder' | Out-File "$ENV:TEMP\demo-rename-me.txt" -WhatIf:$false
Remove-Item "$ENV:TEMP\demo-delete-me.txt" -WhatIf:$false
Rename-Item "$ENV:TEMP\demo-rename-me.txt" "$ENV:TEMP\demo-renamed.txt" -WhatIf:$false
Write-Host "  Done — files are gone for real.`n" -ForegroundColor DarkGray
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — *:WhatIf  |  SET DEFAULTS"
$PSDefaultParameterValues['*:WhatIf'] = $true
$PSDefaultParameterValues
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — *:WhatIf  |  AFTER"
'placeholder' | Out-File "$ENV:TEMP\demo-delete-me.txt" -WhatIf:$false
'placeholder' | Out-File "$ENV:TEMP\demo-rename-me.txt" -WhatIf:$false
Remove-Item "$ENV:TEMP\demo-delete-me.txt"
Rename-Item "$ENV:TEMP\demo-rename-me.txt" "$ENV:TEMP\demo-renamed.txt"
Copy-Item   "$ENV:TEMP\demo-rename-me.txt" "$ENV:TEMP\demo-copy.txt"
Reset-Example4
Remove-Item "$ENV:TEMP\demo-delete-me.txt", "$ENV:TEMP\demo-rename-me.txt", "$ENV:TEMP\demo-renamed.txt" -ErrorAction SilentlyContinue -WhatIf:$false
Complete-Section
Wait-ForKeyPress

# Example 5 — ScriptBlock
Start-Section "EXAMPLE 5 — ScriptBlock  |  TERMINAL WIDTH"
Write-Host "Terminal Width is: $($Host.UI.RawUI.WindowSize.Width)"
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 5 — ScriptBlock  |  BEFORE"
Get-Process |
Select-Object Name, CPU, Id, Path |
Sort-Object CPU -Descending |
Select-Object -First 10 |
Format-Table
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 5 — ScriptBlock  |  SET DEFAULTS"
$PSDefaultParameterValues['Format-Table:Wrap'] = {
    if ($Host.UI.RawUI.WindowSize.Width -lt 120) { $true }
}
$PSDefaultParameterValues
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 5 — ScriptBlock  |  AFTER"
Get-Process |
Select-Object Name, CPU, Id, Path |
Sort-Object CPU -Descending |
Select-Object -First 10 |
Format-Table
Reset-Example5
Complete-Section
Wait-ForKeyPress

#endregion

#region 02 — Aliases & Shortcuts

Reset-AliasDemo
Start-Section "02 — Aliases & Shortcuts  |  SETUP COMPLETE"
Complete-Section
Wait-ForKeyPress

# Example 1 — Built-in aliases
Start-Section "EXAMPLE 1 — Built-in Aliases  |  GET-ALIAS"
Get-Alias | Select-Object -First 20 | Format-Table -AutoSize | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Built-in Aliases  |  LOOKUP BY NAME"
Get-Alias ls | Format-Table -AutoSize | Out-Host
Get-Alias cd | Format-Table -AutoSize | Out-Host
Get-Alias cls | Format-Table -AutoSize | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Built-in Aliases  |  LOOKUP BY DEFINITION"
Get-Alias -Definition Get-ChildItem | Format-Table -AutoSize | Out-Host
Get-Alias -Definition Set-Location | Format-Table -AutoSize | Out-Host
Get-Alias -Definition Clear-Host | Format-Table -AutoSize | Out-Host
Complete-Section
Wait-ForKeyPress

# Example 2 — New-Alias
Start-Section "EXAMPLE 2 — New-Alias  |  CREATE"
New-Alias -Name gh -Value Get-Help -Verbose
Get-Alias gh | Format-Table -AutoSize | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — New-Alias  |  AFTER"
gh Get-Process | Out-Host
Reset-AliasDemo
Complete-Section
Wait-ForKeyPress

# Example 3 — Wrapper + Alias
Start-Section "EXAMPLE 3 — Wrapper + Alias  |  CREATE FUNCTION"
function Get-SystemEventLog { Get-EventLog -LogName System -Newest 10 }
Get-SystemEventLog | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — Wrapper + Alias  |  CREATE ALIAS"
Set-Alias -Name syslog -Value Get-SystemEventLog -Verbose
Get-Alias syslog | Format-Table -AutoSize | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — Wrapper + Alias  |  AFTER"
syslog | Out-Host
Reset-AliasDemo
Complete-Section
Wait-ForKeyPress

# Example 4 — Azure aliases
Start-Section "EXAMPLE 4 — Azure Aliases  |  BEFORE"
Set-AzContext -Subscription '00000000-aaaa-bbbb-cccc-111111111111' -Tenant '00000000-dddd-eeee-ffff-222222222222' | Out-Host
Set-AzContext -Subscription '00000000-aaaa-bbbb-cccc-222222222222' -Tenant '00000000-dddd-eeee-ffff-222222222222' | Out-Host 
Set-AzContext -Subscription '00000000-aaaa-bbbb-cccc-333333333333' -Tenant '00000000-dddd-eeee-ffff-222222222222' | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Azure Aliases  |  CREATE ALIASES"
Set-Alias -Name azprod -Value Set-AzContextToProduction -Verbose
Set-Alias -Name aztest -Value Set-AzContextToTest -Verbose
Set-Alias -Name azdev  -Value Set-AzContextToDevelopment -Verbose
Get-Alias az* | Format-Table Name, Definition -AutoSize
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Azure Aliases  |  AFTER"
azprod
aztest
azdev
Reset-AliasDemo
Complete-Section
Wait-ForKeyPress

# Example 5 — go
Start-Section "EXAMPLE 5 — go  |  BEFORE"
Set-Location "$ENV:USERPROFILE\Documents" -Verbose | Out-Host
Set-Location "$ENV:USERPROFILE\Downloads" -Verbose | Out-Host
Set-Location "$ENV:TEMP" -Verbose | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 5 — go  |  DIR SHORTCUTS"
$DirShortcuts
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 5 — go  |  AFTER"
go documents
go downloads
go temp
Complete-Section
Wait-ForKeyPress

#endregion

#region 03 — Credential Management

Reset-CredDemo
New-Item -ItemType Directory -Path $CliXmlPath -Force | Out-Null
Start-Section "03 — Credential Management  |  SETUP COMPLETE"
Complete-Section
Wait-ForKeyPress

# Example 1 — The problem
Start-Section "EXAMPLE 1 — The Problem  |  PLAINTEXT"
$password = 'SuperSecret123!'
Write-Host "  Password: $password" -ForegroundColor Red
$cred = [pscredential]::new('contoso\svc-account', (ConvertTo-SecureString $password -AsPlainText -Force -Verbose))
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — The Problem  |  GET-CREDENTIAL"
Get-Credential -Message "Enter your service account credentials"
Complete-Section
Wait-ForKeyPress

# Example 2 — Export-Clixml
Start-Section "EXAMPLE 2 — Export-Clixml  |  SAVE"
$adminCred = Get-Credential -Message "Enter your service account credentials"
$adminCred | Export-Clixml -Path "$CliXmlPath\adminCred.xml" -Verbose
Write-Host "  Saved to $CliXmlPath\adminCred.xml`n" -ForegroundColor DarkGray
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — Export-Clixml  |  RAW FILE"
Get-Content "$CliXmlPath\adminCred.xml" | Out-Host
Complete-Section
Wait-ForKeyPress

# Example 3 — Import-Clixml
Start-Section "EXAMPLE 3 — Import-Clixml  |  LOAD"
$loaded = Import-Clixml -Path "$CliXmlPath\adminCred.xml" -Verbose
$loaded | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — Import-Clixml  |  VERIFY"
$loaded.UserName | Out-Host
$loaded.GetNetworkCredential().Password | Out-Host
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — Import-Clixml  |  USAGE"
Write-Host "  # Connect-AzAccount  -Credential `$loaded" -ForegroundColor DarkGray
Write-Host "  # Invoke-Command     -ComputerName server01 -Credential `$loaded -ScriptBlock { whoami }" -ForegroundColor DarkGray
Write-Host "  # Get-WmiObject      -ComputerName server01 -Credential `$loaded -Class Win32_BIOS`n" -ForegroundColor DarkGray
Complete-Section
Wait-ForKeyPress

# Example 4 — Profile pattern
Start-Section "EXAMPLE 4 — Profile Pattern  |  CREATE FILES"
[pscredential]::new('contoso\svc-account', (ConvertTo-SecureString 'Svc123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\svcCred.xml"
[pscredential]::new('contoso\api-account', (ConvertTo-SecureString 'Api123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\apiCred.xml"
[pscredential]::new('contoso\sql-account', (ConvertTo-SecureString 'Sql123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\sqlCred.xml"
Get-ChildItem $CliXmlPath
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Profile Pattern  |  IMPORT"
Import-CliXmlCredentials
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Profile Pattern  |  USE"
Get-LoadedCliXmlCredentials
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Profile Pattern  |  ADD NEW FILE"
[pscredential]::new('contoso\new-svc', (ConvertTo-SecureString 'New123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\newSvcCred.xml"
Get-ChildItem $CliXmlPath
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Profile Pattern  |  RE-IMPORT"
Import-CliXmlCredentials
Get-LoadedCliXmlCredentials
Complete-Section
Wait-ForKeyPress

#endregion

#region 04 — PSReadLine

Start-Section "04 — PSReadLine  |  SETUP COMPLETE"
Complete-Section
Wait-ForKeyPress

# Example 1 — Baseline
Start-Section "EXAMPLE 1 — Baseline  |  CURRENT OPTIONS"
Get-PSReadLineOption | Select-Object PredictionSource, PredictionViewStyle, HistoryNoDuplicates, HistorySearchCursorMovesToEnd, BellStyle
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Baseline  |  KEY BINDINGS"
Get-PSReadLineKeyHandler | Where-Object { $_.Key -match 'UpArrow|DownArrow|Tab' }
Complete-Section
Wait-ForKeyPress

# Example 2 — Predictive IntelliSense
Start-Section "EXAMPLE 2 — Predictive IntelliSense  |  ENABLE"
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Get-PSReadLineOption | Select-Object PredictionSource, PredictionViewStyle
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — Predictive IntelliSense  |  FULL CONFIG"
$psReadLineOptions = @{
    HistorySearchCursorMovesToEnd = $true
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    HistoryNoDuplicates           = $true
    BellStyle                     = 'None'
    DingTone                      = 0
}
Set-PSReadLineOption @psReadLineOptions
Complete-Section
Wait-ForKeyPress

# Example 3 — History search arrows
Start-Section "EXAMPLE 3 — History Search Arrows  |  BIND"
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Get-PSReadLineKeyHandler | Where-Object { $_.Key -match 'UpArrow|DownArrow' }
Complete-Section
Wait-ForKeyPress

# Example 4 — Colors
Start-Section "EXAMPLE 4 — Colors  |  CURRENT"
Get-PSReadLineOption | Select-Object -ExpandProperty Colors
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 4 — Colors  |  APPLY"
Set-PSReadLineOption -Colors @{
    Command          = 'Cyan'
    Parameter        = 'DarkCyan'
    String           = 'Yellow'
    Operator         = 'DarkGray'
    Variable         = 'Green'
    Number           = 'White'
    Member           = 'DarkYellow'
    InlinePrediction = "`e[38;5;240m"
    ListPrediction   = "`e[38;5;240m"
    Error            = "`e[31m"
}
Complete-Section
Wait-ForKeyPress

#endregion

#region 05 — Extras

Start-Section "05 — Extras  |  SETUP COMPLETE"
Complete-Section
Wait-ForKeyPress

# Example 1 — Start-Transcript
Start-Section "EXAMPLE 1 — Start-Transcript  |  BEFORE"
Start-Transcript -Path "$ENV:TEMP\transcript_$(Get-Date -Format 'yyyy-MM-dd').txt"
Stop-Transcript
Get-ChildItem "$ENV:TEMP\transcript_*.txt" | Select-Object Name, LastWriteTime
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Start-Transcript  |  SET DEFAULT"
$transcriptDir = "$ENV:USERPROFILE\Documents\Transcripts"
New-Item -ItemType Directory -Path $transcriptDir -Force | Out-Null
$PSDefaultParameterValues['Start-Transcript:Path'] = {
    "$ENV:USERPROFILE\Documents\Transcripts\$(Get-Date -Format 'yyyy-MM-dd').txt"
}
$PSDefaultParameterValues
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 1 — Start-Transcript  |  AFTER"
Start-Transcript
Stop-Transcript
Get-ChildItem "$ENV:USERPROFILE\Documents\Transcripts" | Select-Object Name, LastWriteTime
Complete-Section
Wait-ForKeyPress

# Example 2 — ErrorView
Start-Section "EXAMPLE 2 — ErrorView  |  BEFORE (NormalView)"
$ErrorView = 'NormalView'
Get-Item "C:\this\path\does\not\exist" -ErrorAction SilentlyContinue
$Error[0]
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — ErrorView  |  AFTER (ConciseView)"
$ErrorView = 'ConciseView'
Get-Item "C:\this\path\does\not\exist"
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 2 — ErrorView  |  CUSTOM COLOR"
Set-PSReadLineOption -Colors @{ Error = "`e[31m" }
Get-Item "C:\this\path\does\not\exist"
Complete-Section
Wait-ForKeyPress

# Example 3 — Custom prompt
Start-Section "EXAMPLE 3 — prompt  |  DEFAULT"
Get-Content Function:\prompt
Complete-Section
Wait-ForKeyPress

Start-Section "EXAMPLE 3 — prompt  |  CUSTOM"
function prompt {
    $path = $ExecutionContext.SessionState.Path.CurrentLocation
    $time = Get-Date -Format 'HH:mm:ss'
    $branch = ''
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $b = git branch --show-current 2>$null
        if ($b) { $branch = " `e[33m($b)`e[0m" }
    }
    "`n`e[36m$time`e[0m  `e[32m$path`e[0m$branch`n`e[0m> "
}
Get-Date
Set-Location $ENV:TEMP
Set-Location $ENV:USERPROFILE
Complete-Section
Wait-ForKeyPress

Start-Section "DEMO COMPLETE"
Complete-Section
#endregion