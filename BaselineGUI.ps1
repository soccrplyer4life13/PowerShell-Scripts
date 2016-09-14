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
        

        <!-- OTHER CONTROLS THAT ARE POSSIBLE
        --------------------------------------
        <Border x:Name="border"/>
        <Button x:Name="button"/>
        <Calendar x:Name="calendar"/>
        <Canvas x:Name="canvas"/>
        <CheckBox x:Name="checkBox"/>
        <ComboBox x:Name="combobox"/>
        <ContentControl x:Name="contentControl"/>
        <DataGrid x:Name="dataGrid"/>
        <DatePicker x:Name="datepicker"/>
        <DockPanel x:Name="dockpanel"/>
        <DocumentViewer x:Name="documentViewer"/>
        <Expander x:Name="expander"/>
        <Frame x:Name="frame"/>
        <Grid x:Name="grid"/>
        <Image x:Name="image"/>
        <InkCanvas x:Name="inkCanvas"/>
        <ItemsControl x:Name="itemsControl"/>
        <Label x:Name="label"/>
        <Listbox x:Name="listbox"/>
        <ListView x:Name="listview"/>
        <Menu x:Name="menu"/>
        <PasswordBox x:Name="passwordbox"/>
        <ProgressBar x:Name="progressbar"/>
        <RadioButton x:Name="radiobutton"/>
        <RichTextBox x:Name="richtextbox"/>
        <ScrollViewer x:Name="scrollviewer"/>
        <Separator x:Name="separator"/>
        <Slider x:Name="slider"/>
        <StackPanel x:Name="stackpanel"/>
        <TabControl x:Name="tabcontrol"/>
        <TextBlock x:Name="textblock"/>
        <TextBox x:Name="textbox"/>
        <ToolBar x:Name="toolbar"/>
        <TreeView x:Name="treeview"/>
        <WrapPanel x:Name="wrappanel"/>

        ---------------------------------------------------------------------------------------------------
        FOR THE FULL LIST - https://msdn.microsoft.com/en-us/library/system.windows.controls(v=vs.110).aspx
        -->
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
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "control_$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable control_*
}
 
#Get-FormVariables
#endregion

#===========================================================================
# Do your work here: append $control_ onto the name of your object. I.E. myTextBox becomes $control_myTextBox
#=========================================================================== 

$control_btnGo.Add_Click({
    $inputText = $control_txtFirstInput.Text
    $control_txtFirstOutput.Text = $inputText
})
$control_btnClose.Add_Click({$form.Close()})

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null