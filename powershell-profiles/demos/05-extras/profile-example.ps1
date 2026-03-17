$azureSAAccountID = "example@example.com"

$Global:DirShortcuts = @{
    terraform = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\code\terraform"
    scripts   = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\PowerShell\Scripts"
    docs      = [System.IO.DirectoryInfo]"$env:OneDrive\Documents"
    clixml    = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\code\clixml"
    creds     = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\code\clixml"
    code      = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\code"
    git       = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\code\git"
}

$cliXMLPath = [System.IO.DirectoryInfo]"$env:OneDrive\Documents\code\clixml"

$mainTenantAzureInfo = @(
    #  Cat Main Tenant
    [PSCustomObject]@{
        Environment      = 'Prod'
        EnvironmentShort = 'Production'
        SubscriptionName = 'Prod'
        SubscriptionId   = ''
        TenantId         = ''
    },
    [PSCustomObject]@{
        Environment      = 'Test'
        EnvironmentShort = 'Test'
        SubscriptionName = 'Test'
        SubscriptionId   = ''
        TenantId         = ''
    },
    [PSCustomObject]@{
        Environment      = 'Development'
        EnvironmentShort = 'Development'
        SubscriptionName = 'Development'
        SubscriptionId   = ''
        TenantId         = ''
    }
)

$extraTenantAzureInfo = @(
    [PSCustomObject]@{
        Environment = 'Test Tenant'
        TenantId    = ''
    },
    [PSCustomObject]@{
        Environment = 'Development Tenant'
        TenantId    = ''
    }
)
#endregion Variables

#region Functions

#region CLI XML Functions

function Import-CliXmlCredentials {
    <#
    .SYNOPSIS
    Imports all CLI XML credential files into global variables for the current system that is in use.
    #>
    try {
        $cliXMLFiles = Get-ChildItem -Path $cliXMLPath -ErrorAction Stop

        foreach ($cliXMLFile in $cliXMLFiles) {
            try {
                $baseName = $cliXMLFile.BaseName
                
                # Check if this is a VDI-specific credential file
                if ($baseName.EndsWith('-vdi')) {
                    if ($env:COMPUTERNAME -match 'VDI') {
                        $variableName = $baseName.TrimEnd('-vdi')
                        $credential = Import-Clixml -Path $cliXMLFile.FullName
                        New-Variable -Name $variableName -Value $credential -Scope Global -Force
                    }
                }
                # Handle non-VDI credential files
                else {
                    if ($env:COMPUTERNAME -notmatch 'VDI') {
                        $variableName = $baseName
                        $credential = Import-Clixml -Path $cliXMLFile.FullName
                        New-Variable -Name $variableName -Value $credential -Scope Global -Force
                    }
                }
            }
            catch {
                Write-Warning "Failed to import: $($cliXMLFile.FullName) — $_"
            }
        }
    }
    catch {
        Write-Error "Could not retrieve CLI XML files from $cliXMLPath — $_"
    }
}

function Get-LoadedCliXmlCredentials {
    <#
    .SYNOPSIS
    Lists currently loaded credential variables.
    #>
    Get-Variable | Where-Object { $_.Value -is [pscredential] } | Select-Object Name
}

function New-CliXmlEntry {
    <#
    .SYNOPSIS
    Creates a new credential XML file.

    .DESCRIPTION
    Creates and exports a PSCredential object to an XML file for secure storage.

    .PARAMETER Path
    The directory path where the XML file will be saved. Defaults to $cliXMLPath.

    .PARAMETER Name
    The name of the credential entry (used as filename).

    .PARAMETER Credential
    Optional PSCredential object. If not provided, will prompt for credentials.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.IO.DirectoryInfo]$Path = $cliXMLPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [pscredential]$Credential
    )

    if (-not $Credential) {
        $Credential = Get-Credential -Message "Enter the credentials you wish to save"
    }

    Export-Clixml -Path (Join-Path -Path $Path.FullName -ChildPath "$Name.xml") -InputObject $Credential
    Write-Output "Credential exported to $($Path.FullName)\$Name.xml" -ForegroundColor Cyan
}

function Remove-CliXmlCredentials {
    <#
    .SYNOPSIS
    Removes all loaded CLI XML credential variables from the session.
    #>
    $variables = Get-LoadedCliXmlCredentials
    foreach ($var in $variables) {
        Remove-Variable -Name $var.Name -Scope Global -ErrorAction SilentlyContinue
    }
    Write-Output "Cleared loaded CLI XML credentials." -ForegroundColor Cyan
}

#endregion CLI XML Functions

#region Azure Functions
function Set-AzContextTo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Production', 'Test', 'Development')]
        [string]$Environment
    )

    $environmentInfo = $mainTenantAzureInfo | Where-Object -FilterScript { $_.EnvironmentShort -like $Environment }

    if (-not $environmentInfo.SubscriptionId) {
        Write-Output "Subscription ID not found for environment '$Environment'."
        return
    }

    Write-Output "Attempting to connect to Azure for environment '$($environmentInfo.Environment)' with Subscription ID '$($environmentInfo.SubscriptionId)'..."
    Connect-AzAccount -Subscription $environmentInfo.SubscriptionId -Tenant $environmentInfo.TenantId -AccountId $azureSAAccountID
    $currentContext = Get-AzContext

    # If no context (e.g., login canceled)
    if (-not $currentContext) {
        Write-Output "Could not establish an Azure connection."
        return
    }
}

function Get-AllTenantAzureInfo {
    <#
    .SYNOPSIS
        Displays comprehensive Azure tenant and subscription information in organized format.

    .DESCRIPTION
        Outputs main production tenant subscriptions and additional tenant configurations
        in a visually appealing, organized table format with color-coded sections.

    .EXAMPLE
        PS> Get-AllTenantAzureInfo

        DESCRIPTION: Displays all configured Azure environments and tenants
    #>
    
    Write-Host "`n"
    Write-Host "╔════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    AZURE TENANT & SUBSCRIPTION INFORMATION                     ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # Main Tenant Information
    Write-Host "📋 MAIN TENANT SUBSCRIPTIONS ( Catastrophe Services)" -ForegroundColor Yellow
    Write-Host "─────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    
    $mainTenantAzureInfo | Format-Table -Property @(
        @{ Label = "Environment"; Expression = { $_.Environment }; Width = 40 }
        @{ Label = "Subscription ID"; Expression = { $_.SubscriptionId }; Width = 36 }
        @{ Label = "Tenant ID"; Expression = { $_.TenantId }; Width = 36 }
    ) -AutoSize -ErrorAction SilentlyContinue
    
    Write-Host ""
    
    # Additional Tenants Information
    Write-Host "🔐 ADDITIONAL TENANTS (External CIAM & Test Environments)" -ForegroundColor Magenta
    Write-Host "─────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    
    $extraTenantAzureInfo | Format-Table -Property @(
        @{ Label = "Environment"; Expression = { $_.Environment }; Width = 45 }
        @{ Label = "Tenant ID"; Expression = { $_.TenantId }; Width = 36 }
    ) -AutoSize -ErrorAction SilentlyContinue
    
    Write-Host ""
    
    # Dynamic Azure Context Aliases
    Write-Host "⚡ AVAILABLE CONTEXT COMMANDS" -ForegroundColor Green
    Write-Host "─────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    
    $azAliases = Get-Alias | Where-Object -FilterScript { $_.Name -like "az*" } | Sort-Object Name
    
    if ($azAliases) {
        $azAliases | Format-Table -Property @(
            @{ Label = "Alias"; Expression = { $_.Name }; Width = 15 }
            @{ Label = "Command"; Expression = { $_.Definition }; Width = 30 }
        ) -AutoSize
    }
    
    Write-Host ""
    Write-Host "╔═════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Example: azprod, aztest, azdev, or Set-AzContextTo -Environment Development     ║" -ForegroundColor Cyan
    Write-Host "║  Or Use Set-AzContextToProduction, Set-AzContextToTest, Set-AzContextToDevelopment  ║" -ForegroundColor Cyan
    Write-Host "╚═════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Set-AzContextToProduction { Set-AzContextTo -Environment Production }
function Set-AzContextToTest { Set-AzContextTo -Environment Test }
function Set-AzContextToDevelopment { Set-AzContextTo -Environment Development }

#endregion Azure Functions

#region Misc Functions

function go {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Name
    )

    if ($DirShortcuts.ContainsKey($Name)) {
        Set-Location $DirShortcuts[$Name]
        Write-Host "📂 Changed directory to '$Name': $($DirShortcuts[$Name])" -ForegroundColor Green
    }
    else {
        Write-Warning "No shortcut named '$Name' found. Available shortcuts:"
        $DirShortcuts.Keys | Sort-Object | ForEach-Object { " - $_" }
    }
}

#endregion Misc Functions

#endregion Functions

#region Configuration

#region Jira Config Setup
Set-JiraConfigServer -Server "https://<example>.atlassian.net"
#endregion Jira Config Setup

#region Confluence Config Setup
Import-Module ConfluencePS -Force
Set-ConfluenceInfo -BaseURI 'https://<example>.atlassian.net/wiki'
#endregion Confluence Config Setup

#region PSReadLine Setup

# Configure PSReadLine options
$psReadLineOptions = @{
    HistorySearchCursorMovesToEnd = $true
    PredictionSource              = 'History'
    PredictionViewStyle           = 'ListView'
    HistoryNoDuplicates           = $true
    BellStyle                     = 'None'
    DingTone                      = 0
}
Set-PSReadLineOption @psReadLineOptions

# History search and navigation key handlers
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

#endregion PSReadLine Setup

#region Tab Completion Setup

# Directory Tool
Register-ArgumentCompleter -CommandName go -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    $DirShortcuts.Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

#endregion Tab Completion Setup

#region Set CLI XML Credentials
Import-CliXmlCredentials
#endregion Set CLI XML Credentials

#region Aliases

# Context Aliases
Set-Alias -Name azprod -Value Set-AzContextToProduction
Set-Alias -Name aztest -Value Set-AzContextToTest
Set-Alias -Name aztst -Value Set-AzContextToTest
Set-Alias -Name azstage -Value Set-AzContextToTest
Set-Alias -Name azdev  -Value Set-AzContextToDevelopment

# Subscription Info Aliases

Set-Alias -Name azinfo -Value Get-AllTenantAzureInfo

#endregion Aliases

#endregion Configuration