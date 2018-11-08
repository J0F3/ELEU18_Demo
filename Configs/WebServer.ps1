Configuration WebServer
{
    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.Where{$_.Role -eq 'WebServer'}.NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure          = "Present"
            Name            = "Web-Server"
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure          = "Present"
            Name            = "Web-Asp-Net45"
        }

        # Stop the default website
        xWebsite DefaultSite
        {
            Ensure          = "Present"
            Name            = "Default Web Site"
            State           = "Stopped"
            PhysicalPath    = "C:\inetpub\wwwroot"
            DependsOn       = "[WindowsFeature]IIS"
        }

# Copy the website content
Archive WebContent
{
    Ensure          = "Present"
    Path            = $Node.SourcePath
    Destination     = $Node.WebSiteRootPath
    DependsOn       = "[WindowsFeature]AspNet45"
}

# Create the new Website
        xWebsite fourthcoffee
{
    Ensure          = "Present"
    Name            = $Node.WebSiteName
    State           = "Started"
    PhysicalPath    = "$($Node.WebSiteRootPath)\fourthcoffee"
    DependsOn       = "[Archive]WebContent"
}

    }
}