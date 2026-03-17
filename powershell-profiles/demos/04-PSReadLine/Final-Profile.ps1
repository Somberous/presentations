#######################################################
#  Final-Profile.ps1  —  04-PSReadLine
#  Copy this block into your $PROFILE.
#
#  To open your profile:  notepad $PROFILE
#######################################################


# ── PSReadLine options ────────────────────────────────────────────────────────

$psReadLineOptions = @{
    HistorySearchCursorMovesToEnd = $true
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    HistoryNoDuplicates           = $true
    BellStyle                     = 'None'
    DingTone                      = 0
}
Set-PSReadLineOption @psReadLineOptions


# ── History search on arrow keys ──────────────────────────────────────────────

Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward


# ── Color scheme ─────────────────────────────────────────────────────────────

Set-PSReadLineOption -Colors @{
    Command            = 'Cyan'
    Parameter          = 'DarkCyan'
    String             = 'Yellow'
    Operator           = 'DarkGray'
    Variable           = 'Green'
    Number             = 'White'
    Member             = 'DarkYellow'
    InlinePrediction   = "`e[38;5;240m"
    ListPrediction     = "`e[38;5;240m"
    Error              = "`e[31m"
}
