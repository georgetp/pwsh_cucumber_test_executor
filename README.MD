# Test executor for .feature files in PowerShell
## Short Description
This is a graphical .feature file parser that can help you construct the final command in order to execute your tests.
Some of the functionality needs to be implemented inside the .\scripts\runTestCase.ps1.
Of course you can create your own "runTestCase.ps1".
This one was created for demonstration purposes and no command is executed.
Feel free to keep it if you like and make the changes at the lines marked with "# !!" in order to make it fully functional.

## Prerequisites
- Windows OS
- PowerShell v5.1 or above
- 7zip installed ( https://www.7-zip.org/download.html )
- Add 7zip folder to system PATH
- Git installed  ( https://git-scm.com/downloads )

## Make it work
- Start PowerShell
- Choose the folder you want to clone this repository
- git clone https://github.com/georgetp/pwsh_test_executor_for_feature_files.git
- cd pwsh_test_executor_for_feature_files\Tools
- .\form_runTestCase.ps1

On the first run the configuration window will appear.

### "Scripts Path"
The value for this should be <checkOutFolder>\pwsh_test_executor_for_feature_files\Tools\scriptsPath

### "Feature files folder path"
The value for this should be the folder that contains the ".feature" files.
To make it work you can initially set the value to <checkOutFolder>\pwsh_test_executor_for_feature_files\Cucumber\features and change it later.

### "Test Execution Tool Folder"
The value for this should be the folder that you are currently running your tests from.
To make it work you can initially set the value to <checkOutFolder>\pwsh_cucumber_test_executor and change it later.

### "Test Results Folder"
The value for this should be the folder you want to keep your test results.
To make it work you can initially set the value to <checkOutFolder>\pwsh_cucumber_test_executor\TestResults and change it later.

## Run from any folder
- Add a system variable with name "TOOLS_PATH"
- Set the 'Variable value' field value to be the full path of 'Tools' folder. e.g 'C:\pwsh_cucumber_test_executor\Tools'
- Add the "TOOLS_PATH" variable to the "Path".
- Restart system for the changes to be applied
- Start PowerShell
- form_runTestCase.ps1

##  Screenshots
![alt text](https://github.com/georgetp/pwsh_test_executor_for_feature_files/blob/master/Screenshots/main_window.JPG?raw=true)

![alt text](https://github.com/georgetp/pwsh_test_executor_for_feature_files/blob/master/Screenshots/Configure_Folders_Screen.JPG?raw=true)


# Hope you like it and ENJOY .. :)
