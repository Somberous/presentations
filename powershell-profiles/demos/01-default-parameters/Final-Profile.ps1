#######################################################
#  Copy this block into your $PROFILE to make all of
#  today's defaults load automatically every session.
#
#  To open your profile:  notepad $PROFILE
#  Or whatever editor you prefer — it's just a text file.
#######################################################

#region PSDefaultParameterValues

$PSDefaultParameterValues = @{

    # Exports & encoding
    'Export-Csv:NoTypeInformation' = $true
    'Export-Csv:Encoding'          = 'UTF8'
    'Out-File:Encoding'            = 'UTF8'

    # Active Directory — always return the properties you actually need
    'Get-ADUser:Properties'        = @(
        'EmailAddress',
        'Department',
        'Manager',
        'Title',
        'LastLogonDate',
        'PasswordLastSet',
        'Enabled'
    )

    # Microsoft Graph — never copy-paste your scope list again
    'Connect-MgGraph:Scopes'       = @(
        'User.Read.All',
        'Group.Read.All',
        'Directory.Read.All',
        'AuditLog.Read.All'
    )

    # Auto-format tables in the terminal only, not in editors
    'Format-Table:AutoSize'        = { if ($Host.Name -eq 'ConsoleHost') { $true } }

    # Uncomment to turn on verbose output across everything
    # '*:Verbose'                       = $true
}

#endregion PSDefaultParameterValues