# 03 — Credential Management

---

## Example 1 — The problem

Two ways people handle credentials badly.

**Option A — plaintext password hardcoded in a script:**

```powershell
$password = 'SuperSecret123!'
$cred = [pscredential]::new('contoso\svc-account', (ConvertTo-SecureString $password -AsPlainText -Force))
$cred
```

**Option B — `Get-Credential` prompt every time:**

```powershell
Get-Credential -Message "Enter your service account credentials"
```

---

## Example 2 — `Export-Clixml`: saving a credential securely

**Create and export a credential:**

```powershell
$demoPassword = ConvertTo-SecureString 'DemoPassword123!' -AsPlainText -Force
$adminCred    = [pscredential]::new('contoso\admin', $demoPassword)

$adminCred | Export-Clixml -Path "$CliXmlPath\adminCred.xml"
Write-Host "  Saved to $CliXmlPath\adminCred.xml`n" -ForegroundColor DarkGray
```

**Look at the raw file on disk:**

```powershell
Get-Content "$CliXmlPath\adminCred.xml"
```

> **Why is this safe?**
>
> `Export-Clixml` encrypts the password using the **Windows Data Protection API (DPAPI)**. The key is derived from your Windows user account — only you, logged in as you, on this machine, can decrypt it.
>
> Copy the file to another machine — unreadable. Another user on the same machine — unreadable. The username is visible in the XML. Only the password is encrypted.

---

## Example 3 — `Import-Clixml`: loading it back

**Import and inspect:**

```powershell
$loaded = Import-Clixml -Path "$CliXmlPath\adminCred.xml"
$loaded
```

**Prove the round-trip — username and password both intact:**

```powershell
$loaded.UserName
$loaded.GetNetworkCredential().Password
```

**Pass it to any cmdlet that accepts `-Credential`:**

```powershell
# Connect-AzAccount  -Credential $loaded
# Invoke-Command     -ComputerName server01 -Credential $loaded -ScriptBlock { whoami }
# Get-WmiObject      -ComputerName server01 -Credential $loaded -Class Win32_BIOS
Write-Host "  `$loaded is ready to pass to any -Credential parameter.`n" -ForegroundColor DarkGray
```

---

## Example 4 — The profile pattern: dynamic auto-loading

The filename becomes the variable name — so naming your file `adminCred.xml` means `$adminCred` is what loads into your session.

**Create several credential files:**

```powershell
[pscredential]::new('contoso\svc-account', (ConvertTo-SecureString 'Svc123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\svcCred.xml"
[pscredential]::new('contoso\api-account', (ConvertTo-SecureString 'Api123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\apiCred.xml"
[pscredential]::new('contoso\sql-account', (ConvertTo-SecureString 'Sql123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\sqlCred.xml"

Get-ChildItem $CliXmlPath
```

**One function call loads everything:**

```powershell
Import-CliXmlCredentials
```

**Every credential available by name — no prompts, no hardcoding:**

```powershell
Get-LoadedCliXmlCredentials

$svcCred
$apiCred
$sqlCred
```

---

### The dynamic part

The whole point — drop a new file in the folder, restart PowerShell, it's automatically there. No profile changes needed.

**Add a new file:**

```powershell
[pscredential]::new('contoso\new-svc', (ConvertTo-SecureString 'New123!' -AsPlainText -Force)) | Export-Clixml "$CliXmlPath\newSvcCred.xml"

Get-ChildItem $CliXmlPath
```

**Same function, no profile changes — picks it up automatically:**

```powershell
Import-CliXmlCredentials
Get-LoadedCliXmlCredentials
```