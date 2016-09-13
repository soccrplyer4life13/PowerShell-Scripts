### Main Function
function CheckPermissions_Main {

if ([threading.thread]::CurrentThread.GetApartmentState() -eq "MTA") {
   & $env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe -sta $MyInvocation.ScriptName
   Exit
}

#region Import Assemblies
	[void][reflection.assembly]::Load('mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.ServiceProcess, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
#endregion

#region Form Object Declarations
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object 'System.Windows.Forms.Form'
	$tabcontrolWizard = New-Object 'System.Windows.Forms.TabControl'
	$tabpageStep1 = New-Object 'System.Windows.Forms.TabPage'
	$labelProcessing = New-Object 'System.Windows.Forms.Label'
	$dataListUsers = New-Object 'System.Windows.Forms.DataGridView'
    $dataListDBs = New-Object 'System.Windows.Forms.DataGridView'
	$buttonCheckPermissions = New-Object 'System.Windows.Forms.Button'
	$buttonSQLConnect = New-Object 'System.Windows.Forms.Button'
	$txtSrvName = New-Object 'System.Windows.Forms.TextBox'
	$labelEnterTheNameinstance = New-Object 'System.Windows.Forms.Label'
	$labelEnterEachDomainUsern = New-Object 'System.Windows.Forms.Label'
    $lblWFAdmin = New-Object 'System.Windows.Forms.Label'
    $lblWFSQL = New-Object 'System.Windows.Forms.Label'
    $lblWS = New-Object 'System.Windows.Forms.Label'
    $lblSPFarm = New-Object 'System.Windows.Forms.Label'
    $lblWFAdmin1 = New-Object 'System.Windows.Forms.Label'
    $lblWFSQL1 = New-Object 'System.Windows.Forms.Label'
    $lblWS1 = New-Object 'System.Windows.Forms.Label'
    $lblSPFarm1 = New-Object 'System.Windows.Forms.Label'
	$tabResults = New-Object 'System.Windows.Forms.TabPage'
	$txtResults = New-Object 'System.Windows.Forms.RichTextBox'
	$names = New-Object 'System.Windows.Forms.DataGridViewTextBoxColumn'
    $dbs = New-Object 'System.Windows.Forms.DataGridViewComboBoxColumn'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
#endregion
	
#region Form Load Function
	$form1_Load={
		#TODO: Initialize Form Controls here
		$dataListUsers.RowCount = 4
        $dataListDBs.RowCount = 4
		$dataListUsers.ClearSelection()
        $dataListDBs.Visible = $false
        $labelEnterEachDomainUsern.Visible = $false
        $dataListUsers.Visible = $false
        $lblWFAdmin.Visible = $false
        $lblWFSQL.Visible = $false
        $lblWS.Visible = $false
        $lblSPFarm.Visible = $false
        $buttonCheckPermissions.Visible = $false
        $form1.Width = 480
        $form1.Height = 150
        $tabcontrolWizard.TabPages.Remove($tabResults)
	}
#endregion

#region Connect to SQL Button Click
    $buttonSQLConnect_Click={
		#TODO: Place custom script here
		Test-SQLConn -srvConn $txtSrvName.Text
	}
#endregion

#region Connect to SQL Helper Function
    Function Test-SQLConn ($srvConn)
    {
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
        #add-type -Path "C:\Microsoft.SqlServer.Smo.dll"
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.ConnectionInfo.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.CustomControls.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.GridControl.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.InstApi.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.RegSvrEnum.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.Replication.BusinessLogicSupport.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.Rmo.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.ServiceBrokerEnum.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.Setup.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.Smo.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.SmoEnum.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.SqlEnum.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.SqlTDiagM.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.SString.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.WizardFrameworkLite.dll")
        [System.Reflection.Assembly]::LoadFrom("C:\dlls\Microsoft.SqlServer.WmiEnum.dll")

        $connectionString = "Data Source=$srvConn;Integrated Security=true;Connect Timeout=10;"
        $sqlConn = new-object ("Data.SqlClient.SqlConnection") $connectionString
        #trap
        #{
            #[System.Windows.Forms.MessageBox]::Show("Cannot connect to $srvConn`nPlease check the server and permissions of this account" , "Status")
           # continue
        #}
        #Write-Host $connectionString
        try{
            $sqlConn.Open()
        }
        catch{
            $errormessage = $_.Exception.Message
            [System.Windows.Forms.MessageBox]::Show("Cannot connect to $srvConn`nError: $errormessage" , "Status")
            #Write-Host $errormessage
        }
 
        if ($sqlConn.State -eq 'Open')
        {
            $sqlConn.Close();
            [System.Windows.Forms.MessageBox]::Show("Connection Successful to $srvConn!`nPlease select your databases" , "Status")
            $srv1 = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $srvConn
            foreach ($database in $srv1.Databases){
                #Write-Host $database
                for ($i = 0; $i -lt $dataListDBs.RowCount; $i++) {
                    #$dataListDBs.Rows[$i].Cells['dbs'].Add($database)
                    $cells = $dataListDBs.Rows[$i].Cells['dbs']
                    $cells.Items.Add($database.Name)
                }
            }
            $form1.Width = 580
            $form1.Height = 410
            $dataListDBs.Visible = $true
            $labelEnterEachDomainUsern.Visible = $true
            $dataListUsers.Visible = $true
            $lblWFAdmin.Visible = $true
            $lblWFSQL.Visible = $true
            $lblWS.Visible = $true
            $lblSPFarm.Visible = $true
            $buttonCheckPermissions.Visible = $true
        }
    }
#endregion
	
#region Check Permissions Button Click
	$buttonCheckPermissions_Click={
		$users = @()
        $usersIndex = @()
		for ($i = 0; $i -lt $dataListUsers.RowCount; $i++) {
			$user = $dataListUsers.Rows[$i].Cells['names'].Value
			if ($user)
			{
				$users += $user
                $usersIndex += $i
			}
		}
		$sqlServer = $txtSrvName.Text
		$labelProcessing.Visible = $true
		Start-Sleep -m 50
		Show-SQLUserPermissions -usr $users -usrIdx $usersIndex -svr $sqlServer
		$labelProcessing.Visible = $false
		$tabcontrolWizard.SelectTab($tabResults)
	}
#endregion
	
#region Show Permissions Results
	Function Show-SQLUserPermissions ($usr, $usrIdx, $svr)
	{
		[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
		
		# Suppress Error messages - They will be displayed at the end
		
		#$ErrorActionPreference = "SilentlyContinue"
		#cls
		
		# Pull a list of servers from a local text file
		
		$servers = $svr
		
		# Create an array for the username and each domain slash username
		
		$logins = $usr
        $loginsIndex = $usrIdx
		
		$txtResults.Clear()
        $txtResults.SelectionColor = [Drawing.Color]::Red
        $txtResults.AppendText("=======================================`n")
		$txtResults.AppendText("Server Permissions displayed below for:`n")
        foreach ($theLogin in $logins){
            $txtResults.AppendText("  ** $theLogin`n")
        }
        $txtResults.SelectionColor = [Drawing.Color]::Red
		$txtResults.AppendText("=======================================`n")
        $txtResults.SelectionFont = new Font($txtResults.Font, [Drawing.FontStyle]::Bold)
		$txtResults.AppendText("`nPermissions on the Server/instance:`n")
        $txtResults.AppendText("**********************************************************")
		#loop through each server and each database and display usernames, servers and databases
		foreach ($server in $servers)
		{
			$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
			
			foreach ($login in $logins)
			{
				
				if ($srv.Logins.Contains($login))
				{
					$txtResults.AppendText("`nLogin Name: $login ")
					foreach ($Role in $Srv.Roles)
					{
						$RoleMembers = $Role.EnumServerRoleMembers()
						
						if ($RoleMembers -contains $login)
						{
							$txtResults.AppendText("`n  ** Member of $Role")
						}
					}
					$txtResults.AppendText("`n")
				}
				
				else
				{
					
				}
			}
		}
        $txtResults.AppendText("`n**********************************************************`n")
		$txtResults.AppendText("`nPermissions on each Database:`n")
		$txtResults.AppendText("**********************************************************")
		foreach ($server in $servers)
		{
			$srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
            for ($z = 0; $z -lt $logins.count; $z++)
            {
				foreach ($database in $srv.Databases)
				{
                    switch ($database.Name){
                       $dataListDBs[0].Rows[0].Cells.Value {
                            $currentDB = $database.EnumLoginMappings()
                            foreach ($curRow in $currentDB.Rows)
					        {
                                $dboFound = $false
						        foreach ($curCol in $curRow.Table.Columns)
						        {
                                    if (($curCol.ColumnName -eq "UserName" -and $curRow[$curCol]-eq "dbo") -or $dboFound)
                                    {
                                        $current = $curRow[$curCol]
                                        if ($dboFound -and $curRow[$curCol]-eq $dataListUsers[0].Rows[$loginsIndex[$z]].Cells.Value){
                                            $txtName = $database.Name
                                            $zValueLogin = $logins[$z]
                                            $txtResults.AppendText("`nLogin: $zValueLogin     Database: $txtName")
                                            $txtResults.AppendText("`n$current is a DBO and therefore has all permissions!`n")
                                        }
                                        $dboFound = $true
                                    }
                                    elseif ($database.Name -eq $dataListDBs[0].Rows[0].Cells.Value -and $curCol.ColumnName -eq "LoginName" -and $curRow[$curCol]-eq $dataListUsers[0].Rows[$loginsIndex[$z]].Cells.Value){
                                        $txtName = $database.Name
                                        $zValueLogin = $logins[$z]
                                        $txtResults.AppendText("`nLogin: $zValueLogin     Database: $txtName")
                                        $theUser = $curRow[$curCol]
                                        if ($database.Users.Contains($theUser))
                                        {

                                        $theRole = $database.Roles['db_datareader']
                                        $theMembers = $theRole.EnumMembers()
							                        if ($theMembers -contains $theUser)
							                        {
								                        $txtResults.AppendText("`n  ** SUCCESS ** Member of $theRole Role")
                                                        $isFound = $false
                                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                                            foreach($prmsn in $databasePermission.PermissionType){
                                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                                    $isFound = $true    
                                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                                            continue 
                                                                 }
                                                            }

                                                        }
                                                        if ($isFound -eq $false){
                                                            $txtResults.AppendText("`n  ** EXECUTE permissions ARE NOT granted!`n")
                                                        }
                                                        $txtResults.AppendText("`n--------------------------------------------------------------------------------------`n")
							                        }
                                                else{
                                                    $txtResults.AppendText("`nThe account does not explicitly have the 'db_datareader' role. Below is a list of the account's roles.")
                                                    foreach ($role in $Database.Roles){
                                                        $RoleMembers = $Role.EnumMembers()
							                            if ($RoleMembers -contains $theUser)
							                            {
								                            $txtResults.AppendText("`n  ** Member of $Role Role")
                                                            #$txtResults.AppendText("`n  **SUCCESS** Member of $theRole Role")
                                                        $isFound = $false
                                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                                            foreach($prmsn in $databasePermission.PermissionType){
                                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                                    $isFound = $true    
                                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                                            continue 
                                                                 }
                                                            }

                                                        }
                                                        if ($isFound -eq $false){
                                                            $txtResults.AppendText("`n  ** EXECUTE permissions ARE NOT granted!`n")
                                                        }
                                                            $txtResults.AppendText("`n--------------------------------------------------------------------------------------`n")
							                            }
                                                    }
                                                }
						                    }
                                        else
                                        {
                                            $txtResults.AppendText("`nThis login - $theUser - does not have any roles assigned to it`n")
                                            $isFound = $false
                                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                                            foreach($prmsn in $databasePermission.PermissionType){
                                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                                    $isFound = $true    
                                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                                            continue 
                                                                 }
                                                            }

                                                        }
                                                        if ($isFound -eq $false){
                                                            $txtResults.AppendText("  ** EXECUTE permissions ARE NOT granted!`n")
                                                        }
                                            $txtResults.AppendText("--------------------------------------------------------------------------------------`n")
                                        }
                                    }
						        }
					        }
                       }
                       $dataListDBs[0].Rows[1].Cells.Value {
                            $currentDB = $database.EnumLoginMappings()
                            foreach ($curRow in $currentDB.Rows)
					        {
						        $dboFound = $false
						        foreach ($curCol in $curRow.Table.Columns)
						        {
                                    if (($curCol.ColumnName -eq "UserName" -and $curRow[$curCol]-eq "dbo") -or $dboFound)
                                    {
                                        $current = $curRow[$curCol]
                                        if ($dboFound -and $curRow[$curCol]-eq $dataListUsers[0].Rows[$loginsIndex[$z]].Cells.Value){
                                            $txtName = $database.Name
                                            $zValueLogin = $logins[$z]
                                            $txtResults.AppendText("`nLogin: $zValueLogin     Database: $txtName")
                                            $txtResults.AppendText("`n$current is a DBO and therefore has all permissions!`n")
                                        }
                                        $dboFound = $true
                                    }
                                    elseif ($database.Name -eq $dataListDBs[0].Rows[1].Cells.Value -and $curCol.ColumnName -eq "LoginName" -and $curRow[$curCol]-eq $dataListUsers[0].Rows[$loginsIndex[$z]].Cells.Value){
                                        $txtName = $database.Name
                                        $zValueLogin = $logins[$z]
                                        $txtResults.AppendText("`nLogin: $zValueLogin     Database: $txtName")
                                        $theUser = $curRow[$curCol]
                                        if ($database.Users.Contains($theUser))
                                        {

                                        $theRole = $database.Roles['WSS_Content_Application_Pools']
                                        $theMembers = $theRole.EnumMembers()
							                        if ($theMembers -contains $theUser)
							                        {
								                        $txtResults.AppendText("`n  ** SUCCESS ** Member of $theRole Role")
                                                        $isFound = $false
                                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                                            foreach($prmsn in $databasePermission.PermissionType){
                                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                                    $isFound = $true    
                                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                                            continue 
                                                                 }
                                                            }

                                                        }
                                                        if ($isFound -eq $false){
                                                            $txtResults.AppendText("`n  ** EXECUTE permissions ARE NOT granted!`n")
                                                        }
                                                        $txtResults.AppendText("`n--------------------------------------------------------------------------------------`n")
							                        }
                                                else{
                                                    $txtResults.AppendText("`nThe account does not explicitly have the 'WSS_Content_Application_Pools' role. Below is a list of the account's roles.")
                                                    foreach ($role in $Database.Roles){
                                                        $RoleMembers = $Role.EnumMembers()
							                            if ($RoleMembers -contains $theUser)
							                            {
								                            $txtResults.AppendText("`n  ** Member of $Role Role")
							                            #$txtResults.AppendText("`n  **SUCCESS** Member of $theRole Role")
                                                        $isFound = $false
                                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                                            foreach($prmsn in $databasePermission.PermissionType){
                                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                                    $isFound = $true    
                                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                                            continue 
                                                                 }
                                                            }

                                                        }
                                                        if ($isFound -eq $false){
                                                            $txtResults.AppendText("`n  ** EXECUTE permissions ARE NOT granted!`n")
                                                        }
                                                            $txtResults.AppendText("`n--------------------------------------------------------------------------------------`n")
							                            }
                                                    }
                                                }
						                    }
                                        else
                                        {
                                            $txtResults.AppendText("`nThis login - $theUser - does not have any roles assigned to it`n")
                                            $isFound = $false
                                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                                            foreach($prmsn in $databasePermission.PermissionType){
                                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                                    $isFound = $true    
                                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                                            continue 
                                                                 }
                                                            }

                                                        }
                                                        if ($isFound -eq $false){
                                                            $txtResults.AppendText("  ** EXECUTE permissions ARE NOT granted!`n")
                                                        }
                                                        $txtResults.AppendText("--------------------------------------------------------------------------------------`n")
                                        }
                                    }
						        }
					        }
                       }
                       $dataListDBs[0].Rows[2].Cells.Value {
                            $currentDB = $database.EnumLoginMappings()
                            foreach ($curRow in $currentDB.Rows)
					        {
                                $dboFound = $false
						        foreach ($curCol in $curRow.Table.Columns)
						        {
                                    if (($curCol.ColumnName -eq "UserName" -and $curRow[$curCol]-eq "dbo") -or $dboFound)
                                    {
                                        $current = $curRow[$curCol]
                                        if ($dboFound -and $curRow[$curCol]-eq $dataListUsers[0].Rows[$loginsIndex[$z]].Cells.Value){
                                            $txtName = $database.Name
                                            $zValueLogin = $logins[$z]
                                            $txtResults.AppendText("`nLogin: $zValueLogin     Database: $txtName")
                                            $txtResults.AppendText("`n$current is a DBO and therefore has all permissions!`n")
                                        }
                                        $dboFound = $true
                                    }
                                    elseif ($database.Name -eq $dataListDBs[0].Rows[2].Cells.Value -and $curCol.ColumnName -eq "LoginName" -and $curRow[$curCol]-eq $dataListUsers[0].Rows[$loginsIndex[$z]].Cells.Value){
                                        $txtName = $database.Name
                                        $zValueLogin = $logins[$z]
                                        $txtResults.AppendText("`nLogin: $zValueLogin     Database: $txtName")
                                        $isFound = $false
                                        foreach($databasePermission in $database.EnumDatabasePermissions($zValueLogin)){
                                            foreach($prmsn in $databasePermission.PermissionType){
                                                if ($databasePermission.PermissionState -eq "Grant" -and $prmsn.Execute -and $isFound -eq $false){
                                                    $txtResults.AppendText("`n  ** EXECUTE permissions ARE granted!`n")
                                                    $isFound = $true    
                                                }elseif ($prmsn.Execute -eq $false -and $isFound -eq $false){
                                                            continue 
                                                    }
                                            }

                                        }
                                        if ($isFound -eq $false){
                                            $txtResults.AppendText("`n  ** EXECUTE permissions ARE NOT granted!`n")
                                        }
                                        $txtResults.AppendText("`n--------------------------------------------------------------------------------------`n")
							        }
						        }
					        }
                       }
                       $dataListDBs[0].Rows[3].Cells.Value {
                            #TO DO: Possible eShuttleDB Expansion
                       }
                    }					
				}
            }
		}
		$txtResults.AppendText("`n`n`n=======================================")
		$txtResults.AppendText("`nCOMPLETED SUCCESSFULLY`nIf any info is blank, check connectivity and permissions.")
		$txtResults.AppendText("`n=======================================")	
        $txtResults.SelectionStart = "0"
        $txtResults.ScrollToCaret()
        $found = $false
        foreach($tab in $tabcontrolWizard.TabPages){
            if ($tab.Name -eq "tabResults"){
                $found = $true
            }
        }
        if (!$found){
            $tabcontrolWizard.TabPages.Add($tabResults)
        }
	}
#endregion	

#region Form Controls/Layout
	$form1.SuspendLayout()
	$tabcontrolWizard.SuspendLayout()
	$tabpageStep1.SuspendLayout()
	$tabResults.SuspendLayout()

	#region Form Object
	$form1.Controls.Add($tabcontrolWizard)
	$form1.ClientSize = '566, 386'
	$form1.Name = "form1"
	$form1.Text = "Check Permissions"
    $form1.ShowIcon = $false
    $form1.StartPosition = "CenterScreen"
	$form1.add_Load($form1_Load)
	#endregion

	#region Tab Control Object
	$tabcontrolWizard.Controls.Add($tabpageStep1)
	$tabcontrolWizard.Controls.Add($tabResults)
	$tabcontrolWizard.Anchor = 'Top, Bottom, Left, Right'
	$tabcontrolWizard.Location = '12, 12'
	$tabcontrolWizard.Name = "tabcontrolWizard"
	$tabcontrolWizard.SelectedIndex = 0
	$tabcontrolWizard.Size = '541, 362'
	$tabcontrolWizard.TabIndex = 1
	#endregion

    #region Tab Page 1 Object
	$tabpageStep1.Controls.Add($labelProcessing)
	$tabpageStep1.Controls.Add($dataListUsers)
    $tabpageStep1.Controls.Add($dataListDBs)
	$tabpageStep1.Controls.Add($buttonCheckPermissions)
    $tabpageStep1.Controls.Add($buttonSQLConnect)
	$tabpageStep1.Controls.Add($txtSrvName)
	$tabpageStep1.Controls.Add($labelEnterTheNameinstance)
	$tabpageStep1.Controls.Add($labelEnterEachDomainUsern)
    $tabpageStep1.Controls.Add($lblWFAdmin)
    $tabpageStep1.Controls.Add($lblWFSQL)
    $tabpageStep1.Controls.Add($lblWS)
    $tabpageStep1.Controls.Add($lblSPFarm)
    $tabpageStep1.Controls.Add($lblWFAdmin1)
    $tabpageStep1.Controls.Add($lblWFSQL1)
    $tabpageStep1.Controls.Add($lblWS1)
    $tabpageStep1.Controls.Add($lblSPFarm1)
	$tabpageStep1.Location = '4, 22'
	$tabpageStep1.Name = "tabpageStep1"
	$tabpageStep1.Padding = '3, 3, 3, 3'
	$tabpageStep1.Size = '433, 250'
	$tabpageStep1.TabIndex = 0
	$tabpageStep1.Text = "Enter Account Info"
	$tabpageStep1.UseVisualStyleBackColor = $True
	#endregion

	#region Processing Label Object
	$labelProcessing.BackColor = 'White'
	$labelProcessing.Font = "Microsoft Sans Serif, 18pt, style=Bold"
	$labelProcessing.Location = '0, 0'
	$labelProcessing.Name = "labelProcessing"
	$labelProcessing.Size = '550, 350'
	$labelProcessing.TabIndex = 5
	$labelProcessing.Text = "Processing..."
	$labelProcessing.TextAlign = 'MiddleCenter'
	$labelProcessing.Visible = $False
	#endregion

	#region Domain/Users List Object
	$dataListUsers.BackgroundColor = 'Control'
	$dataListUsers.BorderStyle = 'None'
	$dataListUsers.ColumnHeadersHeightSizeMode = 'DisableResizing'
	$dataListUsers.ColumnHeadersVisible = $False
	[void]$dataListUsers.Columns.Add($names)
	$dataListUsers.EditMode = 'EditOnEnter'
	$dataListUsers.Location = '6, 183'
	$dataListUsers.MultiSelect = $False
	$dataListUsers.Name = "dataListUsers"
	$dataListUsers.RowHeadersVisible = $False
	$dataListUsers.RowHeadersWidth = 4
	$dataListUsers.RowHeadersWidthSizeMode = 'DisableResizing'
	$dataListUsers.ScrollBars = 'None'
	$dataListUsers.Size = '418, 89'
	$dataListUsers.TabIndex = 6
    #endregion

    #region Databases List Object
	$dataListDBs.BackgroundColor = 'Control'
	$dataListDBs.BorderStyle = 'None'
	$dataListDBs.ColumnHeadersHeightSizeMode = 'DisableResizing'
	$dataListDBs.ColumnHeadersVisible = $False
	[void]$dataListDBs.Columns.Add($dbs)
	$dataListDBs.EditMode = 'EditOnEnter'
	$dataListDBs.Location = '6, 64'
	$dataListDBs.MultiSelect = $False
	$dataListDBs.Name = "dataListDBs"
	$dataListDBs.RowHeadersVisible = $False
	$dataListDBs.RowHeadersWidth = 4
	$dataListDBs.RowHeadersWidthSizeMode = 'DisableResizing'
	$dataListDBs.ScrollBars = 'None'
	$dataListDBs.Size = '418, 89'
	$dataListDBs.TabIndex = 6
	#endregion

	#region Check Permissions Button Object
	$buttonCheckPermissions.Location = '195, 285'
	$buttonCheckPermissions.Name = "buttonCheckPermissions"
	$buttonCheckPermissions.Size = '128, 30'
	$buttonCheckPermissions.TabIndex = 4
	$buttonCheckPermissions.Text = "Check Permissions"
	$buttonCheckPermissions.UseVisualStyleBackColor = $True
	$buttonCheckPermissions.add_Click($buttonCheckPermissions_Click)
    #endregion

    #region SQL Connect Button Object
	$buttonSQLConnect.Location = '375, 30'
	$buttonSQLConnect.Name = "buttonSQLConnect"
	$buttonSQLConnect.Size = '50, 20'
	$buttonSQLConnect.TabIndex = 4
	$buttonSQLConnect.Text = "-->"
	$buttonSQLConnect.UseVisualStyleBackColor = $True
	$buttonSQLConnect.add_Click($buttonSQLConnect_Click)
	#endregion

	#region Server Name Textbox Object
	$txtSrvName.Location = '6, 30'
	$txtSrvName.Name = "txtSrvName"
	$txtSrvName.Size = '365, 20'
	$txtSrvName.TabIndex = 3
	$txtSrvName.Text = "sea-en-vstsup4"
	#endregion

	#region Server Name Label Object
	$labelEnterTheNameinstance.AutoSize = $True
	$labelEnterTheNameinstance.Location = '9, 14'
	$labelEnterTheNameinstance.Name = "labelEnterTheNameinstance"
	$labelEnterTheNameinstance.Size = '212, 13'
	$labelEnterTheNameinstance.TabIndex = 2
	$labelEnterTheNameinstance.Text = "Enter the name/instance of the SQL Server"
	#endregion

	#region Domain/Username Label Object
	$labelEnterEachDomainUsern.AutoSize = $True
	$labelEnterEachDomainUsern.Location = '9, 167'
	$labelEnterEachDomainUsern.Name = "labelEnterEachDomainUsern"
	$labelEnterEachDomainUsern.Size = '154, 13'
	$labelEnterEachDomainUsern.TabIndex = 0
	$labelEnterEachDomainUsern.Text = "Enter each Domain\Username:"
	#endregion

    #region Label Objects
	$lblWFAdmin.AutoSize = $True
	$lblWFAdmin.Location = '425, 188'
	$lblWFAdmin.Name = "lblWFAdmin"
	$lblWFAdmin.Size = '154, 13'
	$lblWFAdmin.TabIndex = 0
	$lblWFAdmin.Text = "<- Workflow Admin"
    $lblWFAdmin1.AutoSize = $True
	$lblWFAdmin1.Location = '425, 69'
	$lblWFAdmin1.Name = "lblWFAdmin"
	$lblWFAdmin1.Size = '154, 13'
	$lblWFAdmin1.TabIndex = 0
	$lblWFAdmin1.Text = "<- Content DB"

	$lblWFSQL.AutoSize = $True
	$lblWFSQL.Location = '425, 210'
	$lblWFSQL.Name = "lblWFSQL"
	$lblWFSQL.Size = '154, 13'
	$lblWFSQL.TabIndex = 0
	$lblWFSQL.Text = "<- Workflow SQL"
    $lblWFSQL1.AutoSize = $True
	$lblWFSQL1.Location = '425, 91'
	$lblWFSQL1.Name = "lblWFSQL"
	$lblWFSQL1.Size = '154, 13'
	$lblWFSQL1.TabIndex = 0
	$lblWFSQL1.Text = "<- Config DB"

	$lblWS.AutoSize = $True
	$lblWS.Location = '425, 232'
	$lblWS.Name = "lblWS"
	$lblWS.Size = '154, 13'
	$lblWS.TabIndex = 0
	$lblWS.Text = "<- Winshuttle Server"
    $lblWS1.AutoSize = $True
	$lblWS1.Location = '425, 113'
	$lblWS1.Name = "lblWS"
	$lblWS1.Size = '154, 13'
	$lblWS1.TabIndex = 0
	$lblWS1.Text = "<- Workflow DB"

	$lblSPFarm.AutoSize = $True
	$lblSPFarm.Location = '425, 254'
	$lblSPFarm.Name = "lblSPFarm"
	$lblSPFarm.Size = '154, 13'
	$lblSPFarm.TabIndex = 0
	$lblSPFarm.Text = "<- SharePoint Farm"
    $lblSPFarm1.AutoSize = $True
	$lblSPFarm1.Location = '425, 135'
	$lblSPFarm1.Name = "lblSPFarm"
	$lblSPFarm1.Size = '154, 13'
	$lblSPFarm1.TabIndex = 0
	$lblSPFarm1.Text = "<- TBD"
	#endregion

	#region Results Tab Object
	$tabResults.Controls.Add($txtResults)
	$tabResults.Location = '4, 22'
	$tabResults.Name = "tabResults"
	$tabResults.Padding = '3, 3, 3, 3'
	$tabResults.Size = '433, 250'
	$tabResults.TabIndex = 1
	$tabResults.Text = "Results"
	$tabResults.UseVisualStyleBackColor = $True
	#endregion

	#region Results Textbox Object
	$txtResults.Location = '6, 6'
	$txtResults.Name = "txtResults"
	$txtResults.Size = '516, 310'
	$txtResults.TabIndex = 0
	$txtResults.Text = ""
    $txtResults.BackColor = "WhiteSmoke"
	#endregion

	#region Column Properties
	$names.HeaderText = "names"
	$names.Name = "names"
	$names.Width = 417
    $dbs.DisplayStyle = 'ComboBox'
	$dbs.HeaderText = "dbs"
	$dbs.Name = "dbs"
	$dbs.Width = 417
    #endregion

	$tabResults.ResumeLayout()
	$tabpageStep1.ResumeLayout()
	$tabcontrolWizard.ResumeLayout()
	$form1.ResumeLayout()
#endregion

#region Load/Cleanup Helper Functions (if new button click, modify this)	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonCheckPermissions.remove_Click($buttonCheckPermissions_Click)
            $buttonSQLConnect_Click.remove_Click($buttonSQLConnect_Click)   
			$form1.remove_Load($form1_Load)
			$form1.remove_Load($Form_StateCorrection_Load)
			$form1.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch [Exception]
		{ }
	}
#endregion

#region Cleanup and Show the Form
	#Save the initial state of the form
	$InitialFormWindowState = $form1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form1.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form1.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $form1.ShowDialog()
#endregion

} #End Function

#Call the form
CheckPermissions_Main | Out-Null
