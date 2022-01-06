<#
.SYNOPSIS
     ExchangeAdminLogPermissionChangeSearcher
.DESCRIPTION
    A PowerShell script helping you to search for specific changes to permission documented in the Online Exchange Admin Log. 
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Author: Michael Schönburg
    Version: 1.0
    Last Change: 06.01.2022
    GitHub Repository: https://github.com/MichaelSchoenburg/ExchangeAdminLogPermissionChangeSearcher

    This projects code loosely follows the PowerShell Practice and Style guide*, as well as Microsofts PowerShell scripting performance considerations**.
    * https://poshcode.gitbook.io/powershell-practice-and-style/
    ** https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
#>

#region INITIALIZATION

using namespace System.Management.Automation.Host

#endregion INITIALIZATION
#region FUNCTIONS

function New-Menu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Question,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ChoiceA,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ChoiceB
    )
    
    $a = [ChoiceDescription]::new("&$( $ChoiceA )", '')
    $b = [ChoiceDescription]::new("&$( $ChoiceB )", '')

    $options = [ChoiceDescription[]]($a, $b)

    $result = $host.ui.PromptForChoice($title, $question, $options, 0)

    return $result
}

function Get-CustomLogEntry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [psobject]
        $logEntry
    )

    $r = $logEntry
    $IndexIdentity = $r.CmdletParameters.Name.indexof("Identity")
    $IndexUser = $r.CmdletParameters.Name.indexof("User")
    $IndexAccessRights = $r.CmdletParameters.Name.indexof("AccessRights")
    $IndexErrorAction = $r.CmdletParameters.Name.indexof("ErrorAction")
    if ($IndexErrorAction -eq -1) {
        # The parameter ErrorAction has not been specified -> only possible when using PowerShell
        $ErrorAction = ''
        $DefinitelyRanFromShell = $true
    } else {
        # The parameter "ErrorAction" has been specified -> could have been the Exchange Admin Center, as well as PowerShell.
        $ErrorAction = $r.CmdletParameters.Value[$IndexErrorAction]
        # The Exchange Admin Center always specifies "Stop" for the parameter "ErrorAction".
        if ($ErrorAction -ne 'Stop') {
            $DefinitelyRanFromShell = $true            
        } else {
            $DefinitelyRanFromShell = $false
        }
    }

    $object = [pscustomobject]@{
        RunDate = $r.RunDate
        Caller = $r.Caller
        DefinitelyRanFromShell = $DefinitelyRanFromShell
        Cmdlet = $r.CmdletName
        Identity = $r.CmdletParameters.Value[$IndexIdentity]
        User = $r.CmdletParameters.Value[$IndexUser]
        AccessRights = $r.CmdletParameters.Value[$IndexAccessRights]
        ErrorAction = $ErrorAction
    }
    
    return $object
}

function Get-FromEntry {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [psobject]
        $CmdletParameters,

        [Parameter(Mandatory)]
        [ValidateSet("User", "Identity")]
        [string]
        $Property
    )

    process {
        switch ($Property) {
            "User" {
                $IndexUser = $cmdletParameters.Name.indexof("User")
                $user = $cmdletParameters.Value[$IndexUser]
                return $user
            }
            "Identity" {
                $IndexPF = $cmdletParameters.Name.indexof("Identity")
                $pf = $cmdletParameters.Value[$IndexPF]
                return $pf
            }
        }
        
    }
}

function Get-FilteredLog {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [psobject]
        $LogEntries,

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [string]
        $SearchString
    )

    process {
        $return = @()

        foreach ($logEntry in $LogEntries) {
            if ($logEntry.CmdletParameters.Value -contains $SearchString) {
                $customLogEntry = Get-CustomLogEntry -LogEntry $logEntry
                $return += $customLogEntry
            }
        }

        return $return
    }
}

#endregion FUNCTIONS
#region DECLARATIONS

$Out = @()

#endregion DECLARATIONS
#region EXECUTION

Connect-ExchangeOnline

$Cmdlet = Read-Host "Cmdlet"
$LogEntries = Search-AdminAuditLog -Cmdlets $Cmdlet

$Choice = New-Menu -Title 'Exchange Log Filterer' -Question 'Do you want to search by user or by identity?' -ChoiceA 'User' -ChoiceB 'Identity'
switch ($Choice) {
    0 {
        $listUsers = $LogEntries | Get-FromEntry -Property User | Get-Unique
        $user = $listUsers | Out-GridView -PassThru -Title "Choose a User"

        $Out = Get-FilteredLog -SearchString $user -LogEntries $LogEntries
    }
    1{
        $listIdentities = $LogEntries | Get-FromEntry -Property Identity | Get-Unique
        $identity = $listIdentities | Out-GridView -PassThru -Title "Choose an Identity"

        $Out = Get-FilteredLog -SearchString $identity -LogEntries $LogEntries
    }
}

$Out | Out-GridView

#endregion EXECUTION
