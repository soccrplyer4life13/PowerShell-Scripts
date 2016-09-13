Add-PSSnapin Microsoft.SharePoint.PowerShell

### Load the assemblies to create the GUI interfaces
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

### Prompt for the site URL
$url = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your Form Site URL", "URL", "http://" + $env:computername + "/forms")
# $url="http://sea-en-vstsup8/forms"

### Create the Form
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Delete SharePoint Lists" 
$objForm.StartPosition = "CenterScreen"

### Hook into the SharePoint site and return all of the Lists
$web = Get-SPWeb -Identity "$url"
$lists = $web.Lists

### Variables used for form sizing and spacing
$ylocation = 20

### Create a table for containing the objects
$listTable = New-Object System.Windows.Forms.TableLayoutPanel
$listTable.Location = New-Object System.Drawing.Size(10,10)
$listTable.CellBorderStyle = "Single"
#$listTable.RowCount = $lists.Count
$listTable.ColumnCount = 3
$listTable.ColumnStyles.Add((new-object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null
$listTable.ColumnStyles.Add((new-object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null
$listTable.ColumnStyles.Add((new-object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null

###Create the Header Row
$objCheckHead = New-Object System.Windows.Forms.CheckBox
$objCheckHead.AutoSize = "true"
$objCheckHead.Add_CheckStateChanged({
    if ($objCheckHead.Checked) {
        foreach ($control in $listTable.Controls) {
            $controlType = $control.GetType()
                if ($controlType.Name -eq "CheckBox") {
                    $control.Checked = $true
                }
        }
    }
    else{
        foreach ($control in $listTable.Controls) {
            $controlType = $control.GetType()
                if ($controlType.Name -eq "CheckBox") {
                    $control.Checked = $false
                }
        }
    }
})
$listTable.Controls.Add($objCheckHead,0, 0)

$objLabelHead = New-Object System.Windows.Forms.Label 
$objLabelHead.Size = New-Object System.Drawing.Size(10,20)
$objLabelHead.AutoSize = "true" 
$objLabelHead.Text = "List Name"
$objLabelHead.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
$listTable.Controls.Add($objLabelHead, 1, 0)

$objDescHead = New-Object System.Windows.Forms.Label 
$objDescHead.Size = New-Object System.Drawing.Size(10,20)
$objDescHead.AutoSize = "true" 
$objDescHead.Text = "List Description"
$objDescHead.Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
$listTable.Controls.Add($objDescHead, 2, 0)
        

### Cycle through each List item. If they're the correct Template, show them in the list on-screen
$i = 1

### Create a multi-dimensional Array

foreach ($list in $lists) {
 
    if($list.BaseTemplate -eq "32111"){

        ### Add a new Row for each list
        $listTable.RowStyles.Add((new-object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize))) | Out-Null

        $objCheck = New-Object System.Windows.Forms.CheckBox
        $objCheck.AutoSize = "true"
        $listTable.Controls.Add($objCheck,0, $i)

        $objLabel = New-Object System.Windows.Forms.Label 
        $objLabel.AutoSize = "true" 
        $objLabel.Text = $list.Title
        $listTable.Controls.Add($objLabel, 1, $i)
        
        $objDesc = New-Object System.Windows.Forms.Label 
        $objDesc.AutoSize = "true" 
        $objDesc.Text = $list.Description
        $listTable.Controls.Add($objDesc, 2, $i)

        $ylocation += 20
        $i++
       }
}

### Add the Table to the Form
$objForm.Controls.Add($listTable)

### Adjust the form size to accomodate all lists
$listTable.AutoSize = "true" 
$objForm.AutoSize = "true"
$buttonYLocation = $objForm.Height - 30
$buttonXLocation = $objForm.Width / 2
$OKButtonX = $buttonXLocation - 100
$CancelButtonX = $buttonXLocation

### Create an OK button
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size($OKButtonX,$buttonYLocation)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$hadError = $false
$OKButton.Add_Click({

    foreach ($control in $listTable.Controls) {
            $controlType = $control.GetType()
                if ($controlType.Name -eq "CheckBox" -and $control.Checked -eq $true) {
                    $rowPos = $listTable.GetPositionFromControl($control)
                    $controlName = $listTable.GetControlFromPosition(1,$rowPos.Row)
                    $listArray = @()
                    $listArray += $controlName.Text
                        foreach ($listItem in $listArray) {
                            if ($controlName.Text -ne "List Name"){
                                Try {
                                $toDelete = $web.Lists[$listItem]
                                $toDelete.AllowDeletion = $true
                                $toDelete.Update()
                                $toDelete.Delete()
                                }
                                Catch {
                                    [System.Windows.Forms.MessageBox]::Show($Error)
                                    $hadError = $true
                                }
                            }
                        }
                }
        }
    if ($hadError -eq $false) {
        [System.Windows.Forms.MessageBox]::Show("All Sites Have Been Deleted!")
        $objForm.Close()
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("There was an error, please ensure that all sites are in the proper state")
    }
})
$objForm.Controls.Add($OKButton)

### Create a Cancel button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size($CancelButtonX,$buttonYLocation)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)
$objForm.Topmost = $True

###Show the Form
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
