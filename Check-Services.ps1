USING MODULE .\ServicesHelpers.psm1

$Console = $Host.UI.RawUI 
$Buffer = $Console.BufferSize  
$Buffer.Width = '4096'
$Console.BufferSize = $Buffer 

$ServersList = $ENV:MT5_Start #SERVERS_LIST
$Username    = $ENV:ADMIN
$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)
$Result = @()

foreach ($srv in $ServersList) 
{
    $metaserver = [MetaServerRestarter]::new($srv, $credentials);    
    $metaserver.GetLastBootTime()
    $Result += $metaserver     
}   

if([Functions]::ExportHtmlFile( $Result , "D:\Scripts\PO\G2-Meta-App-Restart-Check\OutputG2MetaProc.html", "ServerName,MetaServer,MetaAdminAPIService,MetaRatesCenter,MetaRefRateIndicator,TibRVD")) { Write-Host "Results exported to html"} 

return ($Result | Format-Table -Wrap -Property ServerName,MetaServer,MetaAdminAPIService,MetaRatesCenter,MetaRefRateIndicator,TibRVD  | Out-String )  

exit 0




