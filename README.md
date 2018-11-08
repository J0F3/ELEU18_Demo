# Infrastructure as Code (IaC) example

![Overview](/Assets/Overview.png)

What we have here:
 - PowerShell DSC configuration for a DNS and a Webserver saved in Git repository
 - Build definition with Unit Tests to validate and build (generate MOF files) the DSC configuration 
 - Release definition to deploy builded DSC configuration (MOF Files) to the servers in the environments
 - Integration and acceptance test in to test the functionality of the environment after a deployment. 


