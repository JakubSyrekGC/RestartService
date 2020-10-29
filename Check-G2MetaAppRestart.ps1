#Region Preconfigure
USING MODULE C:\dev\ServicesHelpers.psm1
#.\ServicesHelpers.psm1

#Region Consts
#$ServersList = $ENV:MT5_Start
$ServersList = @("MT4104Demo")
#$Username    = $ENV:ADMIN
#$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
#$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)


$HTMLpath               = "$env:OutputsForMetaStack\G2-Meta-App-Restart-Check\OutputG2MetaProc.html"
#Endregion Preconfigure


#Region Execute
$Result = @()

foreach ($srv in $ServersList) 
{
    $metaserver = [MetaServerRestarter]::new($srv, $credentials);    
    $metaserver.GetLastBootTime()
    $Result += $metaserver     
}
#Endregion Execute


#Region ExportHTML
if($Result -ne $null -and $Result[0] -ne $null) {  
  
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, ( [Properties]::CheckMetaProps ))) 
    {Write-Output "HTML exported to $HostName / $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML
   

#Region DisplayResults

return ($Result | Format-Table -Wrap -Property ( [Properties]::CheckMetaProps ) | Out-String )  

#Endregion DisplayResults


#Region ReturnResultCodeFromScript
if($Result -ne $null -and $Result[0].TradeCont.Contains("error") -ne $true) {
    Write-Output "Logs successfully verified $bar"
    exit 0
}
else {
    Write-Output "Error! Logs not verified. Please check! $bar"
    exit 1
}
#Endregion ReturnResultCodeFromScript


($Result | Format-Table -Wrap -Property ( [Properties]::CheckMetaProps )  | Out-String )  

#if([Functions]::ExportHtmlFile( $Result , "C:\___\OutputG2MetaProc.html")) { Write-Host "Results exported to html" }

#exit 0