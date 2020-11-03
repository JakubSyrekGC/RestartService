class Filter
{
    static [string]$MetaAdminAPIService  = "Name='MetaAdminAPIService.exe'"   
    static [string]$MetaRatesCenter      = "Name='MetaRatesCenter.exe'"          
    static [string]$MetaRefRateIndicator = "Name='MetaRefRateIndicator.exe'"
    static [string]$mtsrv                = "Name='mtsrv.exe'"               
    static [string]$rvntsctl             = "Name='rvntsctl.exe'"  
    
    static [string]$TibRVD1              = "Name='rvd.exe'"           
    static [string]$HS1                  = "Name='mt5history64.exe'"  
    static [string]$TS1                  = "Name='mt5trade64.exe'"    
    static [string]$PF1                  = "Name='MT5PriceFeeder.exe'"
    static [string]$MAPI1                = "Name='MT5ManagerAPI.exe'"   
    
    static [string]$RatesCheckerServiceGB      = 'RatesCheckerServiceGB'    
    static [string]$RatesCheckerServiceCALive  = 'RatesCheckerServiceCALive'
    static [string]$RatesCheckerServiceJPDemo  = 'RatesCheckerServiceJPDemo'
}
class Properties
{
    static $CheckMt5ServicesProps =  @("ServerName","TibRVD1","TS1","PF1","MAPI1")     
    static $CheckMetaProps        =  @("ServerName","MetaServer","MetaAdminAPIService","MetaRatesCenter","MetaRefRateIndicator","TibRVD")     
    static $CheckRCRProps         =  @("ServerName","RatesCheckerGB","RatesCheckerCALive","RatesCheckerJPDemo") 
}
class Functions
{
      
    static [string]GetLastBootUpTime (
        [string]$Server,
        [string]$Filter,              
        [System.Management.Automation.PSCredential]$Credentials
        
    )
    {    
        [string]$result = ""

        if ([string]::IsNullOrEmpty($Server) -or $Credentials -eq [System.Management.Automation.PSCredential]::Empty) 
        { return "Wrong credentials" }
                
        $result = gwmi win32_process -computer $Server -Credential $Credentials -filter $Filter -ErrorAction Stop | Select @{Name="Started";Expression={$_.ConvertToDateTime($_.CreationDate)}}| ft -hidetableheaders | out-string 
        
        return $result
    }


    static [bool]ExportHtmlFile(
        $Inputs,
        $HtmlOutputPath,
	$Properties
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
            $HTML  = $inp | ConvertTo-Html -As Table -Head $Header -Property $Properties
            $HTML | Out-File $htmlOutputPath    
            return $true
        }
    }
    static [object]DisplayResults(
        $Inputs,
	$Properties
    )
    {
        if($Inputs -eq $null)  
        {
            return $null
        }
        else
        {
            return ($Inputs | Format-Table -Wrap -Property $Properties | Out-String )  
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
                $errorConnection     = "error: Connection problem"
                $errorStringNotFound = "error: Searched string not found in logs"
       		
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
                    Write-Output "Ran into an issue: $($PSItem.ToString())"
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

class MetaServerChecker : Functions {
    [string]$ServerName
    [string]$TibRVD1
    [string]$HS1    
    [string]$TS1    
    [string]$PF1    
    [string]$MAPI1  
    [System.Management.Automation.PSCredential]$Credentials       

    MetaServerChecker(
    [string]$sn,
    [string]$tb,
    [string]$hs,
    [string]$ts,
    [string]$pf,
    [string]$mp
    
    ){
        $this.ServerName = $sn
        $this.TibRVD1 = $tb
        $this.HS1     = $hs
        $this.TS1     = $ts
        $this.PF1     = $pf
        $this.MAPI1   = $mp        
        $this.Credentials = $null
     }
    
    MetaServerChecker(
    [string]$srv,
    [System.Management.Automation.PSCredential]$creds
    )
    {             
        $this.ServerName  = $srv
        $this.Credentials = $creds
    }
     
     GetLastBootTime () {
     $this.TibRVD1             = ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::TibRVD1)  , $this.Credentials )).Trim()                                              
     $this.HS1                 = ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::HS1)      , $this.Credentials )).Trim()
     $this.TS1                 = ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::TS1)      , $this.Credentials )).Trim()
     $this.PF1                 = ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::PF1)      , $this.Credentials )).Trim()
     $this.MAPI1               = ([Functions]::GetLastBootUpTime($this.ServerName, ([Filter]::MAPI1)    , $this.Credentials )).Trim() 
    }
}
class RCRChecker : Functions {
    [string]$ServerName        
    [string]$RatesCheckerGB    
    [string]$RatesCheckerCALive
    [string]$RatesCheckerJPDemo        
    [System.Management.Automation.PSCredential]$Credentials       

    RCRChecker(
    [string]$sn,
    [string]$rcGB,
    [string]$rcCA,
    [string]$rcJPD,
    [System.Management.Automation.PSCredential]$c  
    
    ){
        $this.ServerName                 = $sn
        $this.RatesCheckerGB             = $rcgb
        $this.RatesCheckerCALive         = $rcCA
        $this.RatesCheckerJPDemo         = $rcJPD
        $this.Credentials                = $c
     }
    
    RCRChecker(
    [string]$srv,
    [System.Management.Automation.PSCredential]$creds
    )
    {             
        $this.ServerName  = $srv
        $this.Credentials = $creds        
    }
     
     GetRcrStatus () {
     
        $scriptBlock = {param($srvr, $name) Get-Service -computer $srvr -Name $name -ErrorAction SilentlyContinue | select Status| ft -hidetableheaders | out-string  };


        $GetRatesCheckerGB = Start-Job -ScriptBlock $scriptBlock -ArgumentList @($this.ServerName, [Filter]::RatesCheckerServiceGB) -Credential $this.Credentials;
        Wait-Job $GetRatesCheckerGB;
        $Result = Receive-Job -Job $GetRatesCheckerGB;
        $this.RatesCheckerGB = $Result.ToString().Trim();
               
        
        $GetRatesCheckerCALive = Start-Job -ScriptBlock $scriptBlock -ArgumentList @($this.ServerName,[Filter]::RatesCheckerServiceCALive ) -Credential $this.Credentials;
        Wait-Job $GetRatesCheckerCALive;
        $Result = Receive-Job -Job $GetRatesCheckerCALive;
        $this.RatesCheckerCALive = $Result.ToString().Trim();

        
        $GetRatesCheckerJPDemo = Start-Job -ScriptBlock $scriptBlock -ArgumentList @($this.ServerName,[Filter]::RatesCheckerServiceJPDemo ) -Credential $this.Credentials;
        Wait-Job $GetRatesCheckerJPDemo;
        $Result = Receive-Job -Job $GetRatesCheckerJPDemo;
        $this.RatesCheckerJPDemo = $Result.ToString().Trim();

        if( [string]::IsNullOrEmpty($this.RatesCheckerGB) )     { $this.RatesCheckerGB         = "Service not available"};
        if( [string]::IsNullOrEmpty($this.RatesCheckerCALive) ) { $this.RatesCheckerCALive     = "Service not available"};
        if( [string]::IsNullOrEmpty($this.RatesCheckerJPDemo) ) { $this.RatesCheckerJPDemo     = "Service not available"};

    }
}

  

