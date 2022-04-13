![img_license](https://img.shields.io/github/license/MichaelSchoenburg/ExchangeAdminLogPermissionChangeSearcher) ![img_version](https://img.shields.io/github/v/release/MichaelSchoenburg/ExchangeAdminLogPermissionChangeSearcher) ![GitHub last commit](https://img.shields.io/github/last-commit/michaelschoenburg/ExchangeAdminLogPermissionChangeSearcher) [![PSScriptAnalyzer](https://github.com/MichaelSchoenburg/ExchangeAdminLogPermissionChangeSearcher/actions/workflows/powershell.yml/badge.svg)](https://github.com/MichaelSchoenburg/ExchangeAdminLogPermissionChangeSearcher/actions/workflows/powershell.yml)

# ExchangeAdminLogPermissionChangeSearcher
A PowerShell script helping you to search for specific changes to permission documented in the Online Exchange Admin Log.
This script it cut out to search for permissions since it uses the parameters `User` and `Identity`.

This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.

Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/

Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1

# How to use
* Step 1: Log in to Exchange Online.
* Step 2: Specify the Cmdlet you want to search for.
* Step 3: Specify whether you want to search by the Cmdlets parameter `user` or `identity`.
* Step 4: Specify the value of saied parameter.
* Step 5: Receive a filterable and sortable table (GUI) with results.

## Example
**I want to see every log where someone has given the user "John" any level of permission to any mailbox:**

|Question|Answer|
|-|-|
|Cmdlet|Add-MailboxPermission|
|User|John|

---

**I want to see every log where someone has given somebody any level of permission to the public folder "Sales" (which has the identity "\Our Departments\Sales").**
|Question|Answer|
|-|-|
|Cmdlet|Add-PublicFolderClientPermission|
|Identity|\Our Departments\Sales|

(You mustn't add quotes in your answers)
