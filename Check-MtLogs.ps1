#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1
$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 
$newLine = [Environment]::NewLine
$Properties = ("ServerName,TradeCont").Split(",")
$HTMLpath = "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html"
$HostName = [System.Net.Dns]::GetHostName()
#Endregion Preconfigure

#Region Execute
Write-Output $newLine#####################################################################################################################$newLine
$ServersList = $env:G2_Meta_Servers
Write-Output "Servers: $ServersList" 
Write-Output $newLine#####################################################################################################################$newLine
$Result = @()
$Result = [Functions]::CheckMetaLogs($ServersList)
if([Functions]::ExportHtmlFile( $Result, $HTMLpath, $Properties)) 
  {Write-Output "HTML exported to $HostName / $HTMLpath"}
else
  {Write-Output "Error during HTML export" }
#Endregion Execute

#Region DisplayResults
[Functions]::DisplayResults($Result, $Properties)
Write-Output $newLine#####################################################################################################################$newLine
#Endregion DisplayResults

if($Result -ne $null -and $Result[0].TradeCont.Contains("error") -ne $true) {
    Write-Output "Logs successfully verified"
    exit 0
}
else {
    Write-Output "Error! Logs not verified. Please check!"
    exit 1
}
