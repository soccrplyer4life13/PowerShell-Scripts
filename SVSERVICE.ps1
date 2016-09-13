##### - Base Parameters - #####
$serviceName = ""
$username = ""
$password = ""
$svPath = ""
$parameters = ""
$svPathAndParams = $svPath + $parameters

#region Assemblies
##### - Load Assemblies - #####
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
#endregion

#region Base Form
##### - Create the Base Form - #####
$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "SVSERVICE Creation"
$objForm.Size = New-Object System.Drawing.Size(600,400)
$objForm.StartPosition = "CenterScreen"
#endregion

##### - Create the OK Button - #####
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(210,320)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({
    $serviceName=$txtName.Text;
    $username=$txtUser.Text;
    $password=$txtPassword.Text;
    $svPath='"' + $txtPath.Text + '"';
    if ($chkExit.Checked -eq $True)
    {
        $parameters += " -exit"
    }
    if ($txtCfgPath.Text -ne "")
    {
        $parameters += " -configpath " + $txtCfgPath.Text
    }
    if ($txtPolling.Text -ne "")
    {
        $parameters += " -pollingtime " + $txtPolling.Text
    }
    if ($txtPurgePoll.Text -ne "")
    {
        $parameters += " -purgepollingtime " + $txtPurgePoll.Text
    }
    if ($chkNoPurge.Checked -eq $True)
    {
        $parameters += " -nopurge"
    }
    if ($chkReverse.Checked -eq $True)
    {
        $parameters += " -n"
    }
    if ($txtType.Text -ne "")
    {
        $parameters += " -type " + $txtType.Text
    }

    $svPathAndParams = "'" + $svPath + "'" + '"' + $parameters + '"';

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "schtasks.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $argString = '/create /tn ' + $serviceName + ' /ru ' + $username + ' /rp ' + $password + ' /rl HIGHEST /sc DAILY /st 00:00 /ri 5 /du 24:00 /tr ' + $svPathAndParams
    Write-Host $argString
    $pinfo.Arguments = $argString
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()

    if ($stderr.Contains("ERROR: No mapping between account names and security IDs was done"))
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Error has occurred!" + "`n" + "Task likely not created. Try manually creating." + "`n`n" + "ERROR: It appears that the username and/or password are incorrect. Please try again.",'OKOnly,SystemModal,Information', 'Warning')
    }
    elseif ($p.ExitCode -ne "0")
    {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Error has occurred!" + "`n" + "Task likely not created. Try manually creating." + "`n`n" + $stderr,'OKOnly,SystemModal,Information', 'Warning')
    }
    else
    {
        $objForm.Close()
    }

    })
$objForm.Controls.Add($OKButton)

#region Cancel
##### - Create the Cancel Button - #####
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(290,320)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)
#endregion

#region Headers
##### - Create the Divs and Headers - #####
$div1 = New-Object System.Windows.Forms.Label
$div1.Location = New-Object System.Drawing.Size(40,30)
$div1.Size = New-Object System.Drawing.Size(200,2) 
$div1.Text = ""
$div1.Autosize = $False
$div1.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$objForm.Controls.Add($div1)

$header1 = New-Object System.Windows.Forms.Label
$header1.Location = New-Object System.Drawing.Size(40,10)
$header1.Size = New-Object System.Drawing.Size(200,20) 
$header1.Text = "Basic"
$header1.TextAlign = "MiddleCenter"
$header1.Font = New-Object System.Drawing.Font("arial",12,[System.Drawing.FontStyle]::Bold)
$objForm.Controls.Add($header1)

$div2 = New-Object System.Windows.Forms.Label
$div2.Location = New-Object System.Drawing.Size(335,30)
$div2.Size = New-Object System.Drawing.Size(200,2) 
$div2.Text = ""
$div2.Autosize = $False
$div2.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$objForm.Controls.Add($div2)

$header2 = New-Object System.Windows.Forms.Label
$header2.Location = New-Object System.Drawing.Size(335,10)
$header2.Size = New-Object System.Drawing.Size(200,20) 
$header2.Text = "Advanced"
$header2.TextAlign = "MiddleCenter"
$header2.Font = New-Object System.Drawing.Font("arial",12,[System.Drawing.FontStyle]::Bold)
$objForm.Controls.Add($header2)
#endregion

#region Basic Functions

    #region Task Name
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Location = New-Object System.Drawing.Size(6,50)
    $lblName.Size = New-Object System.Drawing.Size(65,20) 
    $lblName.Text = "Task Name:"
    $lblName.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblName)

    $txtName = New-Object System.Windows.Forms.TextBox
    $txtName.Location = New-Object System.Drawing.Size(75,50)
    $txtName.Size = New-Object System.Drawing.Size(205,20) 
    $txtName.Text = "WinshuttleSVSERVICE"
    $objForm.Controls.Add($txtName)
    #endregion

    #region Path
    $lblPath = New-Object System.Windows.Forms.Label
    $lblPath.Location = New-Object System.Drawing.Size(6,100)
    $lblPath.Size = New-Object System.Drawing.Size(65,20) 
    $lblPath.Text = "EXE Path:"
    $lblPath.TextAlign = "MiddleRight"
    #$lblPath.BackColor = "Red"
    $objForm.Controls.Add($lblPath)

    $txtPath = New-Object System.Windows.Forms.TextBox
    $txtPath.Location = New-Object System.Drawing.Size(75,100)
    $txtPath.Size = New-Object System.Drawing.Size(205,20)
    $txtPath.AutoSize = $False 
    $txtPath.Text = "C:\Program Files\ShareVis\bin\svservice.exe"
    $txtPath.Font = New-Object System.Drawing.Font("arial",7)
    $objForm.Controls.Add($txtPath)
    #endregion

    #region Exit?
    $lblExit = New-Object System.Windows.Forms.Label
    $lblExit.Location = New-Object System.Drawing.Size(6,150)
    $lblExit.Size = New-Object System.Drawing.Size(65,20) 
    $lblExit.Text = "Exit?:"
    $lblExit.TextAlign = "MiddleRight"
    #$lblPath.BackColor = "Red"
    $objForm.Controls.Add($lblExit)

    $chkExit = New-Object System.Windows.Forms.CheckBox
    $chkExit.Location = New-Object System.Drawing.Size(75,150)
    $chkExit.Size = New-Object System.Drawing.Size(75,20)
    $chkExit.Checked = $True
    $objForm.Controls.Add($chkExit)
    #endregion

    #region Username
    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Location = New-Object System.Drawing.Size(6,200)
    $lblUser.Size = New-Object System.Drawing.Size(65,20) 
    $lblUser.Text = "Username:"
    $lblUser.TextAlign = "MiddleRight"
    #$lblUser.BackColor = "Red"
    $objForm.Controls.Add($lblUser)

    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = New-Object System.Drawing.Size(75,200)
    $txtUser.Size = New-Object System.Drawing.Size(205,20) 
    $txtUser.Text = "domain\user"
    $objForm.Controls.Add($txtUser)
    #endregion

    #region Password
    $lblPassword = New-Object System.Windows.Forms.Label
    $lblPassword.Location = New-Object System.Drawing.Size(6,250)
    $lblPassword.Size = New-Object System.Drawing.Size(65,20) 
    $lblPassword.Text = "Password:"
    $lblPassword.TextAlign = "MiddleRight"
    #$lblUser.BackColor = "Red"
    $objForm.Controls.Add($lblPassword)

    $txtPassword = New-Object System.Windows.Forms.TextBox
    $txtPassword.Location = New-Object System.Drawing.Size(75,250)
    $txtPassword.Size = New-Object System.Drawing.Size(205,20) 
    $txtPassword.Text = ""
    $txtPassword.PasswordChar = "•"
    #$txtPassword.Font = New-Object System.Drawing.Font("arial",12,[System.Drawing.FontStyle]::Bold)
    $objForm.Controls.Add($txtPassword)
    #endregion

#endregion

#region Advanced Functions
    $ToolTip = New-Object System.Windows.Forms.ToolTip
    $ToolTip.IsBalloon = $true

    #region Config Path
    $lblCfgPath = New-Object System.Windows.Forms.Label
    $lblCfgPath.Location = New-Object System.Drawing.Size(294,50)
    $lblCfgPath.Size = New-Object System.Drawing.Size(70,20) 
    $lblCfgPath.Text = "Config Path:"
    $lblCfgPath.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblCfgPath)
    $ToolTip.SetToolTip($lblCfgPath, "This option will allow you to specify`nthe exact Web Application you want`nto point this task to.")

    $txtCfgPath = New-Object System.Windows.Forms.TextBox
    $txtCfgPath.Location = New-Object System.Drawing.Size(369,50)
    $txtCfgPath.Size = New-Object System.Drawing.Size(205,20) 
    $txtCfgPath.Text = ""
    $objForm.Controls.Add($txtCfgPath)
    #endregion

    #region Polling Time
    $lblPolling = New-Object System.Windows.Forms.Label
    $lblPolling.Location = New-Object System.Drawing.Size(294,100)
    $lblPolling.Size = New-Object System.Drawing.Size(100,20) 
    $lblPolling.Text = "Polling Time:"
    $lblPolling.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblPolling)
    $ToolTip.SetToolTip($lblPolling, "This option will allow you to specify`nthe exact milliseconds you want`nto rest after the task completes.")

    $txtPolling = New-Object System.Windows.Forms.TextBox
    $txtPolling.Location = New-Object System.Drawing.Size(400,100)
    $txtPolling.Size = New-Object System.Drawing.Size(174,20) 
    $txtPolling.Text = ""
    $objForm.Controls.Add($txtPolling)
    #endregion

    #region Purge Polling Time
    $lblPurgePoll = New-Object System.Windows.Forms.Label
    $lblPurgePoll.Location = New-Object System.Drawing.Size(294,150)
    $lblPurgePoll.Size = New-Object System.Drawing.Size(100,20) 
    $lblPurgePoll.Text = "Purge Poll Time:"
    $lblPurgePoll.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblPurgePoll)
    $ToolTip.SetToolTip($lblPurgePoll, "This option will allow you to specify`nthe exact milliseconds you want`nto wait before purging records.")

    $txtPurgePoll = New-Object System.Windows.Forms.TextBox
    $txtPurgePoll.Location = New-Object System.Drawing.Size(400,150)
    $txtPurgePoll.Size = New-Object System.Drawing.Size(174,20) 
    $txtPurgePoll.Text = ""
    $objForm.Controls.Add($txtPurgePoll)
    #endregion

    #region No Purge
    $lblNoPurge = New-Object System.Windows.Forms.Label
    $lblNoPurge.Location = New-Object System.Drawing.Size(314,200)
    $lblNoPurge.Size = New-Object System.Drawing.Size(65,20) 
    $lblNoPurge.Text = "No Purge:"
    $lblNoPurge.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblNoPurge)
    $ToolTip.SetToolTip($lblNoPurge, "This option will allow you to specify`nwhether you want to purge records`nautomatically or not.")

    $chkNoPurge = New-Object System.Windows.Forms.CheckBox
    $chkNoPurge.Location = New-Object System.Drawing.Size(383,200)
    $chkNoPurge.Size = New-Object System.Drawing.Size(20,20)
    $chkNoPurge.Checked = $False
    $objForm.Controls.Add($chkNoPurge)
    #endregion

    #region Reverse Type
    $lblReverse = New-Object System.Windows.Forms.Label
    $lblReverse.Location = New-Object System.Drawing.Size(420,200)
    $lblReverse.Size = New-Object System.Drawing.Size(85,20) 
    $lblReverse.Text = "Reverse Type:"
    $lblReverse.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblReverse)
    $ToolTip.SetToolTip($lblReverse, "This option will allow you to specify`nthat you want to capture everything`nthat is not listed in the Type field.")

    $chkReverse = New-Object System.Windows.Forms.CheckBox
    $chkReverse.Location = New-Object System.Drawing.Size(509,200)
    $chkReverse.Size = New-Object System.Drawing.Size(20,20)
    $chkReverse.Checked = $False
    $objForm.Controls.Add($chkReverse)
    #endregion

    #region Type
    $lblType = New-Object System.Windows.Forms.Label
    $lblType.Location = New-Object System.Drawing.Size(294,250)
    $lblType.Size = New-Object System.Drawing.Size(65,20) 
    $lblType.Text = "Type:"
    $lblType.TextAlign = "MiddleRight"
    $objForm.Controls.Add($lblType)
    $ToolTip.SetToolTip($lblType, "This option will allow you to specify`na comma-separated list of Task Types`nthat the task will specifically run.")

    $txtType = New-Object System.Windows.Forms.TextBox
    $txtType.Location = New-Object System.Drawing.Size(369,250)
    $txtType.Size = New-Object System.Drawing.Size(205,60) 
    $txtType.Text = ""
    $txtType.AcceptsReturn = $true
    $txtType.Multiline = $true
    $txtType.Scrollbars = 'Both'
    $objForm.Controls.Add($txtType)
    #endregion

#endregion

##### - Create the Border Panel - #####
$panel1 = New-Object System.Windows.Forms.Panel
$panel1.Location = New-Object System.Drawing.Size(5,5)
$panel1.Size = New-Object System.Drawing.Size(280,310)
$panel1.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$objForm.Controls.Add($panel1)
$panel2 = New-Object System.Windows.Forms.Panel
$panel2.Location = New-Object System.Drawing.Size(290,5)
$panel2.Size = New-Object System.Drawing.Size(289,310)
$panel2.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$objForm.Controls.Add($panel2)

##### - KeyDowns - #####
$objForm.AcceptButton = $OKButton
$txtUser.Add_Click({$txtUser.SelectAll()})

##### - Bring UI to Front - #####
$objForm.Topmost = $True

##### - Show the Form - #####
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

#schtasks /create /tn $serviceName /ru $username /rp $password /rl HIGHEST /sc DAILY /st 00:00 /ri 5 /du 24:00 /tr $svPathAndParams