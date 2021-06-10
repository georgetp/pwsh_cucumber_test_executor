function readGlobals() {
  $global_vars_file = ".\json\global_vars.json"

  if ( Test-Path -Path "$global_vars_file" ) {
    $config = Get-Content "$global_vars_file" | ConvertFrom-Json
  } else {
    write-error "Unable to find $global_vars_file"
  }

  return $config
}

function readConfiguration() {
  $global_vars = readGlobals
  $config_file = "$HOME\$($global_vars.configFileName)"
  $config = @{scriptsPath=""; feature_files_path=""; test_execution_tool_path=""; test_results_folder=""; home_path=""}

  if ( Test-Path -Path "$config_file" ) {
    $config = Get-Content "$config_file" | ConvertFrom-Json
  }

  return $config
}

function Select-FolderDialog() {
  param([string]$Description="Select Folder",[string]$RootFolder="MyComputer")

  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

  $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
  $objForm.Rootfolder = $RootFolder
  $objForm.Description = $Description
  $Show = $objForm.ShowDialog()
  if ($Show -eq "OK")
  {
      Return $objForm.SelectedPath
  } else {
      Write-host "Operation cancelled by user."
      Return ""
  }
}

function Select-FileDialog([String] $initialPath = ".\") {
  Add-Type -AssemblyName System.Windows.Forms
  $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $false
  	Filter = 'Zip files (*.zip, *.7z)|*.zip;*.7z'
    InitialDirectory = "$initialPath"
  }

  [void]$FileBrowser.ShowDialog()
  $file = $FileBrowser.FileName;

  return $FileBrowser.FileName
}

function RunScipt ([String] $script, [String] $console, [String[]] $params) {
    $parameters = ""
    if ( $console -eq "cmd.exe"){
        foreach ($p in $params) { $parameters += "`"$p`" " }
        Start-Process -FilePath "$console" -ArgumentList "/c $script $parameters"
    } else {
      foreach ($p in $params) { $parameters += "`'$p`' " }
      Start-Process -FilePath "$console" -ArgumentList "-NoProfile $script $parameters" -WindowStyle maximized
    }
}

function GetInfoIcon($path) {
  return [system.drawing.image]::FromFile("$path\..\files\info.ico")
}

function autoClose([String] $seconds) {
  write-host "`r`n`r`n`r`n ** This window will close in " -NoNewline -ForegroundColor Red
  write-host "$seconds" -NoNewLine -ForegroundColor Magenta
  write-host " secs **" -ForegroundColor Red
  Start-Sleep $seconds
}
