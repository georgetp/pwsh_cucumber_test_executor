Using module .\Scenario.psm1
Using module .\Example.psm1

class Feature {
  [System.Collections.ArrayList]$tags
  $scenarios = [ordered]@{}
  [string]$file
  [string]$featureDescription
  hidden $featureFileContent
  hidden [int]$lastCheckedLine

  Feature ([string]$file) {
    $this.tags = [System.Collections.ArrayList]::new()
    $this.file = $file
    $this.getFileContent($file)
    $this.getFeatureTags()
    $this.getFeatureDescription()
    $this.createScenarioObjects()
  }

  hidden [void]getFeatureTags(){
    [int]$line = 0
    [boolean]$continue = $TRUE
    do {
      $curLine = $this.featureFileContent[$line]
      if( ($curLine.Contains("@") -eq $TRUE) -and `
          ($curLine.Contains("#") -eq $FALSE) ) {
        $curLineTags = $curLine.Split("@")
        foreach ($tag in $curLIneTags) {
          if($tag -ne '') {
            $this.tags.Add("@"+$tag)
          }
        }
      }
      if($curLine.Contains("Feature:")) {
        $continue = $FALSE
        $this.lastCheckedLine = $line
      }
      $line += 1
    } while($continue)
  }

  hidden [void]getFeatureDescription(){
    [int]$line = $this.lastCheckedLine
    $curLine = $this.featureFileContent[$line]
    $this.featureDescription = $curLine.Split(":")[1].Trim()
  }

  hidden [void]createScenarioObjects(){
    $scenarioLines = $this.featureFileContent `
    | select-string -pattern 'Scenario.*:' `
    | select-string -pattern '.*#.*' -Notmatch

    Foreach ($scenarioLine in $scenarioLines) {
      $scenLine = $($scenarioLine.LineNumber)
      $scenario = "$scenarioLine".Trim("`t").Trim(" ")
      $text = "$scenLine - $scenario"
      $this.scenarios["$scenLine"] = [Scenario]::new($scenLine)
      $this.scenarios["$scenLine"].scenarioDescription = $text
      $this.scenarios["$scenline"].tags = $this.getScenarioTags($scenLine)
      $this.getScenarioExamples($scenLine)
    }
  }

  hidden [string[]]getScenarioTags([int]$scenLine) {
    [int]$line = $scenLine - 2
    $scenTags = [System.Collections.ArrayList]::new()
    [boolean]$continue = $TRUE
    do {
      $curLine = $this.featureFileContent[$line]
      if( ($curLine.Contains("@") -eq $TRUE) -and `
          ($curLine.Contains("#") -eq $FALSE) ) {
        $curLineTags = $curLine.Trim("`t").Trim(" ").Split("@")
        foreach ($tag in $curLIneTags) {
          if($tag -ne '') {
            $scenTags.Add("@"+$tag.Trim())
          }
        }
      }
      if($curLine.Equals('')) {
        $continue = $FALSE
      }
      $line = $line - 1
    } while($continue)

    return $scenTags
  }

  hidden getScenarioExamples([int]$scenLine) {
    $ex_val = [System.Collections.ArrayList]::new()
    $exampleTags = [System.Collections.ArrayList]::new()
    $fileContent = $this.featureFileContent
    $hasExamples = $TRUE
    $currentScenario = $scenLine

    do {
      if($fileContent -eq $null ) {
        $hasExamples = $FALSE
        break
       }
      if($scenLine -gt $($fileContent.Count - 1)) {
        $hasExamples = $FALSE
        break
      }
      if($fileContent[$scenLine].Contains("Examples:") -eq $TRUE) {
        $exampleTags = $this.getExampleTags($scenLine)
        break
      }
      if($fileContent[$scenLine].Contains("Scenario")  -eq $TRUE) {
        $hasExamples = $FALSE
        break
      }
      $scenLine += 1
    }while($TRUE)

    if ($hasExamples -eq $TRUE){
      do{
        $scenLine += 1
        if ( ($scenLine -eq $fileContent.Count) -or `
             ($fileContent[$scenLine].Contains("Scenario")  -eq $TRUE)) {
          break
        }
        if ($fileContent[$scenLine].Contains("Examples:")) {
          $exampleTags = $this.getExampleTags($scenLine)
          $scenLine += 2
        }
        if ( ($fileContent[$scenLine].Contains("| ") -eq $TRUE) -and `
             (-Not ($fileContent[$scenLine].Contains("#") -eq $TRUE))) {
          $r = @("$($scenLine + 1)") + "$($fileContent[$scenLine].Trim(' '))".Trim("`t").Trim("|").Split("|")
          for($i = 0; $i -lt $r.Count; $i++) {
            $r[$i] = $r[$i].Trim(" ")
          }
          $exampleLine = $scenLine + 1
          $this.scenarios["$currentScenario"].examples["$exampleLine"] = [Example]::new($exampleLine)
          $this.scenarios["$currentScenario"].examples["$exampleLine"].values = $r
          $this.scenarios["$currentScenario"].examples["$exampleLine"].tags = $exampleTags
        }
      }while($TRUE)
    }
  }

  hidden [string[]]getExampleTags($exampleLine) {
    [int]$line = $exampleLine - 1
    $ex_Tags = [System.Collections.ArrayList]::new()
    [boolean]$continue = $TRUE
    do {
      $curLine = $this.featureFileContent[$line]
      if( ($curLine.Contains("@") -eq $TRUE) -and `
          ($curLine.Contains("#") -eq $FALSE) ) {
        $curLineTags = $curLine.Trim("`t").Trim(" ").Split("@")
        foreach ($tag in $curLIneTags) {
          if($tag -ne '') {
            $ex_Tags.Add("@"+$tag.Trim())
          }
        }
      }
      if( $curLine.Trim().StartsWith('Examples:') -eq $TRUE -or `
          $curLine.Trim().StartsWith('Scenario') -eq $TRUE ) {
        $continue = $FALSE
      }
      $line = $line - 1
    } while($continue)

    return $ex_Tags
  }

  hidden [void]getFileContent($file){
    $this.featureFileContent = Get-Content "$file"
  }
}
