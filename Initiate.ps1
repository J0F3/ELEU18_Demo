param(
    [parameter()]
    [ValidateSet('Build','Deploy')]
    [string]
    $fileName
)

Import-Module psake

Invoke-PSake $PSScriptRoot\$fileName.ps1

exit (!$psake.build_success)