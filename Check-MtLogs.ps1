USING MODULE .\ServicesHelpers.psm1

$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 
$newLine = [Environment]::NewLine
$line = "$newLine#####################################################################################################################$newLine"

$line
$ServersList = $env:G2_Meta_Servers
Write-Output "Servers: $ServersList"
$line

$Result = @()
$Result = [Functions]::CheckMetaLogs($ServersList)

if($Result -ne $null)
{
     ($Result | Format-Table -Wrap | Out-String )
     $line
#    if([Functions]::ExportHtmlFile( $Result , "D:\Scripts\PO\G2-Meta-App-Restart-Check\OutputG2MetaProc.html")) { Write-Host "Results exported to html"} 
}
else
{
    exit 1
}
#return ($Result | Format-Table -Wrap | Out-String )  

exit 0
