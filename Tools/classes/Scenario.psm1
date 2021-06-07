
class Scenario {
  [string]$scenarioDescription
  [string[]]$tags
  $examples = [ordered]@{}

  Scenario([int]$scenario_line){
  }

  [void]getTags($scenario_line){
  }
}
