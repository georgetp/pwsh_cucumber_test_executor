. .\common_functions.ps1

function SaveFolderConfiguration($configOBJ){
   $globalVars = readGlobals
   $configOBJ.scriptsPath              = $textBoxScripts.Text
   $configOBJ.feature_files_path       = $textBoxCode.Text
   $configOBJ.test_results_folder      = $textBoxTestResults.Text
   $configOBJ.test_execution_tool_path = $textTestExecutionToolPath.Text
   $configOBJ.home_path                = $textBoxHome.Text

   $($configOBJ | ConvertTo-Json) | Out-File -FilePath "$HOME\$($globalVars.configFileName)" -Encoding ASCII
}

function applyFolderConfiguration($configOBJ) {
  $textBoxScripts.Text            = $configOBJ.scriptsPath
  $textBoxCode.Text               = $configOBJ.feature_files_path
  $textBoxTestResults.Text        = $configOBJ.test_results_folder
  $textTestExecutionToolPath.Text = $configOBJ.test_execution_tool_path
  $textBoxHome.Text               = $configOBJ.home_path
}

function folderSelection() {
  $curText = $this.text
  $selection = Select-FolderDialog
  if($selection -eq "") {$selection = $curText}
  return $selection
}

function configure_form() {
  $configure_form           = New-Object System.Windows.Forms.Form
  $configure_form.Text      ='Configure Folders'
  $configure_form.Width     = 500
  $configure_form.Height    = 650
  $configure_form.AutoSize  = $true

  $label_position_y = 10
  $button_select_position_x = 415

  # Add label
  $LabelScripts = New-Object System.Windows.Forms.Label
  $LabelScripts.Text = "Scripts Path :"
  $LabelScripts.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelScripts.AutoSize = $true
  $LabelScripts.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $configure_form.Controls.Add($LabelScripts)

  $textBoxScripts = New-Object System.Windows.Forms.TextBox
  $textBoxScripts.Location = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $textBoxScripts.Size = New-Object System.Drawing.Size(460,20)
  $textBoxScripts.Add_Click(
    {
      $textBoxScripts.Text = folderSelection
    }
  )
  $configure_form.Controls.Add($textBoxScripts)

  # Add label
  $label_position_y += 60
  $LabelCode = New-Object System.Windows.Forms.Label
  $LabelCode.Text = "Feature files folder path :"
  $LabelCode.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelCode.AutoSize = $true
  $LabelCode.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $configure_form.Controls.Add($LabelCode)

  $textBoxCode = New-Object System.Windows.Forms.TextBox
  $textBoxCode.Location = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $textBoxCode.Size = New-Object System.Drawing.Size(460,20)
  $textBoxCode.Add_Click(
    {
      $textBoxCode.Text = folderSelection
    }
  )
  $configure_form.Controls.Add($textBoxCode)

  # Add label
  $label_position_y += 60
  $LabelTestExecutionToolPath = New-Object System.Windows.Forms.Label
  $LabelTestExecutionToolPath.Text = "Test Execution Tool Folder :"
  $LabelTestExecutionToolPath.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelTestExecutionToolPath.AutoSize = $true
  $LabelTestExecutionToolPath.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $configure_form.Controls.Add($LabelTestExecutionToolPath)

  $textTestExecutionToolPath = New-Object System.Windows.Forms.TextBox
  $textTestExecutionToolPath.Location = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $textTestExecutionToolPath.Size = New-Object System.Drawing.Size(460,20)
  $textTestExecutionToolPath.Add_Click(
    {
      $textTestExecutionToolPath.Text = folderSelection
    }
  )
  $configure_form.Controls.Add($textTestExecutionToolPath)

  # Add label
  $label_position_y += 60
  $LabelTestResults = New-Object System.Windows.Forms.Label
  $LabelTestResults.Text = "Tests Results Folder :"
  $LabelTestResults.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelTestResults.AutoSize = $true
  $LabelTestResults.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $configure_form.Controls.Add($LabelTestResults)

  $textBoxTestResults = New-Object System.Windows.Forms.TextBox
  $textBoxTestResults.Location = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $textBoxTestResults.Size = New-Object System.Drawing.Size(460,20)
  $textBoxTestResults.Add_Click(
    {
      $textBoxTestResults.Text = folderSelection
    }
  )
  $configure_form.Controls.Add($textBoxTestResults)

  # Add label
  $label_position_y += 60
  $LabelHome = New-Object System.Windows.Forms.Label
  $LabelHome.Text = "User Home :"
  $LabelHome.Location  = New-Object System.Drawing.Point(10,$label_position_y)
  $LabelHome.AutoSize = $true
  $LabelHome.Font = [System.Drawing.Font]::new('Segoe UI', 10)
  $configure_form.Controls.Add($LabelHome)

  $textBoxHome = New-Object System.Windows.Forms.TextBox
  $textBoxHome.Location = New-Object System.Drawing.Point(10,$($label_position_y + 30))
  $textBoxHome.Size = New-Object System.Drawing.Size(460,20)
  $textBoxhome.Add_Click(
    {
      if ((folderSelection) -eq "") {
        $textBoxHome.Text = "$HOME"
      } else {
        $textBoxHome.Text = folderSelection
      }
    }
  )
  $configure_form.Controls.Add($textBoxHome)

  #Save configuration button
  $saveCongigButton_width = 100
  $saveCongigButton_location_x = $($configure_form.Width-$saveCongigButton_width) / 2
  $saveConfigButton = New-Object System.Windows.Forms.Button
  $saveConfigButton.Location = New-Object System.Drawing.Size($saveCongigButton_location_x,$($($configure_form.Height) - 80))
  $saveConfigButton.Size = New-Object System.Drawing.Size($saveCongigButton_width,25)
  $saveConfigButton.Font = [System.Drawing.Font]::new('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
  $saveConfigButton.Text = "Save"
  $saveConfigButton.Add_Click(
    {
      SaveFolderConfiguration($configuration)
      $configure_form.Close()
    }
  )
  $configure_form.Controls.Add($saveConfigButton)

  $configuration = readConfiguration
  applyFolderConfiguration($configuration)

  $configure_form.ShowDialog()
}
