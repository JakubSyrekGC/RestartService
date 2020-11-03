#Region Preconfigure
USING MODULE C:\dev\ServicesHelpers.psm1
#.\ServicesHelpers.psm1

#$ServersList = $ENV:MT5_Start
$ServersList =                       @("MT4104Demo")
#$Username    = $ENV:ADMIN
#$Password              = ConvertTo-SecureString $ENV:PASS -AsPlainText -Force 
#$Credentials           = New-Object System.Management.Automation.PSCredential ($Username, $Password)


$HTMLpath               = "C:\dev\OutputRCRStatus.html"
#"MT_TB_Conn\OutputTBConn.html"


#Endregion Preconfigure


#Region Execute
$Result = @() ;

foreach ($srv in $ServersList) 
{
    $ConnChecker = [ConnChecker]::new($srv, $credentials)    
    $ConnChecker.GetConnectivityStatus()                 
    $Result += $ConnChecker                                      
}

#Endregion Execute


#Region ExportHTML
if ($Result -ne $null -and $Result[0] -ne $null) {  
  
  if([Functions]::ExportHtmlFile( $Result, $HTMLpath, ( [Properties]::CheckConnProps ))) 
    {Write-Output "HTML exported to $HTMLpath"}
  else
    {Write-Output "Error during HTML export" }
}
#EndRegion ExportHTML


#Region DisplayResults

return ($Result | Format-Table -Wrap -Property ( [Properties]::CheckConnProps ) | Out-String )  

#Endregion DisplayResults 