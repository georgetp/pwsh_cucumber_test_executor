# Cucumber Test executor tool in Powershell

## Prerequisites
- Windows OS
- PowerShell v5.1 or above
- 7zip installed ( https://www.7-zip.org/download.html )
- Git installed  ( https://git-scm.com/downloads )

## Make it work
 - Choose the folder you want to clone this repo
 - git clone https://github.com/georgetp/pwsh_cucumber_test_executor.git
 - Start PowerShell
 - cd Tools
 - .\form_runTestCase.ps1

## Run from any folder
 - Add a system variable with name "TOOLS_PATH"
 - Set the 'Variable value' field value to be the full path of 'Tools' folder. e.g 'C:\pwsh_cucumber_test_executor\Tools'
 - Add the "TOOLS_PATH" variable to the "Path".
 - Restart system for the changes to be applied
 - Start PowerShell
 - .\form_runTestCase.ps1

