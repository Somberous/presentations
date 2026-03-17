# 01 — `$PSDefaultParameterValues`

---

## Example 1 — `Export-Csv`

In Windows PowerShell 5.1, `Export-Csv` adds a `#TYPE` header line and uses ASCII encoding by default. Both cause real problems — the header breaks imports and ASCII silently corrupts any non-English characters.

**Before — produce the file with no defaults set:**

```powershell
$beforeFile = "$ENV:TEMP\procs_before.csv"
$afterFile  = "$ENV:TEMP\procs_after.csv"

Start-Process powershell.exe -ArgumentList (
    "-NoProfile -Command `"Get-Process | Select-Object Name,CPU | Export-Csv '$beforeFile'`""
) -Wait -WindowStyle Hidden -WhatIf:$false

Show-FileEncoding $beforeFile
Get-Content $beforeFile | Select-Object -First 4
```

> **What is a BOM?**
>
> BOM stands for **Byte Order Mark** — a short invisible sequence of bytes at the very start of a file that tells any program reading it what encoding was used.
>
> For UTF-8 the BOM is always `0xEF 0xBB 0xBF`. You never see it as a character — editors strip it out — but it's there at the byte level.
>
> Without a BOM, programs have to guess. Older tools like Excel often fall back to Windows-1252, which is when `José` becomes `JosÃ©`.

**Set the defaults:**

```powershell
$PSDefaultParameterValues['Export-Csv:NoTypeInformation'] = $true
$PSDefaultParameterValues['Export-Csv:Encoding']          = 'UTF8'
$PSDefaultParameterValues
```

**After — same export, clean output:**

```powershell
Start-Process powershell.exe -ArgumentList (
    "-NoProfile -Command `"Get-Process | Select-Object Name,CPU | Export-Csv '$afterFile' -NoTypeInformation -Encoding UTF8`""
) -Wait -WindowStyle Hidden -WhatIf:$false

Show-FileEncoding $afterFile
Get-Content $afterFile | Select-Object -First 4
```

---

## Example 2 — `Get-ADUser`

By default `Get-ADUser` only returns about 10 properties. `EmailAddress`, `LastLogonDate`, `Manager` — all empty unless you remember `-Properties` every single time.

**Before — extended properties come back empty:**

```powershell
Get-ADUser -Filter { $_.SamAccountName -eq 'jsmith' } |
    Select-Object Name, EmailAddress, Department, Title, LastLogonDate
```

**Set the default:**

```powershell
$PSDefaultParameterValues['Get-ADUser:Properties'] = @(
    'EmailAddress', 'Department', 'Manager',
    'Title', 'LastLogonDate', 'PasswordLastSet', 'Enabled'
)
$PSDefaultParameterValues
```

**After — same command, fully populated. Works for every subsequent query too:**

```powershell
Get-ADUser -Filter { $_.SamAccountName -eq 'jsmith' } |
    Select-Object Name, EmailAddress, Department, Title, LastLogonDate

Get-ADUser -Filter { $_.SamAccountName -eq 'fjones' } |
    Select-Object Name, EmailAddress, Department, Title, LastLogonDate
```

---

## Example 3 — `Connect-MgGraph`

If you work with Microsoft Graph regularly you're copying the same scope list at the start of every single session.

**Before — full scope list every session:**

```powershell
Connect-MgGraph -Scopes 'User.Read.All', 'Group.Read.All', 'Directory.Read.All', 'AuditLog.Read.All'
```

**Set the default:**

```powershell
$PSDefaultParameterValues['Connect-MgGraph:Scopes'] = @(
    'User.Read.All', 'Group.Read.All',
    'Directory.Read.All', 'AuditLog.Read.All'
)
$PSDefaultParameterValues
```

**After — just connect:**

```powershell
Connect-MgGraph
```

---

## Example 4 — `*:WhatIf`

The `*` wildcard applies `WhatIf` to every command in the session at once — nothing executes, everything just previews.

**Before — these execute for real:**

```powershell
'placeholder' | Out-File "$ENV:TEMP\demo-delete-me.txt" -WhatIf:$false
'placeholder' | Out-File "$ENV:TEMP\demo-rename-me.txt" -WhatIf:$false

Remove-Item "$ENV:TEMP\demo-delete-me.txt" -WhatIf:$false
Rename-Item "$ENV:TEMP\demo-rename-me.txt" "$ENV:TEMP\demo-renamed.txt" -WhatIf:$false
Write-Host "  Done — files are gone for real.`n" -ForegroundColor DarkGray
```

**Set the default:**

```powershell
$PSDefaultParameterValues['*:WhatIf'] = $true
$PSDefaultParameterValues
```

**After — same commands, only preview:**

```powershell
'placeholder' | Out-File "$ENV:TEMP\demo-delete-me.txt" -WhatIf:$false
'placeholder' | Out-File "$ENV:TEMP\demo-rename-me.txt" -WhatIf:$false

Remove-Item "$ENV:TEMP\demo-delete-me.txt"
Rename-Item "$ENV:TEMP\demo-rename-me.txt" "$ENV:TEMP\demo-renamed.txt"
Copy-Item   "$ENV:TEMP\demo-rename-me.txt" "$ENV:TEMP\demo-copy.txt"
```

---

## Example 5 — ScriptBlock value

A default doesn't have to be a static value — it can be a ScriptBlock evaluated fresh every time the command runs.

**Check current terminal width first:**

```powershell
$Host.UI.RawUI.WindowSize.Width
```

**Before — `Path` column truncated on a narrow terminal:**

```powershell
Get-Process |
    Select-Object Name, CPU, Id, Path |
    Sort-Object CPU -Descending |
    Select-Object -First 10 |
    Format-Table
```

**Set the default — `Wrap` fires automatically when terminal is narrow:**

```powershell
$PSDefaultParameterValues['Format-Table:Wrap'] = {
    if ($Host.UI.RawUI.WindowSize.Width -lt 120) { $true }
}
$PSDefaultParameterValues
```

**After — resize terminal narrow and run. Widen past 120 and run again. Same command, different behaviour.**

```powershell
Get-Process |
    Select-Object Name, CPU, Id, Path |
    Sort-Object CPU -Descending |
    Select-Object -First 10 |
    Format-Table
```