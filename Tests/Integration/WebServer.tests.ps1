####################################################################
# Integration tests for WebServer Config
#
# Integration tests:  Web server is configured as intended.
####################################################################

Import-Module PoshSpec

Describe 'WebServer' {    
    context "Installed and running" {
        Service W3SVC Status { Should Be Running }
        It "Should have Web-Server feature installed" {
            (Get-WindowsFeature -Name Web-Server).InstallState | Should be 'Installed'
        }

        It "Should have Web-Asp-Net45 feature installed" {
            (Get-WindowsFeature -Name Web-Asp-Net45).InstallState | Should be 'Installed'
        }
    }
    
    context 'Inbound DNS rules' {
        $InboundRules = @(Get-NetFirewallRule -DisplayGroup "World Wide Web Services (HTTP)" | where {$_.Direction -eq 'Inbound'})
        
        It "Should have 4 rules" {
            $InboundRules.count | Should be 1
        }

        It "All rules should be enabled" {
            $InboundRules | %{if(!($_.enabled -eq $true)){"Failed!"}} | Should be $null
        }

        It "All rules should not block traffic" {
            $InboundRules | %{if(!($_.Action -eq "Allow")){"Failed!"}} | Should be $null
        }

        It "Should be a rule for local TCP port 80" {
            ($InboundRules | Get-NetFirewallPortFilter | ?{$_.Protocol -eq "TCP"}).LocalPort | Should match 80
        }
    }

    context 'Website' {
        It "FourthCoffee Website should be started" {
            (Get-IISSite -Name FourthCoffee).State | Should be 'Started'
        }
    }

    context 'HTTP' {
        
        It "Should be listening on port 80" {
            (Test-NetConnection -ComputerName 127.0.0.1 -Port 80).TcpTestSucceeded | Should be $true 
        }

        It "Should respond with HTTP status code 200" {
            (Invoke-WebRequest -Uri http://127.0.0.1 -UseBasicParsing).StatusCode | Should be 200
        }
    }
}
