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
      
    static [string]GetLastBootUpTime (
        [string]$Server,
        [string]$Filter,              
        [System.Management.Automation.PSCredential]$Credentials
        
    )
    {    
        [string]$result = $null

        if ([string]::IsNullOrEmpty($Server) -or [string]::IsNullOrEmpty($Server) -or $Credentials -eq [System.Management.Automation.PSCredential]::Empty) {return $null}

        try
        {
            $result = gwmi win32_process -computer $Server -Credential $Credentials -filter $Filter -ErrorAction Stop | Select @{Name="Started";Expression={$_.ConvertToDateTime($_.CreationDate)}}| ft -hidetableheaders | out-string 
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


    static [bool]ExportHtmlFile(
        $Inputs,
        $HtmlOutputPath        
    )
    {   
        if($Inputs -eq $null -or $htmlOutputPath -eq $null)
        {
            return $false
        }
        else
        {
            $Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
            $inp = $Inputs.Clone()
            $HTML  = $inp | ConvertTo-Html -As Table -Head $Header -Property ServerName,MetaServer,MetaAdminAPIService,MetaRatesCenter,MetaRefRateIndicator,TibRVD
            $HTML | Out-File $htmlOutputPath    
            return $true
        }
    }
    static [object]DisplayResults(
        $Inputs   
    )
    {
        if($Inputs -eq $null)  
        {
            return $null
        }
        else
        {
            return ($Inputs | Format-Table -Wrap -Property ServerName,MetaServer,MetaAdminAPIService,MetaRatesCenter,MetaRefRateIndicator,TibRVD | Out-String )  
        }
    }
    static [object]CheckMetaLogs (
        [string]$ServersString
    )
    {
        $Result = @()

        if($ServersString -eq $null)  
        {
            return $null
        }
        else
        {
            $Servers = $ServersString.Split(",").Trim()            

            foreach ($server in $Servers)  {
                
                $logTC = $null
                $ss    = $null
                $snap  = $null
                $errorConnection     = "Connection problem"
                $errorStringNotFound = "Searched string not found in logs"
       		
		Write-Output $server
		
                if((Test-Connection $server) -eq $false )  {
                        $Result += New-Object PSObject -Property @{
	                               ServerName = $server
		                           TradeCont  = $errorConnection
                                   }
                continue
                }

                try {
                    $logTC = gc "\\$server\Logs\MetaTrader4Server\TradeController.log" | select-string 'successfully loaded' | Select-object  -Last 1
                    $ss = $logtc.linenumber  
                    $snap = gc "\\$server\Logs\MetaTrader4Server\TradeController.log"  | select-string  'initial status, dealable' | ?{$_.linenumber -gt $ss} | Select -first 1           
                }
                catch [System.Exception]
                {
                    Write-Output ($_.Exception.ErrorCode).Trim() 
                }

                If($logTC -eq $null)  {
                    
                    $Result += New-Object PSObject -Property @{	                            
                                ServerName = $server
		                        TradeCont  = $errorStringNotFound
                               }
                }
                Else {       
                    
                    $Result += New-Object PSObject -Property @{
	                            ServerName = $server
		                        TradeCont  = $snap
                               }
                }
            }        
        }
        return $Result
    }
}         

class MetaServerRestarter : Functions {
    [string]$ServerName
    [string]$MetaServer
    [string]$MetaAdminAPIService
    [string]$MetaRatesCenter
    [string]$MetaRefRateIndicator
    [string]$TibRVD
    [System.Management.Automation.PSCredential]$Credentials       

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
        $this.Credentials = $null
     }
    
    MetaServerRestarter(
    [string]$srv,
    [System.Management.Automation.PSCredential]$creds
    )
    {             
        $this.ServerName  = $srv
        $this.Credentials = $creds
    }
     
     GetLastBootTime () {
     $this.MetaAdminAPIService =   ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::MetaAdminAPIService),  $this.Credentials )).Trim()                                              
     $this.MetaRatesCenter =       ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::MetaRatesCenter),      $this.Credentials )).Trim()
     $this.MetaRefRateIndicator =  ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::MetaRefRateIndicator), $this.Credentials )).Trim()
     $this.MetaServer =            ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::mtsrv),                $this.Credentials )).Trim()
     $this.TibRVD =                ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::MetaAdminAPIService),  $this.Credentials )).Trim() 
     }
}




  

