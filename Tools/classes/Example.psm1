<# Downloaded from : https://github.com/georgetp/pwsh_test_executor_for_feature_files.git #>

class Example {
  [int]$line
  [string[]]$values
  [string[]]$tags

  Example([int]$exampleLine){
    $this.line = $exampleLine
  }
}
