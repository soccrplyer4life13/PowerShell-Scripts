<#   
Description
-----------
This command query localhost and display a formatted list of all scheduled tasks on the local computer

.EXAMPLE
	.\Get-ScheduledTask.ps1 -ComputerName server01 | Select-Object -Property Name,Trigger

Description
-----------
This command query server01 for scheduled tasks and display only the TaskName and the assigned trigger(s)

.EXAMPLE
	.\Get-ScheduledTask.ps1 | Where-Object {$_.Name -eq 'TaskName') | Select-Object -ExpandProperty Trigger

#>
function Get-ScheduledTask {
    param(
	    [string]$ComputerName = $env:COMPUTERNAME,
        [switch]$RootFolder
    )

    #region Functions
    function Get-AllTaskSubFolders {
        [cmdletbinding()]
        param (
            # Set to use $Schedule as default parameter so it automatically list all files
            # For current schedule object if it exists.
            $FolderRef = $Schedule.getfolder("\")
        )
        if ($FolderRef.Path -eq '\') {
            $FolderRef
        }
        if (-not $RootFolder) {
            $ArrFolders = @()
            if(($Folders = $folderRef.getfolders(1))) {
                $Folders | ForEach-Object {
                    $ArrFolders += $_
                    if($_.getfolders(1)) {
                        Get-AllTaskSubFolders -FolderRef $_
                    }
                }
            }
            $ArrFolders
        }
    }
    #endregion Functions


    try {
	    $Schedule = New-Object -ComObject 'Schedule.Service'
    } catch {
	    Write-Warning "Schedule.Service COM Object not found, this script requires this object"
	    return
    }

    $Schedule.connect($ComputerName) 
    $AllFolders = Get-AllTaskSubFolders

    foreach ($Folder in $AllFolders) {
        if (($Tasks = $Folder.GetTasks(1))) {
            $Tasks | Foreach-Object {
	            New-Object -TypeName PSCustomObject -Property @{
	                'Name' = $_.name
                    'Path' = $_.path
                    'State' = switch ($_.State) {
                        0 {'Unknown'}
                        1 {'Disabled'}
                        2 {'Queued'}
                        3 {'Ready'}
                        4 {'Running'}
                        Default {'Unknown'}
                    }
                    'Enabled' = $_.enabled
                    'LastRunTime' = $_.lastruntime
                    'LastTaskResult' = $_.lasttaskresult
                    'NumberOfMissedRuns' = $_.numberofmissedruns
                    'NextRunTime' = $_.nextruntime
                    'Author' =  ([xml]$_.xml).Task.RegistrationInfo.Author
                    'UserId' = ([xml]$_.xml).Task.Principals.Principal.UserID
                    'Description' = ([xml]$_.xml).Task.RegistrationInfo.Description
                    'ComputerName' = $Schedule.TargetServer
                }
            }
        }
    }
}

#==============================================================================================
#==============================================================================================
#==============================================================================================
#==============================================================================================
#==============================================================================================

#ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Class="PowerShellTest1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PowerShellTest1"
        WindowStartupLocation="CenterScreen"
        mc:Ignorable="d"
        Title="Run Remote SVService Task" Height="200" Width="385">
    <Grid>
        <Label x:Name="lblSrvName" Content="Server Name/IP:" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="txtSrvName" HorizontalAlignment="Left" Height="23" Margin="105,12,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" Text=""/>
        <Button x:Name="btnGo" Content="Go" HorizontalAlignment="Left" Margin="230,12,0,0" VerticalAlignment="Top" Width="75"/>
        
        <Label x:Name="lblChooseTask" Content="Choose Task:" HorizontalAlignment="Left" Margin="10,40,0,0" VerticalAlignment="Top"/>
        <ComboBox x:Name="cboChooseTask" HorizontalAlignment="Left" VerticalAlignment="Top" Width="200" Height="23" Margin="105,42,0,0"/>
        <Label x:Name="lblTaskStatus" Content="" HorizontalAlignment="Left" Margin="310,40,0,0" VerticalAlignment="Top"/>

        <Label x:Name="lblUserName" Content="Username:" HorizontalAlignment="Left" Margin="10,70,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="txtUserName" HorizontalAlignment="Left" Height="23" Margin="105,72,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="200" Text="domain\username"/>

        <Label x:Name="lblPassword" Content="Password:" HorizontalAlignment="Left" Margin="10,100,0,0" VerticalAlignment="Top"/>
        <PasswordBox x:Name="txtMaskedPass" Margin="40,65,0,0" Width="200" Height="23" />
        
        <Button x:Name="btnRunTask" Content="Run Task" HorizontalAlignment="Left" Margin="105,130,0,0" VerticalAlignment="Top" Width="70"/>
        <Button x:Name="btnRefresh" Content="Refresh" HorizontalAlignment="Left" Margin="180,130,0,0" VerticalAlignment="Top" Width="50"/>
        <Button x:Name="btnClose" Content="Close" HorizontalAlignment="Left" Margin="235,130,0,0" VerticalAlignment="Top" Width="70"/>
    </Grid>
</Window>
"@       
#region Interpret the UI and import it into PowerShell 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
#Get-FormVariables
#endregion

#===========================================================================
# Do your work here: append $WPF onto the name of your object. I.E. myTextBox becomes $WPFmyTextBox
#=========================================================================== 

$WPFbtnGo.Add_Click({
    $serverNameIP = $WPFtxtSrvName.Text
    
    $names = Get-ScheduledTask -ComputerName $serverNameIP -RootFolder | Select-Object -Property Name
    foreach ($name in $names){
        $WPFcboChooseTask.Items.Add($name.Name)
    }
    $WPFcboChooseTask.SelectedIndex = 0
})
$WPFcboChooseTask.Add_SelectionChanged({
    $serverNameIP = $WPFtxtSrvName.Text
    $status = Get-ScheduledTask -ComputerName $serverNameIP -RootFolder | Where-Object {$_.Name -eq $WPFcboChooseTask.SelectedValue}    
    $WPFlblTaskStatus.Content = $status.State
    if ($WPFlblTaskStatus.Content -eq "Ready"){
        $WPFlblTaskStatus.Foreground = "green"
    }elseif ($WPFlblTaskStatus.Content -eq "Disabled"){
        $WPFlblTaskStatus.Foreground = "red"
    }elseif ($WPFlblTaskStatus.Content -eq "Running"){
        $WPFlblTaskStatus.Foreground = "blue"
    }else {
        $WPFlblTaskStatus.Foreground = "black"
    }
})
$WPFbtnRunTask.Add_Click({
    $serverNameIP = $WPFtxtSrvName.Text
    $WPFtxtMaskedPass.Text
    schtasks /run /s $serverNameIP /tn $WPFcboChooseTask.SelectedValue /u $WPFtxtUserName.Text /p $WPFtxtMaskedPass.Password
    $status = Get-ScheduledTask -ComputerName $serverNameIP -RootFolder | Where-Object {$_.Name -eq $WPFcboChooseTask.SelectedValue}    
    $WPFlblTaskStatus.Content = $status.State
    if ($WPFlblTaskStatus.Content -eq "Ready"){
        $WPFlblTaskStatus.Foreground = "green"
    }elseif ($WPFlblTaskStatus.Content -eq "Disabled"){
        $WPFlblTaskStatus.Foreground = "red"
    }elseif ($WPFlblTaskStatus.Content -eq "Running"){
        $WPFlblTaskStatus.Foreground = "blue"
    }else {
        $WPFlblTaskStatus.Foreground = "black"
    }
})
$WPFbtnRefresh.Add_Click({
    $serverNameIP = $WPFtxtSrvName.Text
    $status = Get-ScheduledTask -ComputerName $serverNameIP -RootFolder | Where-Object {$_.Name -eq $WPFcboChooseTask.SelectedValue}    
    $WPFlblTaskStatus.Content = $status.State
    if ($WPFlblTaskStatus.Content -eq "Ready"){
        $WPFlblTaskStatus.Foreground = "green"
    }elseif ($WPFlblTaskStatus.Content -eq "Disabled"){
        $WPFlblTaskStatus.Foreground = "red"
    }elseif ($WPFlblTaskStatus.Content -eq "Running"){
        $WPFlblTaskStatus.Foreground = "blue"
    }else {
        $WPFlblTaskStatus.Foreground = "black"
    }
})
$WPFbtnClose.Add_Click({$form.Close()})

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null