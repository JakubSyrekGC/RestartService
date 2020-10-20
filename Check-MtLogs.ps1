#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1
$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 
$newLine = [Environment]::NewLine
#Endregion Preconfigure

#Region Execute
$newLine#####################################################################################################################$newLine
$ServersList = $env:G2_Meta_Servers
Write-Output "Servers: $ServersList"
$newLine#####################################################################################################################$newLine
$Result = @()
$Result = [Functions]::CheckMetaLogs($ServersList)
if([Functions]::ExportHtmlFile( $Result , "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html", "ServerName,TradeCont".Split(","))) {Write-Output "HTML exported to $env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html }
#Endregion Execute

#Region DisplayResults
[Functions]::DisplayResults($Result,"ServerName,TradeCont".Split(",") )
$newLine#####################################################################################################################$newLine
#Endregion DisplayResults

exit 0
