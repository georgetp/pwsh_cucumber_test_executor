Using module .\classes\Feature.psd1

if ($Env:Tools_PATH -ne $null) {
  Set-Location $Env:TOOLS_PATH
}

. .\common_functions.ps1
. .\forms\form_configure.ps1

function addRequiredAssembly () {
  Add-Type -assemblyName System.Windows.Forms
  Add-Type -assemblyName System.drawing
  [System.Windows.Forms.Application]::EnableVisualStyles()
}

function readTestExecConfig() {
  $testExecConfig_file = $global:runTestCase_config
  $config = @{feature_file=""; folder=""; scenario=""; inc_tags=""; excl_tags=""; suite=""; browser=""; run_mode=""; keep_results=""; split_run=""; keep_test_data=""; keep_console_output=""}

  if ( Test-Path -Path "$testExecConfig_file" ) {
    $config = Get-Content "$testExecConfig_file" | ConvertFrom-Json
  }

  return $config
}

function applyTestExecConfig($configOBJ) {
  $ComboBoxFolder.Text    = $configOBJ.folder
  $ComboBoxFeature.Text   = $configOBJ.feature_file
  $ComboBoxSuite.Text     = $configOBJ.suite
  $ComboBoxBrowser.Text   = $configOBJ.browser
  $ComboBoxMode.Text      = $configOBJ.run_mode
  $textBoxIncTags.Text    = $configOBJ.inc_tags
  $textBoxExclTags.Text   = $configOBJ.excl_tags
  if ( $configOBJ.keep_results -eq "yes") {
    $keepResultsCheckbox.Checked = $true
  }
  if ( $configOBJ.split_run -eq "yes") {
    $keepResultsCheckbox.Checked = $true
  }
  if ( $configOBJ.keep_test_data -eq "yes") {
    $keepTestDataCheckbox.Checked = $true
  }
  if ( $configOBJ.keep_console_output -eq "yes") {
    $keepConsoleOutput.Checked = $true
  }
  $ComboBoxScenario.Text  = $configOBJ.scenario
}

function saveTestExecConfig($configOBJ) {
  $configOBJ.folder              = $ComboBoxFolder.Text
  $configOBJ.feature_file        = $ComboBoxFeature.Text
  $configOBJ.suite               = $ComboBoxSuite.Text
  $configOBJ.browser             = $ComboBoxBrowser.Text
  $configOBJ.run_mode            = $ComboBoxMode.Text
  $configOBJ.scenario            = $ComboBoxScenario.Text
  $configOBJ.inc_tags            = $textBoxIncTags.Text
  $configOBJ.excl_tags           = $textBoxExclTags.Text
  $configOBJ.keep_results        = "no"
  $configOBJ.split_run           = "no"
  $configOBJ.keep_test_data      = "no"
  $configOBJ.keep_console_output = "no"
  if ( $keepResultsCheckbox.Checked -eq $true) {
    $configOBJ.keep_results        = "yes"
  }
  if ( $splitRunCheckbox.Checked -eq $true) {
    $configOBJ.split_run           = "yes"
  }
  if ( $keepTestDataCheckbox.Checked -eq $true) {
    $configOBJ.keep_test_data      = "yes"
  }
  if ( $keepConsoleOutput.Checked -eq $true) {
    $configOBJ.keep_console_output = "yes"
  }

   $($configOBJ | ConvertTo-Json) | Out-File -FilePath "$global:runTestCase_config" -Encoding ASCII
}

function runTest(){
  $feature_file    = $ComboBoxFeature.Text
  $folder          = $ComboBoxFolder.Text
  $scenario        = $($ComboBoxScenario.Text).split(" - ")[0]
  $inc_tags        = $textBoxIncTags.Text
  $excl_tags       = $textBoxExclTags.Text
  $browser         = $ComboBoxBrowser.Text
  $suite           = $ComboBoxSuite.Text
  $run_mode        = $ComboBoxMode.Text
  $keep_results    = "yes"
  $split_run       = "yes"
  $keep_console    = "yes"

  if ( $ComboBoxFolder.selectedIndex -eq 0 ) {
    $folder = "-"
  }
  if ( $ComboBoxFeature.selectedIndex -eq 0 ) {
    $feature_file = "-"
  }
  if ( $ComboBoxScenario.SelectedIndex -eq 0 ) {
    $scenario = "-"
  }
  $gridSelection = $examplesDataGridView.SelectedRows[0].Index
  if ( $gridSelection -gt 0 ) {
    $scenario = $examplesDataGridView.SelectedRows | ForEach-Object {
      if( $_.Index -eq $gridSelection ){
        return $_.Cells[0].Value
      }
    }
  }
  if ( "$inc_tags" -eq "" ) {
    $inc_tags = "-"
  }
  if ( "$excl_tags" -eq "" ) {
    $excl_tags = "-"
  }
  if ( $ComboBoxSuite.SelectedIndex -eq 0 ) {
    $suite = "-"
  }
  if ( $keepResultsCheckbox.Checked -eq $false ) {
    $keep_results = "-"
  }
  if ( $splitRunCheckbox.Checked -eq $false ) {
    $split_run = "-"
  }
  if ( $keepConsoleOutput.Checked -eq $false ) {
    $keep_console = "-"
  }

  $params = @("$feature_file", "$folder", "$scenario","$inc_tags", "$excl_tags", "$suite", "$browser", "$keep_results", "$split_run", "$run_mode", "$keep_console")
  RunScipt -console "powershell.exe" `
           -script "$($pathsOBJ.scriptsPath)\runTestCase.ps1" `
           -params $params
}

function findByFeatureName() {
  $ComboBoxFolder.SelectedIndex = 0
  $featureName = $($textBoxSearchFeature.Text).Replace("(","\(").Replace(")","\)")
  $featuresFilesPath = "$($global:featureFilesFolder)"
  $featureFiles = Get-ChildItem -Path "$featuresFilesPath" -Recurse | Select-String -pattern "Feature.*:.*$featureName"
  $ComboBoxFeature.Items.Clear()
  $ComboBoxFeature.Font = [System.Drawing.Font]::new('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
  $ComboBoxFeature.ForeColor = [System.Drawing.Color]::Magenta
  $ComboBoxFeature.Items.Add("*** Select Feature file .. ***")
  Foreach ($featureFile in $featureFiles)
  {
    $ComboBoxFeature.Items.Add($($featureFile.RelativePath("$featuresFilesPath")))
  }

  $ComboBoxFeature.SelectedIndex = 0
  $textBoxSearchFeature.Text = ""
}

function refreshFeatureFilesList() {
  $ComboBoxFeature.Items.Clear()
  $filterText = $textBoxFilter.Text
  $ComboBoxFeature.Font = [System.Drawing.Font]::new('Segoe UI', 10, [System.Drawing.FontStyle]::Regular)
  $ComboBoxFeature.ForeColor = [System.Drawing.Color]::Black
  $ComboBoxFeature.Items.Add("*** All Feature files ***")
  if($ComboBoxFolder.SelectedIndex -eq 0) {
      $sub_path = ""
  } else {
    $sub_path = "\$($ComboBoxFolder.Text)"
  }
  if ($filterText.length -lt 3){
    $filterText = ""
  }
  $featureFiles = Get-ChildItem -Path "$($global:featureFilesFolder)${sub_path}" -Include "*${filterText}*.feature" -Recurse -Name
  Foreach ($featureFile in $featureFiles)
  {
    $ComboBoxFeature.Items.Add($featureFile);
  }
  $ComboBoxFeature.SelectedIndex = 0
}

function refreshTags($scen_line, $example_line, $feature, $target) {
  switch ($target) {
    "Feature" {
      if($feature -eq $null) {
        $FeatureTagsLabel.Text = ""
      } else {
        $FeatureTagsLabel.Text = $feature.tags
      }
     }
    "Scenario" {
      if ($scen_line -eq 9999) {
        $ScenarioTagsLabel.Text = ""
      }else {
        $ScenarioTagsLabel.Text = $feature.scenarios["$scen_line"].tags
      }
     }
    "Example" {
      if ($example_line -eq 9999) {
        $ExampleTagsLabel.Text = ""
      }else {
        $ExampleTagsLabel.Text = $feature.scenarios["$scen_line"].examples["$example_line"].tags
      }
     }
  }
}

function refreshScenarioList($feature) {
  $ComboBoxScenario.Items.Clear()
  $ComboBoxScenario.Items.Add("*** All Scenarios ***")

  Foreach ($key in $($feature.scenarios.keys))
  {
    $text = $feature.scenarios["$key"].scenarioDescription
    $ComboBoxScenario.Items.Add($text);
  }
  $ComboBoxScenario.SelectedIndex = 0
}

function refreshExamplesList($scen_line, $feature) {
  $examplesDataGridView.Rows.Clear()
  $examplesDataGridView.ColumnCount = 1
  $examplesDataGridView.Columns[0].Name = "Line"
  $examplesDataGridView.Rows.Add(@("All Examples"))
  $examplesDataGridView.Columns[0].AutoSizeMode = "AllCells"

  if ($feature.scenarios -ne $null) {
    $ex_keys = [System.Collections.ArrayList]$feature.scenarios["$scen_line"].examples.keys
    if ( $($ex_keys.Count) -gt 0 ) {
      $labelsRow = $feature.scenarios["$scen_line"].examples["$($ex_keys[0])"].values
      $examplesDataGridView.ColumnCount = $labelsRow.Count + 1

      for ($column_num = 1; $column_num -lt $($labelsRow.Count); $column_num++) {
        $examplesDataGridView.Columns[$column_num].Name = $labelsRow[$column_num].Trim(' ')
        $examplesDataGridView.Columns[$column_num].AutoSizeMode = "AllCells"
      }

      $examplesDataGridView.Columns[$column_num].Name = "Tags"
      $examplesDataGridView.Columns[$column_num].AutoSizeMode = "AllCells"

      for ($enum = 1; $enum -lt $($ex_keys.Count); $enum++){
          $key = $ex_keys[$enum]
          $examplesDataGridView.Rows.Add($($feature.scenarios["$scen_line"].examples["$key"].values))
      }
    }
  }

  $examplesDataGridView.Refresh
}

function getFeatureFileObject() {
  $path = $global:featureFilesFolder
  if($ComboBoxFolder.SelectedIndex -eq 0) {
      $sub_path = ""
  } else {
    $sub_path = "\$($ComboBoxFolder.Text)"
  }
  $feature_file = "\$($ComboBoxFeature.Text)"
  $res = [Feature]::new("${path}${sub_path}${feature_file}")

  return $res
}

function getSuitesName() {
  $suitesNames = [System.Collections.ArrayList]::new()
  # Implement your code to retrieve suites names dynamically
  # The following is an example code:
  $suites = 'SuiteName1','SuiteName2'
  foreach ($suite in $suites) {
    $suitesNames.add($suite) | Out-Null
  }
  return $suitesNames
}

function runTestCase_form($pathsOBJ) {
  $runTestCase_form = New-Object System.Windows.Forms.Form
  $runTestCase_form.Text     ='! Test Case Executor !'
  $runTestCase_form.Width    = 820
  $runTestCase_form.Height   = 740
  $runTestCase_form.AutoSize = $true

  $label_position_y = 10
  $button_select_position_x = 415
  $global:feature = $null
  $tooltip1 = New-Object System.Windows.Forms.ToolTip
  $tooltip1.AutoPopDelay = 10000
  $tooltip1.InitialDelay = 500
  $tooltip1.ReshowDelay = 100
  $tooltip1.ShowAlways = $true
  $tooltip1.UseAnimation = $true
  $tooltip1.IsBalloon = $true
  $tooltip1.OwnerDraw = $true
  $tooltip1.Enabled

  $displayToolTip = {
    switch ($this.name) {
      "keepTestDataCheckbox" {
          $text = "Keep the data loaded for the test case selected.`
                  `r`n! -= IMPLEMENT YOUR CODE FOR THIS FUNCTION !" }
      "splitRunCheckbox"     {
          $text = "Will run each .feature file individually.`
Enabled only if 'Keep Results' is enabled and you have selected all features `
files under a specific directory. `
`r`n ! This selection does not work well in conjuction with 'Include Tags'`
and 'Exclude Tags' !" }
      "LabelScripts"         {
          $text = "In order to update 'Scenario (line)' or 'Examples' `
re-select the feature file." }
      "Tags"                 {
          $text = "Enabled only if '*** All Scenarios ***' option is selected. `
`r`n Example: '@tag1 @tag2 @tag3'" }
      "keepConsoleOutput"    {
    $text = "Console Output will be redirected to a file." }
    }
    $tooltip1.SetToolTip($this, $text)
  }

  # Add label filter
  $LabelSearchFeature = New-Object System.Windows.Forms.Label
  $LabelSearchFeature.Text = "Search Feature (text*) :"
  $LabelSearchFeature.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelSearchFeature.AutoSize = $true
  $LabelSearchFeature.FlatStyle = 3
  $LabelSearchFeature.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelSearchFeature)

  $textBoxSearchFeature = New-Object System.Windows.Forms.TextBox
  $textBoxSearchFeature.Location = New-Object System.Drawing.Point(220,$label_position_y)
  $textBoxSearchFeature.Size = New-Object System.Drawing.Size(250,25)
  $textBoxSearchFeature.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $textBoxSearchFeature.Add_TextChanged(
    {
      $textBoxFilter.text = ""
      if( "$($textBoxSearchFeature.text)".length -lt 10){
        $SearchFeatureButton.Enabled = $false
      } else {
        $SearchFeatureButton.Enabled = $true
      }
    }
  )
  $runTestCase_form.Controls.Add($textBoxSearchFeature)

  # Add Search Feature button
  $SearchFeatureButton = New-Object System.Windows.Forms.Button
  $SearchFeatureButton.Location = New-Object System.Drawing.Size(490,$($label_position_y))
  $SearchFeatureButton.Size = New-Object System.Drawing.Size(150,25)
  $SearchFeatureButton.Text = "Search Feature"
  $SearchFeatureButton.FlatStyle = 3
  $SearchFeatureButton.Add_Click(
    {
      findByFeatureName
    }
  )
  $SearchFeatureButton.Enabled = $false
  $runTestCase_form.Controls.Add($SearchFeatureButton)

  $label_position_y += 40
  # Add label filter
  $LabelFilter = New-Object System.Windows.Forms.Label
  $LabelFilter.Text = "Filter feature files (*text*) :"
  $LabelFilter.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelFilter.AutoSize = $true
  $LabelFilter.FlatStyle = 3
  $LabelFilter.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelFilter)

  $textBoxFilter = New-Object System.Windows.Forms.TextBox
  $textBoxFilter.Location = New-Object System.Drawing.Point(220,$label_position_y)
  $textBoxFilter.Size = New-Object System.Drawing.Size(250,25)
  $textBoxFilter.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $textBoxFilter.Add_TextChanged({
      $textBoxSearchFeature.text = ""
      if ( "$($textBoxFilter.text)".length -lt 3) {
        $RefreshFeaturesListButton.Enabled = $false
        $LabelFilteringON.Visible = $false
      } else {
        $RefreshFeaturesListButton.Enabled = $true
        $LabelFilteringON.Visible = $true
      }
    })
  $runTestCase_form.Controls.Add($textBoxFilter)

  # Add RefreshVersionsList button
  $RefreshFeaturesListButton = New-Object System.Windows.Forms.Button
  $RefreshFeaturesListButton.Location = New-Object System.Drawing.Size(490,$($label_position_y))
  $RefreshFeaturesListButton.Size = New-Object System.Drawing.Size(150,25)
  $RefreshFeaturesListButton.FlatStyle = 3
  $RefreshFeaturesListButton.Text = "Apply Filter"
  $RefreshFeaturesListButton.Add_Click(
    {
      refreshFeatureFilesList
    }
  )
  $RefreshFeaturesListButton.Enabled = $false
  $runTestCase_form.Controls.Add($RefreshFeaturesListButton)

  # Add label
  $LabelFilteringON = New-Object System.Windows.Forms.Label
  $LabelFilteringON.Text = "** Filtering ON **"
  $LabelFilteringON.Location  = New-Object System.Drawing.Point(650,$label_position_y)
  $LabelFilteringON.AutoSize = $true
  $LabelFilteringON.FlatStyle = 3
  $LabelFilteringON.Font = [System.Drawing.Font]::new('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
  $LabelFilteringON.ForeColor = [System.Drawing.Color]::Green
  $LabelFilteringON.Visible = $false
  $runTestCase_form.Controls.Add($LabelFilteringON)

  $label_position_y += 30
  # Add label
  $LabelFolder = New-Object System.Windows.Forms.Label
  $LabelFolder.Text = "Select folder :"
  $LabelFolder.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelFolder.AutoSize = $true
  $LabelFolder.FlatStyle = 3
  $LabelFolder.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelFolder)

  # Add ComboBox
  $ComboBoxFolder = New-Object System.Windows.Forms.ComboBox
  $ComboBoxFolder.Width = 775
  $ComboBoxFolder.Location  = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $ComboBoxFolder.FlatStyle = 3
  $ComboBoxFolder.DropDownStyle = 'DropDownList'
  $ComboBoxFolder.AutoCompleteSource = 'ListItems'
  $ComboBoxFolder.Items.Add("*** All Folders ***")
  $folders = Get-ChildItem -Path "$($global:featureFilesFolder)" `
               -Directory -Recurse -Exclude "*img" -Name | Sort
  Foreach ($folder in $folders)
  {
    $ComboBoxFolder.Items.Add($folder);
  }
  $ComboBoxFolder_SelectedIndexChanged=
  {
    refreshFeatureFilesList
  }
  $ComboBoxFolder.add_SelectedIndexChanged($ComboBoxFolder_SelectedIndexChanged)
  $ComboBoxFolder.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($ComboBoxFolder)

  $label_position_y += 60
  # Add label
  $LabelScripts = New-Object System.Windows.Forms.Label
  $LabelScripts.Text = "Select feature file :"
  $LabelScripts.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelScripts.Size = new-object System.Drawing.Size(110,20)
  $LabelScripts.FlatStyle = 3
  $LabelScripts.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelScripts)

  # Add Scenario tags label
  $FeatureTagsLabel = New-Object System.Windows.Forms.Label
  $FeatureTagsLabel.Location  = New-Object System.Drawing.Point(150, $label_position_y)
  $FeatureTagsLabel.AutoSize = $false
  $FeatureTagsLabel.FlatStyle = 3
  $FeatureTagsLabel.Font = [System.Drawing.Font]::new('Segoe UI', 8)
  $FeatureTagsLabel.Size = New-Object System.Drawing.Size(620,30)
  $runTestCase_form.Controls.Add($FeatureTagsLabel)

  $LabelInfoFeatures = New-Object System.Windows.Forms.Label
  $LabelInfoFeatures.Location  = New-Object System.Drawing.Point(120,$label_position_y)
  $LabelInfoFeatures.Size = new-object System.Drawing.Size(20,20)
  $LabelInfoFeatures.Image = GetInfoIcon -path $pathsOBJ.scriptsPath
  $LabelInfoFeatures.Name = "LabelScripts"
  $LabelInfoFeatures.add_MouseHover($displayToolTip)
  $runTestCase_form.Controls.Add($LabelInfoFeatures)

  # Add ComboBox
  $ComboBoxFeature = New-Object System.Windows.Forms.ComboBox
  $ComboBoxFeature.FlatStyle = 3
  $ComboBoxFeature.Width = 775
  $ComboBoxFeature.Location  = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $ComboBoxFeature.DropDownStyle = 'DropDownList'
  $ComboBoxFeature.AutoCompleteSource = 'ListItems'
  $ComboBoxFeature.Items.Add("*** All Feature files ***")
  $featureFiles = Get-ChildItem -Path "$($global:featureFilesFolder)" -Include "*.feature" -Recurse -Name
  Foreach ($featureFile in $featureFiles)
  {
    $ComboBoxFeature.Items.Add($featureFile)
  }
  $ComboBoxFeature_SelectedIndexChanged=
  {
    if( $ComboBoxFeature.selectedIndex -eq 0 ) {
      $global:feature = $null
      refreshTags -feature $global:feature -target "Feature"
      $ComboBoxScenario.SelectedIndex = 0
      $ComboBoxScenario.Enabled = $false
      if( $keepResultsCheckbox.checked -eq $true) {
        $splitRunCheckbox.Enabled = $true
      }
    } else {
      $global:feature = getFeatureFileObject
      refreshScenarioList($global:feature)
      refreshTags -feature $global:feature -target "Feature"
      $ComboBoxScenario.Enabled = $true
      $splitRunCheckbox.Checked = $false
      $splitRunCheckbox.Enabled = $false
    }
  }
  $ComboBoxFeature.add_SelectedIndexChanged($ComboBoxFeature_SelectedIndexChanged)
  $ComboBoxFeature.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($ComboBoxFeature)

  $label_position_y += 60
  # Add label Scenario
  $LabelScenario = New-Object System.Windows.Forms.Label
  $LabelScenario.Text = "Select Scenario :"
  $LabelScenario.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelScenario.AutoSize = $true
  $LabelScenario.FlatStyle = 3
  $LabelScenario.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelScenario)

  # Add Scenario tags label
  $ScenarioTagsLabel = New-Object System.Windows.Forms.Label
  $ScenarioTagsLabel.Location  = New-Object System.Drawing.Point(150, $label_position_y)
  $ScenarioTagsLabel.AutoSize = $false
  $ScenarioTagsLabel.FlatStyle = 3
  $ScenarioTagsLabel.Font = [System.Drawing.Font]::new('Segoe UI', 8)
  $ScenarioTagsLabel.Size = New-Object System.Drawing.Size(620,30)
  $runTestCase_form.Controls.Add($ScenarioTagsLabel)

  $ComboBoxScenario = New-Object System.Windows.Forms.ComboBox
  $ComboBoxScenario.Width = 775
  $ComboBoxScenario.FlatStyle = 3
  $ComboBoxScenario.Location  = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $ComboBoxScenario.DropDownStyle = 'DropDownList'
  $ComboBoxScenario.AutoCompleteSource = 'ListItems'
  $ComboBoxScenario.Items.Add("*** All Scenarios ***")
  $ComboBoxScenario_SelectedIndexChanged=
  {
    $sl = 9999
    if( $ComboBoxScenario.selectedIndex -eq 0 ) {
      refreshTags -scen_line $sl -feature $global:feature -target "Scenario"
      $examplesDataGridView.Enabled = $false
      $textBoxIncTags.Enabled = $true
      $textBoxExclTags.Enabled = $true
    } else {
      $sl = [int]$($ComboBoxScenario.Text).split(" - ")[0]
      refreshTags -scen_line $sl -feature $global:feature -target "Scenario"
      $examplesDataGridView.Enabled = $true
      $textBoxIncTags.Text = ""
      $textBoxIncTags.Enabled = $false
      $textBoxExclTags.Text = ""
      $textBoxExclTags.Enabled = $false
    }
    refreshTags -scen_line $sl -example_line 9999 -feature $global:feature -target "Example"
    refreshExamplesList -scen_line $sl -feature $global:feature
  }
  $ComboBoxScenario.add_SelectedIndexChanged($ComboBoxScenario_SelectedIndexChanged)
  $ComboBoxScenario.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($ComboBoxScenario)

  $label_position_y += 60

  $LabelExample = New-Object System.Windows.Forms.Label
  $LabelExample.Text = "Select Example :"
  $LabelExample.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelExample.AutoSize = $true
  $LabelExample.FlatStyle = 3
  $LabelExample.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelExample)

  # Add Scenario tags label
  $ExampleTagsLabel = New-Object System.Windows.Forms.Label
  $ExampleTagsLabel.Location  = New-Object System.Drawing.Point(150, $label_position_y)
  $ExampleTagsLabel.AutoSize = $false
  $ExampleTagsLabel.FlatStyle = 3
  $ExampleTagsLabel.Font = [System.Drawing.Font]::new('Segoe UI', 8)
  $ExampleTagsLabel.Size = New-Object System.Drawing.Size(620,30)
  $runTestCase_form.Controls.Add($ExampleTagsLabel)

  $examplesDataGridView = New-Object System.Windows.Forms.DataGridView
  $examplesDataGridView.Location = new-object System.Drawing.Size(10,$($label_position_y + 30))
  $examplesDataGridView.Size = new-object System.Drawing.Size(775,180)
  $examplesDataGridView.ColumnHeadersVisible = $true
  $examplesDataGridView.SelectionMode = 1
  $examplesDataGridView.ReadOnly = $true
  $examplesDataGridView.AllowUserToAddRows = $false
  $examplesDataGridView.AllowUserToResizeRows = $false
  $examplesDataGridView.AllowUserToDeleteRows = $false
  $examplesDataGridView.MultiSelect = $false
  $examplesDataGridView.Add_Click({
    $sl = [int]$($ComboBoxScenario.Text).split(" - ")[0]
    $el = 9999
    $gridSelection = $examplesDataGridView.SelectedRows[0].Index
    if ( $gridSelection -gt 0 ) {
      $el = $examplesDataGridView.SelectedRows | ForEach-Object {
        if( $_.Index -eq $gridSelection ){
          return $_.Cells[0].Value
        }
      }
    }
    refreshTags -scen_line $sl -example_line $el -feature $global:feature -target "Example"
  })

  $runTestCase_form.Controls.Add($examplesDataGridView)

  $label_position_y += 220
  # Add label
  $LabelIncTags = New-Object System.Windows.Forms.Label
  $LabelIncTags.Text = "Include Tags :"
  $LabelIncTags.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelIncTags.AutoSize = $true
  $LabelIncTags.FlatStyle = 3
  $LabelIncTags.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelIncTags)

  $textBoxIncTags = New-Object System.Windows.Forms.TextBox
  $textBoxIncTags.Location = New-Object System.Drawing.Point(170,$label_position_y)
  $textBoxIncTags.Size = New-Object System.Drawing.Size(150,20)
  $textBoxIncTags.Add_TextChanged(
    {
      if( ($textBoxIncTags.text -eq "") `
          -and `
          ($textBoxExclTags.text -eq "") `
          -and `
           ($ComboBoxFeature.SelectedIndex -gt 0)) {
        $ComboBoxScenario.Enabled = $true
      } else {
        $ComboBoxScenario.SelectedIndex = 0
        $ComboBoxScenario.Enabled = $false
      }
    }
  )
  $runTestCase_form.Controls.Add($textBoxIncTags)

  $LabelInfoIncTags = New-Object System.Windows.Forms.Label
  $LabelInfoIncTags.Location  = New-Object System.Drawing.Point(325,$label_position_y)
  $LabelInfoIncTags.Size = new-object System.Drawing.Size(20,20)
  $LabelInfoIncTags.Image = GetInfoIcon -path $pathsOBJ.scriptsPath
  $LabelInfoIncTags.Name = "Tags"
  $LabelInfoIncTags.add_MouseHover($displayToolTip)
  $runTestCase_form.Controls.Add($LabelInfoIncTags)

  # Keep Results Checkbox
  $keepResultsCheckbox_location_x = 600
  $keepResultsCheckbox = new-object System.Windows.Forms.checkbox
  $keepResultsCheckbox.Location = new-object System.Drawing.Size($keepResultsCheckbox_location_x,$label_position_y)
  $keepResultsCheckbox.Size = new-object System.Drawing.Size(120,20)
  $keepResultsCheckbox.FlatStyle = 3
  $keepResultsCheckbox.Text = "Keep Results"
  $keepResultsCheckbox.Checked = $false
  $keepResultsCheckbox.Add_CheckStateChanged(
    {
      if (($paths.test_results_folder -eq "") `
          -and ($keepResultsCheckbox.Checked -eq $true)){
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Set test results folder first",0,"Config missing error!",0x0 + 0x10)
        $keepResultsCheckbox.Checked = $false
      }else {
        if (($keepResultsCheckbox.Checked -eq $true) `
            -and ($ComboBoxFeature.SelectedIndex -eq 0)){
          $splitRunCheckbox.Enabled = $true
        } else {
          $splitRunCheckbox.Checked = $false
          $splitRunCheckbox.Enabled = $false
        }
      }
    }
  )
  $keepResultsCheckbox.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($keepResultsCheckbox)

  $label_position_y += 30
  # Add label
  $LabelExclTags = New-Object System.Windows.Forms.Label
  $LabelExclTags.Text = "Exclude Tags :"
  $LabelExclTags.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelExclTags.AutoSize = $true
  $LabelExclTags.FlatStyle = 3
  $LabelExclTags.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelExclTags)

  $textBoxExclTags = New-Object System.Windows.Forms.TextBox
  $textBoxExclTags.Location = New-Object System.Drawing.Point(170,$label_position_y)
  $textBoxExclTags.Size = New-Object System.Drawing.Size(150,20)
  $textBoxExclTags.Add_TextChanged(
    {
      if( ($textBoxIncTags.text -eq "") `
          -and `
          ($textBoxExclTags.text -eq "") `
          -and `
           ($ComboBoxFeature.SelectedIndex -gt 0)){
        $ComboBoxScenario.Enabled = $true
      } else {
        $ComboBoxScenario.SelectedIndex = 0
        $ComboBoxScenario.Enabled = $false
      }
    }
  )
  $runTestCase_form.Controls.Add($textBoxExclTags)

  $LabelInfoExclTags = New-Object System.Windows.Forms.Label
  $LabelInfoExclTags.Location  = New-Object System.Drawing.Point(325,$label_position_y)
  $LabelInfoExclTags.Size = new-object System.Drawing.Size(20,20)
  $LabelInfoExclTags.Image = GetInfoIcon -path $pathsOBJ.scriptsPath
  $LabelInfoExclTags.Name = "Tags"
  $LabelInfoExclTags.add_MouseHover($displayToolTip)
  $runTestCase_form.Controls.Add($LabelInfoExclTags)

  $splitRunCheckbox_location_x = 600
  $splitRunCheckbox = new-object System.Windows.Forms.checkbox
  $splitRunCheckbox.Location = new-object System.Drawing.Size($splitRunCheckbox_location_x,$label_position_y)
  $splitRunCheckbox.Size = new-object System.Drawing.Size(120,20)
  $splitRunCheckbox.Text = "Split Execution"
  $splitRunCheckbox.Checked = $false
  $splitRunCheckbox.Enabled = $false
  $splitRunCheckbox.FlatStyle = 3
  $splitRunCheckbox.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($splitRunCheckbox)

  $LabelInfoSplitRun = New-Object System.Windows.Forms.Label
  $LabelInfoSplitRun.Location  = New-Object System.Drawing.Point(750,$label_position_y)
  $LabelInfoSplitRun.Size = new-object System.Drawing.Size(20,20)
  $LabelInfoSplitRun.Image = GetInfoIcon -path $pathsOBJ.scriptsPath
  $LabelInfoSplitRun.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $LabelInfoSplitRun.Name = "splitRunCheckbox"
  $LabelInfoSplitRun.add_MouseHover($displayToolTip)
  $runTestCase_form.Controls.Add($LabelInfoSplitRun)

  $label_position_y += 30

  # label Suite
  $LabelSuite = New-Object System.Windows.Forms.Label
  $LabelSuite.Text = "Select Suite :"
  $LabelSuite.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelSuite.AutoSize = $true
  $LabelSuite.FlatStyle = 3
  $LabelSuite.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelSuite)

  # Add ComboBox Browser
  $ComboBoxSuite = New-Object System.Windows.Forms.ComboBox
  $ComboBoxSuite.Width = 150
  $ComboBoxSuite.Location  = New-Object System.Drawing.Point(170,$label_position_y)
  $ComboBoxSuite.DropDownStyle = 'DropDownList'
  $ComboBoxSuite.AutoCompleteSource = 'ListItems'
  $ComboBoxSuite.FlatStyle = 3
  $suites = getSuitesName
  $ComboBoxSuite.Items.Add("")
  Foreach ($suite in $suites)
  {
    $ComboBoxSuite.Items.Add($suite)
  }
  $ComboBoxSuite.SelectedIndex = 0
  $ComboBoxSuite.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($ComboBoxSuite)


  $keepTestDataCheckbox_location_x = 600
  $keepTestDataCheckbox = new-object System.Windows.Forms.checkbox
  $keepTestDataCheckbox.Location = new-object System.Drawing.Size($keepTestDataCheckbox_location_x,$label_position_y)
  $keepTestDataCheckbox.Size = new-object System.Drawing.Size(120,20)
  $keepTestDataCheckbox.FlatStyle = 3
  $keepTestDataCheckbox.Text = "Keep test data"
    $keepTestDataCheckbox.Add_CheckStateChanged(
    {
      if($keepTestDataCheckbox.Checked -eq $true) {
        # implement your code
      } else {
        # implement your code
    }
  }
  )
  $keepTestDataCheckbox.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($keepTestDataCheckbox)

  $LabelInfoKeepData = New-Object System.Windows.Forms.Label
  $LabelInfoKeepData.Location  = New-Object System.Drawing.Point(750,$label_position_y)
  $LabelInfoKeepData.Size = new-object System.Drawing.Size(20,20)
  $LabelInfoKeepData.Image = GetInfoIcon -path $pathsOBJ.scriptsPath
  $LabelInfoKeepData.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $LabelInfoKeepData.Name = "keepTestDataCheckbox"
  $LabelInfoKeepData.add_MouseHover($displayToolTip)
  $runTestCase_form.Controls.Add($LabelInfoKeepData)

  $label_position_y += 30
  # label Browser
  $LabelBrowser = New-Object System.Windows.Forms.Label
  $LabelBrowser.Text = "Select Browser :"
  $LabelBrowser.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelBrowser.AutoSize = $true
  $LabelBrowser.FlatStyle = 3
  $LabelBrowser.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelBrowser)

  # Add ComboBox Browser
  $ComboBoxBrowser = New-Object System.Windows.Forms.ComboBox
  $ComboBoxBrowser.Width = 150
  $ComboBoxBrowser.Location  = New-Object System.Drawing.Point(170,$label_position_y)
  $ComboBoxBrowser.DropDownStyle = 'DropDownList'
  $ComboBoxBrowser.AutoCompleteSource = 'ListItems'
  $ComboBoxBrowser.FlatStyle = 3
  $browsers = "chrome", "firefox", "internet explorer", "microsoftedge"
  Foreach ($browser in $browsers)
  {
    $ComboBoxBrowser.Items.Add($browser);
  }
  $ComboBoxBrowser.SelectedIndex = 0
  $ComboBoxBrowser.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($ComboBoxBrowser)

  $keepConsoleOutput_location_x = 600
  $keepConsoleOutput = new-object System.Windows.Forms.checkbox
  $keepConsoleOutput.Location = new-object System.Drawing.Size($keepConsoleOutput_location_x,$label_position_y)
  $keepConsoleOutput.Size = new-object System.Drawing.Size(150,20)
  $keepConsoleOutput.FlatStyle = 3
  $keepConsoleOutput.Text = "Keep Console Output"
  $keepConsoleOutput.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($keepConsoleOutput)

  $LabelInfokeepConsoleOutput = New-Object System.Windows.Forms.Label
  $LabelInfokeepConsoleOutput.Location  = New-Object System.Drawing.Point(750,$label_position_y)
  $LabelInfokeepConsoleOutput.Size = new-object System.Drawing.Size(20,20)
  $LabelInfokeepConsoleOutput.Image = GetInfoIcon -path $pathsOBJ.scriptsPath
  $LabelInfokeepConsoleOutput.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $LabelInfokeepConsoleOutput.Name = "keepConsoleOutput"
  $LabelInfokeepConsoleOutput.add_MouseHover($displayToolTip)
  $runTestCase_form.Controls.Add($LabelInfokeepConsoleOutput)

  $label_position_y += 30
  # label Browser
  $LabelMode = New-Object System.Windows.Forms.Label
  $LabelMode.Text = "Select Run Mode :"
  $LabelMode.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelMode.AutoSize = $true
  $LabelMode.FlatStyle = 3
  $LabelMode.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($LabelMode)

  # Add ComboBox Browser
  $ComboBoxMode = New-Object System.Windows.Forms.ComboBox
  $ComboBoxMode.Width = 150
  $ComboBoxMode.Location  = New-Object System.Drawing.Point(170,$label_position_y)
  $ComboBoxMode.DropDownStyle = 'DropDownList'
  $ComboBoxMode.AutoCompleteSource = 'ListItems'
  $ComboBoxMode.FlatStyle = 3
  $modes = "mode1", "mode2"
  Foreach ($mode in $modes)
  {
    $ComboBoxMode.Items.Add($mode);
  }
  $ComboBoxMode.SelectedIndex = 0
  $ComboBoxMode.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $runTestCase_form.Controls.Add($ComboBoxMode)


  # Clear Selections button
  $ClearSelectionsButton_width = 100
  $ClearSelectionsButton_location_y = $runTestCase_form.Height - 80
  $ClearSelectionsButton = New-Object System.Windows.Forms.Button
  $ClearSelectionsButton.Location = New-Object System.Drawing.Size(10, $ClearSelectionsButton_location_y)
  $ClearSelectionsButton.Size = New-Object System.Drawing.Size($ClearSelectionsButton_width,30)
  $ClearSelectionsButton.Text = "Clear Selections"
  $ClearSelectionsButton.FlatStyle = 3
  $ClearSelectionsButton.Add_Click(
    {
      $textBoxSearchFeature.text      = ""
      $textBoxFilter.text             = ""
      $ComboBoxFolder.SelectedIndex   = 0
      $ComboBoxFeature.SelectedIndex  = 0
      $ComboBoxScenario.SelectedIndex = 0
      $ComboBoxBrowser.SelectedIndex  = 0
      $ComboBoxSuite.SelectedIndex    = 0
      $ComboBoxMode.SelectedIndex     = 0
      $textBoxIncTags.Text            = ""
      $textBoxExclTags.Text           = ""
      $keepResultsCheckbox.Checked    = $false
      $keepTestDataCheckbox.Checked   = $false
      $keepConsoleOutput.Checked      = $false
    }
  )
  $runTestCase_form.Controls.Add($ClearSelectionsButton)

  #Run test/tests button
  $runTestCaseButton_width = 150
  $runTestCaseButton_location_x = $($runTestCase_form.Width-$runTestCaseButton_width) / 2
  $runTestCaseButton_location_y = $runTestCase_form.Height - 80
  $runTestCaseButton = New-Object System.Windows.Forms.Button
  $runTestCaseButton.Location = New-Object System.Drawing.Size($runTestCaseButton_location_x, $runTestCaseButton_location_y)
  $runTestCaseButton.Size = New-Object System.Drawing.Size($runTestCaseButton_width,30)
  $runTestCaseButton.Font = [System.Drawing.Font]::new('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)
  $runTestCaseButton.ForeColor = [System.Drawing.Color]::Green
  $runTestCaseButton.Text = "=> Run  <="
  $runTestCaseButton.FlatStyle = 3
  $runTestCaseButton.Add_Click(
    {
      runTest
    }
  )
  $runTestCase_form.Controls.Add($runTestCaseButton)

  # Clear Selections button
  $ConfigureButton_width = 100
  $ConfigureButton_location_y = $runTestCase_form.Height - 80
  $ConfigureButton = New-Object System.Windows.Forms.Button
  $ConfigureButton.Location = New-Object System.Drawing.Size(($runTestCase_form.Width-140), $ConfigureButton_location_y)
  $ConfigureButton.Size = New-Object System.Drawing.Size($ConfigureButton_width,30)
  $ConfigureButton.Text = "Configure Paths"
  $ConfigureButton.FlatStyle = 3
  $ConfigureButton.Add_Click(
    {
      configure_form
    }
  )
  $runTestCase_form.Controls.Add($ConfigureButton)

  $ComboBoxFolder.SelectedIndex  = 0
  $ComboBoxFeature.SelectedIndex = 0

  $runTestCase_form.Add_Closing({
      param($sender,$e)
      saveTestExecConfig($config)
      Remove-Module Feature
    })

  $config = readTestExecConfig

  applyTestExecConfig($config)

  $runTestCase_form.ShowDialog()
}

# Main program starts here
addRequiredAssembly

$globalVars = readGlobals

if ( -Not (Test-Path -Path "$HOME\$($globalVars.configFileName)") ) {
  configure_form
}

$pathsOBJ = readConfiguration

# Set runTestCase form paths
$global:runTestCase_config = $globalVars.runFormSelectionsFile
$global:featureFilesFolder = "$($pathsOBJ.feature_files_path)"

if ((Test-Path -Path "$global:featureFilesFolder") -AND `
    (Test-Path -Path $pathsOBJ.scriptsPath )) {
  runTestCase_form($pathsOBJ) | Out-Null
} else {
  write-host "!! There was an error in your folder configuration !!"
  write-host "Delete $HOME\$($globalVars.configFileName) and rerun so as to configure paths again."
}
