$a = new-object -comobject wscript.shell 
$intAnswer = $a.popup("Do you want to archive your recordings?", 0,"Archive Recordings",4) 
if ($intAnswer -eq 6) { 
    
} else { 
    exit
}


#define variables
$process = "c:\Program Files\7-Zip\7z.exe"
$destinationFile = "D:\ArchivedRecordings\Recordings_$(get-date -f yyyy-MM-dd).zip"
$sourceFile = "D:\Recordings\*.wmv"
$sourceFileRemove = "D:\Recordings\*"

function New-Zip
{
	param([string]$zipfilename)
	set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
	(dir $zipfilename).IsReadOnly = $false
}

New-Zip $destinationFile

#define functions
function balloonPopup($message){
 [system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
 $balloon = New-Object System.Windows.Forms.NotifyIcon
 $path = Get-Process -id $pid | Select-Object -ExpandProperty Path
 $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
 $balloon.Icon = $icon
 $balloon.BalloonTipIcon = 'Info'
 $balloon.BalloonTipText = $message
 $balloon.BalloonTipTitle = 'Done'
 $balloon.Visible = $true
 $balloon.ShowBalloonTip(10000)
}

#script body
$p = Start-Process $process -ArgumentList "a $destinationFile $sourceFile" -Wait -PassThru
if (($p.HasExited -eq $true) -and ($p.ExitCode -eq 0)) {
 Remove-Item $sourceFileRemove -Recurse
 balloonPopup("7-Zip Ran Successfully")
}
else {
 balloonPopup("7-Zip closed with errors")
}