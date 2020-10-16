USING MODULE .\ServicesHelpers.psm1

#$erroractionpreference = "SilentlyContinue" 
$ServersList = $ENV:SERVERS_LIST
$Username    = $ENV:ADMIN
$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)
#EndRegion Consts
$Result = @()

foreach ($srv in $ServersList) 
{
    $metaserver = [MetaServerRestarter]::new($srv, $credentials);    
    $metaserver.GetLastBootTime()
    $Result += $metaserver     
}   

($Result | Format-Table -Wrap -Property ServerName,MetaServer,MetaAdminAPIService,MetaRatesCenter,MetaRefRateIndicator,TibRVD  | Out-String )  

if([Functions]::ExportHtmlFile( $Result , "C:\___\OutputG2MetaProc.html")) { Write-Host "Results exported to html" }

exit 0
