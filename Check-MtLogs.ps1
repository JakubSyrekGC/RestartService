USING MODULE .\ServicesHelpers.psm1

$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 

$ServersList = $env:G2_Meta_Servers
Write-Output "Servers: $ServersList"

$Result = @()

$Result = [Functions]::CheckMetaLogs($ServersList)

Write-Host $Result

if($Result -ne $null)
{
#    if([Functions]::ExportHtmlFile( $Result , "D:\Scripts\PO\G2-Meta-App-Restart-Check\OutputG2MetaProc.html")) { Write-Host "Results exported to html"} 
}
else
{
    exit 1
}
#return ($Result | Format-Table -Wrap | Out-String )  

exit 0
