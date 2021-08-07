<# Downloaded from : https://github.com/georgetp/pwsh_test_executor_for_feature_files.git #>

class Scenario {
  [string]$scenarioDescription
  [string[]]$tags
  $examples = [ordered]@{}

  Scenario([int]$scenario_line){
  }

  [void]getTags($scenario_line){
  }
}
