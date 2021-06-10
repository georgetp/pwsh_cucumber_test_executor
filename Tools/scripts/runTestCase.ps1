. .\common_functions.ps1

$paths = readConfiguration
$feature_file   = $args[0]
$folder         = "$($args[1])\"
$scenario       = ":$($args[2])"
$include_tags   = $args[3]
$exclude_tags   = $args[4]
$suite          = $args[5]
$browser        = $args[6]
$keep_results   = $args[7]
$split_run      = $args[8]
$run_mode       = $args[9]
$save_console   = $args[10]
$inc_tags       = ""
$excl_tags      = ""
$tags_prefix    = "--tags="
$suite_prefix   = "--suite="
$browser_prefix = "--browser="

if ( "$folder" -eq "-\" ) {
  $folder = ""
}
if ( "$feature_file" -eq "-" ) {
  $feature_file = ""
}
if ("$scenario" -eq ":-") {
  $scenario = ""
}
if ("$include_tags" -eq "-") {
  $inc_tags = ""
} else {
  $inc_tags = " ${tags_prefix}`"($($include_tags -replace ' ', ' or '))`""
}
if ("$exclude_tags" -eq "-") {
  $excl_tags = ""
} else {
  $excl_tags = " ${tags_prefix}`"not ($($exclude_tags -replace ' ', ' or '))`""
}
if ("$suite" -eq "-") {
  $suite = ""
} else {
  $suite = " ${suite_prefix}${suite}"
}
if ("$browser" -eq "-") {
  $browser = ""
} else {
  $browser = " ${browser_prefix}${browser}"
}

$windows_title = "Test Case Executor - ${feature_file}${scenario} - Run Mode: ${run_mode}"
$host.ui.RawUI.WindowTitle = "$windows_title"

function actionAnnouncement($cmd, $outFile, $cnslLog) {
  write-host "=========================================="
  write-host "`r`nExecuting command:"
  write-host "${cmd}`r`n" -ForegroundColor Green
  if ( "$keep_results" -eq "yes" ) {
    write-host "Results will be copied to:"
    write-host "$outFile" -ForegroundColor Yellow
  }
  if("$save_console" -eq "yes") {
    write-host "Console Output will be stored to:"
    write-host "$cnslLog" -ForegroundColor Yellow
  }
  write-host "=========================================="
}

function executeCommand($featureFile) {
  $timeStamp      = $(Get-date -Format "dd-MMM-yyy__HH-mm-ss")
  $consoleOutFile = ""
  $consoleOut     = ""
  if ( "$featureFile" -ne "") {
    $prefix = $featureFile.split("\")[-1].split(".")[0]
  } else {
    if ("$folder" -eq "") {
      $prefix = "all"
    } else {
      $prefix = $folder.Replace("\", "-")
    }
  }
  $output_file="$($paths.test_results_folder)\${prefix}-${timeStamp}.7z"
  if("$save_console" -ne "-") {
    $consoleOutFile = "$($paths.test_results_folder)\console-${prefix}-$timeStamp.log"
    $consoleOut = " | Out-File ${consoleOutFile} -Encoding ASCII -Append"
  }

  $specs   = "\features\${folder}${featureFile}${scenario}"

  # !! You need to complete/replace with the actual command that will eventually
  # !! ran in the line bellow.
  $command = "--specs=${specs}${inc_tags}${excl_tags}${browser}${suite}${consoleOut}"

  actionAnnouncement -cmd $command -outFile $output_file -cnslLog $consoleOutFile

  # !! Un-comment the following line in order to run the command
  # Invoke-Expression $command

  if ( "$keep_results" -eq "yes" ) {
    write-host "`r`nSaving results .." -ForegroundColor DarkGray
    write-host "-----------------" -ForegroundColor DarkGray
    # !! Replace the '.\tmp\' with the folder that you execution tool stores
    # !! the results. Then un-commament the following line.
    # 7z a "${output_file}" .\tmp\*
  }
}

Set-Location $paths.test_execution_tool_path

if ( "$split_run" -eq "yes") {
  $featureFilesArray = Get-ChildItem -Path "$($paths.feature_files_path)\${folder}" -Include "*.feature" -Recurse -Name
  Foreach ($file in $featureFilesArray){
    executeCommand -featureFile $file
  }
} else {
  executeCommand -featureFile $feature_file
}

autoClose(900)
