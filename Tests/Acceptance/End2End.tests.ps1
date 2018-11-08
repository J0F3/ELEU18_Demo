####################################################################
# Acceptance tests for DNS server Configuration
#
# Acceptance tests:  DNS server is configured as intended.
####################################################################

Import-Module PoshSpec
Clear-DnsClientCache

Describe 'Web Server E2E' {
    Context 'DNS addressess' {
        It "Should resolve DNS01 to 172.16.6.162" {
            (Resolve-DnsName -Name 'dns01.devops.lab' -DnsOnly -NoHostsFile).IPAddress | Should be '172.16.6.162'
        }

        It "Should resolve Web01 to 172.16.6.163" {
            (Resolve-DnsName -Name 'web01.devops.lab' -DnsOnly -NoHostsFile).IPAddress | Should be '172.16.6.163'
        }

        It "Should resolve DNS to DNS01" {
            (Resolve-DnsName -Name 'dns.devops.lab' -Type CNAME -DnsOnly -NoHostsFile).NameHost | Should match 'DNS01'
        }

        It "Should resolve DSCPull to PullServer" {
            (Resolve-DnsName -Name 'dscpull.devops.lab' -Type CNAME -DnsOnly -NoHostsFile).NameHost | Should match 'PullServer'
        }
    }

    Context 'Web server ports' {

        $PortTest = Test-NetConnection -ComputerName web01.devops.lab -Port 80

        It "Should successfully Test TCP port 80" {
            $PortTest.TcpTestSucceeded | Should be $true
        }

        It "Should not be able to ping port 80" {
            $PortTest.PingSucceeded | Should be $false
        }
    }

    Context 'Website content' {
        $WebRequest = Invoke-WebRequest -Uri http://web01.devops.lab -UseBasicParsing

        It "Should have a status code of 200" {
            $WebRequest.StatusCode | Should be 200
        }

        It "Should have appropriate headers" {
            $WebRequest.Headers.Server | Should Match 'Microsoft-IIS/10.0'
        }

        It "Should have expected raw content length" {
            $WebRequest.RawContentLength | Should be 4812
        }

        It "Should have expected content" {
            $WebRequest.Content | Should Match 'Welcome to Fourth Coffee!'
        }
    }

}
