#ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Class="PowerShellTest1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:PowerShellTest1"
        mc:Ignorable="d"
        Title="PowerShell GUI Made Easy" Height="350" Width="525">
    <Grid>
        <Label x:Name="lblInputOne" Content="First Input:" HorizontalAlignment="Left" Margin="41,45,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="txtFirstInput" HorizontalAlignment="Left" Height="23" Margin="112,48,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Button x:Name="btnGo" Content="Go" HorizontalAlignment="Left" Margin="251,258,0,0" VerticalAlignment="Top" Width="75"/>
        <TextBox x:Name="txtFirstOutput" HorizontalAlignment="Left" Height="23" Margin="112,186,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Label x:Name="lblOutputOne" Content="First Output:" HorizontalAlignment="Left" Margin="41,186,0,0" VerticalAlignment="Top"/>
        <Button x:Name="btnClose" Content="Close" HorizontalAlignment="Left" Margin="331,258,0,0" VerticalAlignment="Top" Width="75"/>
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
    $inputText = $WPFtxtFirstInput.Text
    $WPFtxtFirstOutput.Text = $inputText
})
$WPFbtnClose.Add_Click({$form.Close()})

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null