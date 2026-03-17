# 05 — Extras

> Other items if I have more time (30 minutes will probably not be enough)

---

## Example 1 — `Start-Transcript` with a dated path

`Start-Transcript` logs everything in your session to a file — every command, every output. Incredibly useful for auditing, troubleshooting, or just remembering what you did last Tuesday.

The problem is you have to manually construct a dated filename every time, or every session overwrites the same file.

**Before — manual path construction every session:**

```powershell
Start-Transcript -Path "$ENV:TEMP\transcript_$(Get-Date -Format 'yyyy-MM-dd').txt"
Stop-Transcript

Get-ChildItem "$ENV:TEMP\transcript_*.txt" | Select-Object Name, LastWriteTime
```

**Set the default — ScriptBlock evaluates the date fresh each session:**

```powershell
$transcriptDir = "$ENV:USERPROFILE\Documents\Transcripts"
New-Item -ItemType Directory -Path $transcriptDir -Force | Out-Null

$PSDefaultParameterValues['Start-Transcript:Path'] = {
    "$ENV:USERPROFILE\Documents\Transcripts\$(Get-Date -Format 'yyyy-MM-dd').txt"
}
$PSDefaultParameterValues
```

> A static value would hardcode today's date at the time you set the default — every transcript would go to the same file forever. Because it's a ScriptBlock, the date is evaluated fresh each time `Start-Transcript` runs.

**After — no path needed, today's date is always used:**

```powershell
Start-Transcript
Stop-Transcript
Write-Host ""
Get-ChildItem "$ENV:USERPROFILE\Documents\Transcripts" | Select-Object Name, LastWriteTime
```

---

## Example 2 — `$ErrorView` and custom error colors

By default PowerShell prints errors as a wall of red. `$ErrorView = 'ConciseView'` cuts that down to the two or three lines that are actually useful.

**Before — default `NormalView`:**

```powershell
$ErrorView = 'NormalView'
Get-Item "C:\this\path\does\not\exist"
```

**After — `ConciseView`:**

```powershell
$ErrorView = 'ConciseView'
Get-Item "C:\this\path\does\not\exist"
```

> `ConciseView` is the default in PS7 but not in 5.1. Worth setting explicitly so it's consistent everywhere. `DetailedView` goes the other way and includes the full stack trace — useful when actively debugging.

**Custom error color — remove the bright red background:**

```powershell
Set-PSReadLineOption -Colors @{ Error = "`e[31m" }
Get-Item "C:\this\path\does\not\exist"
```

> The default error rendering uses a bright red background block which is visually aggressive. `\e[31m` is plain red foreground text — same signal, much less noise.

---

## Example 3 — Custom `prompt` function

The `prompt` function is just a regular PowerShell function that returns a string. PowerShell calls it before every line. Override it in your `$PROFILE` and you control exactly what your prompt looks like.

**See the default prompt function:**

```powershell
Get-Content Function:\prompt
```

**A clean custom prompt with path, git branch, and time:**

```powershell
function prompt {
    $path     = $ExecutionContext.SessionState.Path.CurrentLocation
    $time     = Get-Date -Format 'HH:mm:ss'
    $branch   = ''

    # Show git branch if we're inside a repo
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $b = git branch --show-current 2>$null
        if ($b) { $branch = " `e[33m($b)`e[0m" }
    }

    "`n`e[36m$time`e[0m  `e[32m$path`e[0m$branch`n`e[0m> "
}

# watch the prompt update
Get-Date
Set-Location $ENV:TEMP
Set-Location $ENV:USERPROFILE
```

> The `prompt` function can do anything — run a command, check an API, read a file. The only rule is it must return a string. ANSI escape codes (`\e[32m` = green, `\e[33m` = yellow, `\e[0m` = reset) handle the coloring without any external modules.
>
> If you use **Oh My Posh** or **Starship** they work by replacing this same `prompt` function — so understanding the underlying mechanism means you can always fall back or customise further.