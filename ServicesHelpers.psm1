clasfs MetaServerRestarter {
    [string]$ServerName
    [string]$MetaServer
    [string]$MetaAdminAPIService
    [string]$MetaRatesCenter
    [string]$MetaRefRateIndicator
    [string]$TibRVD
       

    MetaServerRestarter(
    [string]$sn,
    [string]$ms,
    [string]$maas,
    [string]$mrc,
    [string]$mrri,
    [string]$t
    
    ){
        $this.ServerName = $sn
        $this.MetaServer = $ms
        $this.MetaAdminAPIService = $maas
        $this.MetaRatesCenter = $mrc
        $this.MetaRefRateIndicator = $mrri
        $this.TibRVD = $t        
     }
}

class Filter
{
    static [string]$MetaAdminAPIService  = "Name='MetaAdminAPIService.exe'"   
    static [string]$MetaRatesCenter      = "Name='MetaRatesCenter.exe'"          
    static [string]$MetaRefRateIndicator = "Name='MetaRefRateIndicator.exe'"
    static [string]$mtsrv                = "Name='mtsrv.exe'"               
    static [string]$rvntsctl             = "Name='rvntsctl.exe'"             
  
}

class Functions
{
      
    [string]GetLastBootUpTime (
        [string]$Server,
        [System.Management.Automation.PSCredential]$Credentials,
        [string]$Filter              
    )
    {    
        [string]$result = $null

        if ([string]::IsNullOrEmpty($Server) -or [string]::IsNullOrEmpty($Server) -or $Credentials -eq [System.Management.Automation.PSCredential]::Empty) {return $null}

        try
        {
            $result = (gwmi win32_process -computer $Server -Credential $Credentials -filter $Filter -ErrorAction Stop | Select @{Name="Started";Expression={$_.ConvertToDateTime($_.CreationDate)}}| ft -hidetableheaders | out-string ).Trim()
        }
        catch [System.Runtime.InteropServices.COMException]
        {
            if($_.Exception.ErrorCode -eq 0x800706BA)
            {       
                $result = "The RPC server is unavailable"           
            }        
        
        }
        catch [System.UnauthorizedAccessException]
        {
            $result = ("Access is denied").Trim()         
        }
        catch [System.Exception]
        {
            $result = ($_.Exception.ErrorCode).Trim()
        }
        return $result
    }
}         
  

