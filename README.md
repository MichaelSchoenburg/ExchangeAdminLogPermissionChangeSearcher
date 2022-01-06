# ExchangeAdminLogPermissionChangeSearcher
A PowerShell script helping you to search for specific changes to permission documented in the Online Exchange Admin Log.

This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.

Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/

Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1

# How to use
* Step 1: Log in to Exchange Online.
* Step 2: Specify the Cmdlet you want to search for.
* Step 3: Specify whether you want to search by the Cmdlets parameter "user" or "identity".
* Step 4: Specify the value of saied parameter.
* Step 5: Receive a filterable and sortable table (GUI) with results.
