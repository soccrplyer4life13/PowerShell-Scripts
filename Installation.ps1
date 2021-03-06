#######START SECTION FOR CHECK IF CENTRAL ALREADY INSTALLED#######
#################################################################
Add-PSSnapin Microsoft.SharePoint.PowerShell
$centralInstalled = 0;
$centralDBInstalled = 0;

$guid = "90ca8d1b-e05e-48b1-aa85-f333f2fb9f05"
$solution = (Get-SPSolution | where-object {$_.SolutionId -eq $guid})

    if ($solution -ne $null)
    {
        if ($solution.Deployed -eq $true)
        {
            $centralInstalled = 1;
            if (!([Diagnostics.Process]::GetCurrentProcess().Path -match '\\syswow64\\'))
            {
                $uninstallPath = "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
                $uninstallWow6432Path = "\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
                $centralDBInstalled = @(
                if (Test-Path "HKLM:$uninstallWow6432Path" ) { Get-ChildItem "HKLM:$uninstallWow6432Path"}
                if (Test-Path "HKLM:$uninstallPath" ) { Get-ChildItem "HKLM:$uninstallPath" }
                if (Test-Path "HKCU:$uninstallWow6432Path") { Get-ChildItem "HKCU:$uninstallWow6432Path"}
                if (Test-Path "HKCU:$uninstallPath" ) { Get-ChildItem "HKCU:$uninstallPath" }
                ) |
                ForEach-Object { Get-ItemProperty $_.PSPath } |
                Where-Object {
                    $_.DisplayName -like "Winshuttle CENTRAL Database" -and !$_.SystemComponent -and !$_.ReleaseType -and !$_.ParentKeyName -and ($_.UninstallString -or $_.NoRemove)
                } | Measure-Object | Select-Object -expand Count
            }
            else
            {
                "You are running 32-bit Powershell on 64-bit system. Please run 64-bit Powershell instead." | Write-Host -ForegroundColor Red
            }
            
        }
        else
        {
            Write-Host $solution.Name + "is installed, but has not been deployed"
        }
    }
    else
    {
        Write-Host "There are no solutions installed in this SharePoint Farm"
    }

###############################################################               
#######END SECTION FOR CHECK IF CENTRAL ALREADY INSTALLED#######

#######START SECTION FOR INSTALLING WINSHUTTLE CENTRAL#######
#############################################################

            if ($centralInstalled -eq 1 -and $centralDBInstalled -eq 1)
            {
                Write-Host "CENTRAL is fully installed"
            }
            else
            {
                if ($centralInstalled -eq 1 -and $centralDBInstalled -eq 0)
                {
                    Write-Host "CENTRAL Database has not been installed. Please run the eShuttleDBSetup file"
                }
                else
                {
                    #Get the current path of the script and add the exe to the path
                    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
                    
                    #Take the current path, from above, and add the EXE location to it
                    $msiFile = $scriptPath + '\CENTRAL\setup\CENTRAL for SP2007 and SP2010\Setup.exe'
                    
                    Write-Host $msiFile
                    
                    #Start the MSI with the parameters that have been passed on from the XML file
                    Start-Process -FilePath $msiFile -passthru | Wait-Process #Don't continue until installation is complete
                }
                Write-Host "CENTRAL =" $centralInstalled
                Write-Host "CENTRALDB =" $centralDBInstalled
            }
            
###########################################################               
#######END SECTION FOR INSTALLING WINSHUTTLE CENTRAL#######


#######START SECTION FOR CHECK IF SERVER ALREADY INSTALLED#######
#################################################################

$installed = 0;
if (!([Diagnostics.Process]::GetCurrentProcess().Path -match '\\syswow64\\'))
{
  $uninstallPath = "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
  $uninstallWow6432Path = "\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
  $installed = @(
  if (Test-Path "HKLM:$uninstallWow6432Path" ) { Get-ChildItem "HKLM:$uninstallWow6432Path"}
  if (Test-Path "HKLM:$uninstallPath" ) { Get-ChildItem "HKLM:$uninstallPath" }
  if (Test-Path "HKCU:$uninstallWow6432Path") { Get-ChildItem "HKCU:$uninstallWow6432Path"}
  if (Test-Path "HKCU:$uninstallPath" ) { Get-ChildItem "HKCU:$uninstallPath" }
  ) |
  ForEach-Object { Get-ItemProperty $_.PSPath } |
  Where-Object {
    $_.DisplayName -like "Winshuttle SERVER" -and !$_.SystemComponent -and !$_.ReleaseType -and !$_.ParentKeyName -and ($_.UninstallString -or $_.NoRemove)
  } | Measure-Object | Select-Object -expand Count
}
else
{
  "You are running 32-bit Powershell on 64-bit system. Please run 64-bit Powershell instead." | Write-Host -ForegroundColor Red
}

###############################################################               
#######END SECTION FOR CHECK IF SERVER ALREADY INSTALLED#######

#######START SECTION FOR CUSTOM POPUP BOX TO RECEIVE INPUT#######
#################################################################

function CustomInputBox([string] $title, [string] $message, [string] $defaultText) 
{
 [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
 [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
 $userForm = New-Object System.Windows.Forms.Form
 $userForm.Text = "$title"
 $userForm.Size = New-Object System.Drawing.Size(290,150)
 $userForm.StartPosition = "CenterScreen"
     $userForm.AutoSize = $False
     $userForm.MinimizeBox = $False
     $userForm.MaximizeBox = $False
     $userForm.SizeGripStyle= "Hide"
     $userForm.WindowState = "Normal"
     $userForm.FormBorderStyle="Fixed3D"
 
 $userForm.Controls.Add($browseButton)   
 $OKButton = New-Object System.Windows.Forms.Button
 $OKButton.Location = New-Object System.Drawing.Size(115,80)
 $OKButton.Size = New-Object System.Drawing.Size(75,23)
 $OKButton.Text = "OK"
 $OKButton.Add_Click({$value=$objTextBox.Text;$userForm.Close()})
 $userForm.Controls.Add($OKButton)
 $CancelButton = New-Object System.Windows.Forms.Button
 $CancelButton.Location = New-Object System.Drawing.Size(195,80)
 $CancelButton.Size = New-Object System.Drawing.Size(75,23)
 $CancelButton.Text = "Cancel"
 $CancelButton.Add_Click({$userForm.Close()})
 $userForm.Controls.Add($CancelButton)
 $userLabel = New-Object System.Windows.Forms.Label
 $userLabel.Location = New-Object System.Drawing.Size(10,20)
 $userLabel.Size = New-Object System.Drawing.Size(280,30)
 $userLabel.Text = "$message"
 $userForm.Controls.Add($userLabel) 
 $objTextBox = New-Object System.Windows.Forms.TextBox
 $objTextBox.Location = New-Object System.Drawing.Size(10,50)
 $objTextBox.Size = New-Object System.Drawing.Size(260,20)
 $objTextBox.Text="$defaultText"
 $userForm.Controls.Add($objTextBox) 
 $userForm.Topmost = $True
 $userForm.Opacity = 0.91
     $userForm.ShowIcon = $False
 $userForm.Add_Shown({$userForm.Activate()})
 [void] $userForm.ShowDialog()
 return $value

}

###############################################################               
#######END SECTION FOR CUSTOM POPUP BOX TO RECEIVE INPUT#######



#Get the current path of the script and add the xml to the path
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$fullPath = $scriptPath + '\FoundationConfig.xml'

#Read Configuration file into a variable
$xmlConfig = [xml](Get-Content $fullPath)

#Clear out $arguments
$arguments = ""

#######BEGIN SECTION FOR INSTALLING THE MANAGER PORTION OF SERVER#######
########################################################################

    #Read the TCP_PORT setting from the XML file
    $tcp = $xmlConfig.Configuration.Server.TCP_PORT
        if ($tcp -ne "")
        {
            $tcpArg = "TCP_PORT=" + $tcp + " "
            $arguments += $tcpArg
        }

    #Read the APPPOOL setting from the XML file
    $appPool = $xmlConfig.Configuration.Server.APPPOOL
        if ($appPool -ne "")
        {
            $appPoolArg = "APPPOOL=" + $appPool + " "
            $arguments += $appPoolArg
        }

    #Read the WS_USER setting from the XML file
    $wsuser = $xmlConfig.Configuration.Server.WS_USER
        if ($wsuser -ne "")
        {
            $wsuserArg = "WS_USER=" + $wsuser + " "
            $arguments += $wsuserArg
        }

    #Read the WS_PASS setting from the XML file
    $wspass = $xmlConfig.Configuration.Server.WS_PASS
        if ($wspass -ne "")
        {
            $wspassArg = "WS_PASS=" + $wspass + " "
            $arguments += $wspassArg
        }

    #Read the QUEUEMANAGER_CHECKED setting from the XML file
    $queueMgr = $xmlConfig.Configuration.Server.QUEUEMANAGER_CHECKED
        if ($queueMgr -ne "")
        {
            $queueMgrArg = "QUEUEMANAGER_CHECKED=" + $queueMgr + " "
            $arguments += $queueMgrArg
        }

    #Read the QUEUEPROCESSING_CHECKED setting from the XML file
    $queueProc = $xmlConfig.Configuration.Server.QUEUEPROCESSING_CHECKED
        if ($queueProc -ne "")
        {
            $queueProcArg = "QUEUEPROCESSING_CHECKED=" + $queueProc + " "
            $arguments += $queueProcArg
        }

        #Take the current path, from above, and add the MSI location to it
        $msiFile = $scriptPath + '.\WinshuttleSERVER_x64.msi'

        #Start the MSI with the parameters that have been passed on from the XML file
        Start-Process -FilePath $msiFile -argumentlist $arguments -passthru | Wait-Process #Don't continue until installation is complete
        
        #Clear out arguments variable once the process has completed
        $arguments = ""

######################################################################                
#######END SECTION FOR INSTALLING THE MANAGER PORTION OF SERVER#######

# If SERVER is already installed, we're done and let the process uninstall
if ($installed -eq "1")
{
    Exit
}

#######START SECTION FOR INSTALLING THE QUEUE DEPLOYMENT UTILITY#######
#######################################################################

$rabbitOwnServer = $xmlConfig.Configuration.Server.RABBIT_DIFF_SERVER
if ($rabbitOwnServer -eq "Yes" -or $rabbitOwnServer -eq "yes")
{
    #Handle if Rabbit was installed onto another server
}
else
{
    #Check to ensure that QueueDeployment.exe exists in the default directory
    $queueDeployPath = $xmlConfig.Configuration.Server.SERVER_INSTALL_DIR + "\Tools\QueueDeployment\QueueDeployment.exe"
        if (Test-Path $queueDeployPath)
        {
            #Check to ensure that RabbitMQ exists in the default directory
            $rabbitDeployPath = $xmlConfig.Configuration.Server.RABBIT_INSTALL_DIR + "\rabbitmq_server-2.8.6\sbin"
                if (Test-Path $rabbitDeployPath)
                {
                    #Run QueueDeployment.exe with switches for the RabbitMQ installation folder
                    $rabbitDeployPath | Clip
                    Start-Process -FilePath $queueDeployPath -PassThru | Out-Null #Wait-Process #Add Switches
                }
                else
                {
                    #Popup with input for path to RabbitMQ sbin folder
                    $newRabbitPath = CustomInputBox("RabbitMQ Installation Directory") ("RabbitMQ is not installed in the default directory. Please enter the full installation path of RabbitMQ...") ("")
                        if ( $newRabbitPath -ne $null ) 
                        {
                            $rabbitDeployPath = $newRabbitPath + "\sbin"
                            #Run QueueDeployment.exe with switches for the RabbitMQ installation folder
                            $rabbitDeployPath | Clip
                            Start-Process -FilePath $queueDeployPath -PassThru | Out-Null #Wait-Process #Add Switches
                        }
                        else
                        {
                            echo "User cancelled the form!"
                        }
                }
        }
        else
        {
            #Popup with input for path to QueueDeployment.exe
            $newQueuePath = CustomInputBox("QueueDeployment Installation Directory") ("Please enter the full installation path of the QueueDeployment Tool...") ("")
                if ( $newQueuePath -ne $null ) 
                {
                    $QueueDeployPath = $newQueuePath
                    #Run QueueDeployment.exe with switches for the RabbitMQ installation folder
                    $QueueDeployPath | Clip
                    Start-Process -FilePath $queueDeployPath -PassThru | Out-Null #Wait-Process #Add Switches
                            
                }
                else
                {
                    echo "User cancelled the form!"
                }
        }
}

#####################################################################                
#######END SECTION FOR INSTALLING THE QUEUE DEPLOYMENT UTILITY#######

# While QueueDeployment process is open, wait to process anything else
while ($true) {
    Start-Sleep -Seconds 1
    if (-not (Get-Process -Name QueueDeployment -ErrorAction SilentlyContinue)) {
        break
    }
}

#######START SECTION FOR MODIFYING THE WEB.CONFIG FILE#######
#############################################################

    #Read Configuration file into a variable
$xmlConfig = [xml](Get-Content $fullPath)
    #Check to ensure that the Web.Config file exists in the default directory
    $webConfigPath = $xmlConfig.Configuration.Server.SERVER_INSTALL_DIR + "\Manager\Web.config"
    $webConfigPathServer = $xmlConfig.Configuration.Server.SERVER_INSTALL_DIR + "\Manager\"
    $webConfigPathServer = $webConfigPathServer.Substring(0,$webConfigPathServer.Length-1)
        if (Test-Path $webConfigPath)
        {
            #Copy config file to Desktop
            Copy-Item -Path $webConfigPath -Destination "$env:userprofile\desktop\"

            #Open and modify config file from desktop
            $webConfig = "$env:userprofile\desktop\web.config"
            $webConfigDesktop = "$env:userprofile\desktop\"
            $doc = new-object System.Xml.XmlDocument
            $doc.Load($webConfig)
            $doc.get_DocumentElement().winshuttleServerConfiguration.serverQueue.queueHostName = $xmlConfig.Configuration.Server.QUEUEHOSTNAME
            $userCount = 0
            $userc = 0
            foreach ($allowedUser in $xmlConfig.Configuration.Server.AllowedIdentities.ALLOWEDUSER.Name)
            {
                if ($userCount -eq 0)
                {
                    $doc.get_DocumentElement().winshuttleServerConfiguration.allowedIdentities.allowedIdentity.name = $xmlConfig.Configuration.Server.AllowedIdentities.ALLOWEDUSER.ChildNodes.Item($userCount)."#text"
                    $userCount++
                }
                else
                {
                    $root = $doc.get_DocumentElement()
                    $userNode = $doc.createElement("allowedIdentity")
                    $root.winshuttleServerConfiguration.allowedIdentities.appendChild($userNode) | Out-Null
                    $attribute = $doc.createAttribute("name")
                    $attribute.set_Value($xmlConfig.Configuration.Server.AllowedIdentities.ALLOWEDUSER.ChildNodes.Item($userCount)."#text")
                    $userNode.SetAttributeNode($attribute) | Out-Null
                    $userCount++
                    
                }
            }
            $doc.Save($webConfig)
            
            #Cut config file from Desktop #Paste config file into proper folder
            if (Test-Path $webConfigPath)
            {

                robocopy $webConfigDesktop $webConfigPathServer web.config /MOV
            }
            else
            {
                echo "Problem Happened"
            }
            
        }
        else
        {
            $newConfigPath = CustomInputBox("Web Config Installation Directory") ("Please enter the full installation path of the Web.Config file...") ("")
                if ( $newQueuePath -ne $null ) 
                {
                    $webConfigPath = $newConfigPath
                            
                }
                else
                {
                    echo "User cancelled the form!"
                }
        }

###########################################################               
#######END SECTION FOR MODIFYING THE WEB.CONFIG FILE#######        
        
        
#######START SECTION FOR INSTALLING THE WORKER PORTION OF SERVER#######
#######################################################################

    #Read the TCP_PORT setting from the XML file
    $tcp = $xmlConfig.Configuration.Server.TCP_PORT
        if ($tcp -ne "")
        {
            $tcpArg = "TCP_PORT=" + $tcp + " "
            $arguments += $tcpArg
        }

    #Read the APPPOOL setting from the XML file
    $appPool = $xmlConfig.Configuration.Server.APPPOOL
        if ($appPool -ne "")
        {
            $appPoolArg = "APPPOOL=" + $appPool + " "
            $arguments += $appPoolArg
        }

    #Read the WS_USER setting from the XML file
    $wsuser = $xmlConfig.Configuration.Server.WS_USER
        if ($wsuser -ne "")
        {
            $wsuserArg = "WS_USER=" + $wsuser + " "
            $arguments += $wsuserArg
        }

    #Read the WS_PASS setting from the XML file
    $wspass = $xmlConfig.Configuration.Server.WS_PASS
        if ($wspass -ne "")
        {
            $wspassArg = "WS_PASS=" + $wspass + " "
            $arguments += $wspassArg
        }

    #Read the QUEUEMANAGER_CHECKED setting from the XML file
    $queueMgr = $xmlConfig.Configuration.Server.QUEUEMANAGER_CHECKED
        if ($queueMgr -ne "")
        {
            $queueMgrArg = "QUEUEMANAGER_CHECKED=" + $queueMgr + " "
            $arguments += $queueMgrArg
        }

    #Read the QUEUEPROCESSING_CHECKED setting from the XML file
    $queueProc = $xmlConfig.Configuration.Server.QUEUEPROCESSING_CHECKED
        if ($queueProc -ne "")
        {
            $queueProcArg = "QUEUEPROCESSING_CHECKED=" + $queueProc + " "
            $arguments += $queueProcArg
        }

        #Take the current path, from above, and add the MSI location to it
        $msiFile = $scriptPath + '.\WinshuttleSERVER_x64.msi'

        #Start the MSI with the parameters that have been passed on from the XML file
        Start-Process -FilePath $msiFile -argumentlist $arguments -passthru | Wait-Process #Don't continue until installation is complete
        
        #Clear out arguments variable once the process has completed
        $arguments = ""
    
    #Start the WinshuttleWorker Process and confirm that it's running

#####################################################################                
#######END SECTION FOR INSTALLING THE WORKER PORTION OF SERVER#######        



#Notes to myself:
    #How to handle if it's not all on one server?
    #How to handle if they don't install into the default directory