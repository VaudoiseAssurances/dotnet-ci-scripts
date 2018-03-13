<#
.SYNOPSIS
This script return the version setted in the .netCore csproj. It use the <AssemblyVersion> element
.DESCRIPTION
Consider a given project.
    - it will take the parameter related to the path of the csproj
    - it will take in this csproj the AssemblyVersion number
    - it will returns it
.PARAMETER
csprojPath : The actual version we want to suffix or not
.EXAMPLE
.\.NetCoreGetVersion.ps1 "./my-path/to-my.csproj"
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$csprojPath
)

[xml]$csprojFile = Get-Content -Path $csprojPath

return $csprojFile.Project.PropertyGroup.AssemblyVersion
