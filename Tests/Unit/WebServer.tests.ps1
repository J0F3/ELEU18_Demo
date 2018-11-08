####################################################################
# Unit tests for WebServer
#
# Unit tests content of DSC configuration as well as the MOF output.
####################################################################

#region
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose $here
$parent = Split-Path -Parent $here
$GrandParent = Split-Path -Parent $parent
Write-Verbose $GrandParent
$configPath = Join-Path $GrandParent "Configs"
Write-Verbose $configPath
$sut = ($MyInvocation.MyCommand.ToString()) -replace ".Tests.","."
Write-Verbose $sut
. $(Join-Path -Path $configPath -ChildPath $sut)

#endregion

Describe "WebServer Configuration" {
    Context "Configuration Script"{
        
        It "Should be a DSC configuration script" {
            (Get-Command WebServer).CommandType | Should be "Configuration"
        }

        It "Should not be a DSC Meta-configuration" {
            (Get-Command WebServer).IsMetaConfiguration | Should Not be $true
        }

        It "Should use the xWebsite DSC resource" {
            (Get-Command WebServer).Definition | Should Match "xWebsite"
        }
    }

    Context "Node Configuration" {
        $OutputPath = "TestDrive:\"
        
        It "Should not be null" {
            "$configPath\DevEnv.psd1" | Should Exist
        }
        
        It "Should generate a single mof file." {
            WebServer -ConfigurationData "$configPath\DevEnv.psd1" -OutputPath $OutputPath 
            (Get-ChildItem -Path $OutputPath -File -Filter "*.mof" -Recurse ).count | Should be 1
        }
        
        It "Should generate a mof file with the name 'Web01'." {
            WebServer -ConfigurationData "$configPath\DevEnv.psd1" -OutputPath $OutputPath 
            Join-Path $OutputPath "Web01.mof" | Should Exist
        }

        It "Should be a valid DSC MOF document"{
            WebServer -ConfigurationData "$configPath\DevEnv.psd1" -OutputPath $OutputPath
            mofcomp -check "$OutputPath\Web01.mof" | Select-String "compiler returned error" | Should BeNullOrEmpty
        }

        It "Should generate a new version (2.0) mof document." {
            WebServer -ConfigurationData "$configPath\DevEnv.psd1" -OutputPath $OutputPath 
            Join-Path $OutputPath "Web01.mof" | Should Contain "Version=`"2.0.0`""
        }
        
        #Clean up TestDrive between each test
        AfterEach {
            Remove-Item TestDrive:\* -Recurse
        }
    }
}
