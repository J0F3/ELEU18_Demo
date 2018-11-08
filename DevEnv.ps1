param(
    [parameter(Mandatory=$true)]
    [string]
    $OutputPath
)

Import-Module $PSScriptRoot\Assets\DscPipelineTools\DscPipelineTools.psd1 -Force

# Define Unit Test Environment
$DevEnvironment = @{
    Name                        = 'DevEnv';
    Roles = @(
        @{  
            Role                = 'DNSServer';
            VMName              = 'DNS01';
            Zone                = 'devops.lab';
            ARecords            = @{'VSTSAgent'='172.16.6.160';'PullServer'='172.16.6.161';'DNS01'='172.16.6.162';'Web01'='172.16.6.163';'MGTServer'='172.16.6.163'};
            CNameRecords        = @{'DNS' = 'DNS01.devops.lab';'DSCPull' = 'PullServer.devops.lab'};
        },
        @{  
            Role                = 'WebServer';
            VMName              = 'Web01';
            WebSiteName         = 'FourthCoffee';
            WebSiteRootPath     = 'C:\inetpub\wwwroot';
            SourcePath          = 'C:\FourthCoffeeWebsite.zip';
        }
    )
}

Return New-DscConfigurationDataDocument -RawEnvData $DevEnvironment -OutputPath $OutputPath