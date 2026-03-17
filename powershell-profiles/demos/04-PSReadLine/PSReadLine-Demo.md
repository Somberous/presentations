# 04 — PSReadLine

---

## Example 1 — The baseline

Before changing anything, show what PSReadLine currently looks like and what options are available to configure.

**See the current configuration:**

```powershell
Get-PSReadLineOption | Select-Object PredictionSource, PredictionViewStyle, HistoryNoDuplicates, HistorySearchCursorMovesToEnd, BellStyle
```

**See all key bindings — notice UpArrow is just `PreviousHistory` by default:**

```powershell
Get-PSReadLineKeyHandler | Where-Object { $_.Key -match 'UpArrow|DownArrow|Tab' }
```

> **Try it live:** Press `Up Arrow` a few times. It cycles through history in order — no filtering, no intelligence. If you ran 50 commands today you're scrolling through all of them to find one.

---

## Example 2 — Predictive IntelliSense

`PredictionSource = 'History'` enables inline suggestions as you type. `PredictionViewStyle = 'ListView'` shows a dropdown of matching history entries rather than a single inline ghost suggestion.

**Enable prediction:**

```powershell
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Get-PSReadLineOption | Select-Object PredictionSource, PredictionViewStyle
```

> **Try it live:** Start typing any command you've run before — `Get-`, `Import-`, `Connect-` — and watch the dropdown appear. Use `Up/Down` to navigate the suggestions, `Tab` or `Right Arrow` to accept one.
>
> The suggestions come entirely from your local history file — nothing is sent anywhere.

**The full options block from `$PROFILE`:**

```powershell
$psReadLineOptions = @{
    HistorySearchCursorMovesToEnd = $true
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    HistoryNoDuplicates           = $true
    BellStyle                     = 'None'
    DingTone                      = 0
}
Set-PSReadLineOption @psReadLineOptions
```

> `HistoryNoDuplicates` stops the same command appearing multiple times in the dropdown. `BellStyle = 'None'` kills the beep. `HistorySearchCursorMovesToEnd` puts your cursor at the end of the line when you accept a history entry rather than leaving it where it was in the original command.

---

## Example 3 — History search on arrow keys

By default `UpArrow` gives you `PreviousHistory` — pure sequential cycling. Binding it to `HistorySearchBackward` instead makes it context-aware: it only returns entries that _start with whatever you've already typed_.

**Rebind the arrow keys:**

```powershell
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Get-PSReadLineKeyHandler | Where-Object { $_.Key -match 'UpArrow|DownArrow' }
```

> **Try it live:** Type `Get-` then press `Up Arrow`. Only commands that started with `Get-` come back. Type `Connect-` and press `Up Arrow` — only `Connect-` commands. This alone saves more time per day than almost any other profile change.

---

## Example 4 — Colors

`Set-PSReadLineOption -Colors` lets you restyle the entire terminal palette — syntax highlighting, prediction ghost text, error underlining, string colors, keyword colors, everything.

**See what colors are currently set:**

```powershell
Get-PSReadLineOption | Select-Object -ExpandProperty Colors
```

**Set a custom color scheme:**

```powershell
Set-PSReadLineOption -Colors @{
    Command            = 'Cyan'
    Parameter          = 'DarkCyan'
    String             = 'Yellow'
    Operator           = 'DarkGray'
    Variable           = 'Green'
    Number             = 'White'
    Member             = 'DarkYellow'
    InlinePrediction   = "`e[38;5;240m"     # dark gray ghost text
    ListPrediction     = "`e[38;5;240m"     # dark gray dropdown
    Error              = "`e[31m"           # red without the default bright background
}
```

> The `InlinePrediction` and `ListPrediction` values use ANSI escape codes (`\e[38;5;240m`) which gives you access to the full 256-color palette, not just the 16 named colors.