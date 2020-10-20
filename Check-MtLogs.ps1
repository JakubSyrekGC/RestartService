#Region Preconfigure
USING MODULE .\ServicesHelpers.psm1
$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 
$newLine = [Environment]::NewLine
#Region Preconfigure end

#Region Execute
$newLine#####################################################################################################################$newLine
$ServersList = $env:G2_Meta_Servers
Write-Output "Servers: $ServersList"
$newLine#####################################################################################################################$newLine
$Result = @()
$Result = [Functions]::CheckMetaLogs($ServersList)
[Functions]::ExportHtmlFile( $Result , "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html")
#Region execute end

#Region display results
[Functions]::DisplayResults($Result,"ServerName,TradeCont".Split(",") )
$newLine#####################################################################################################################$newLine
#Region display results end

exit 0
