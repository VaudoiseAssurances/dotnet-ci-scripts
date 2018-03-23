param (
	[Parameter(Mandatory = $true)]
	[string]$csprojPath,
	[Parameter(Mandatory = $true)]
	[string]$scriptsPath,
	[Parameter(Mandatory = $true)]
	[string]$packageName,
	[Parameter(Mandatory = $true)]
	[string]$branchName
)

# Find setted version
$version = & "$scriptsPath\GetVersionDotnetCore.ps1" $csprojPath

if (!$version)
{
    Write-Host "failed to read assembly version in $csprojPath"
    $host.SetShouldExit(1)
}

# Decide if the version should be changed
$updatedVersion = & "$scriptsPath\DefineNextVersion.ps1" $version $packageName $branchName 'DummyParameterBecauseImSureThisIsUseless'

# get the version suffix (ex: beta01) if any
$separatorPosition = $updatedVersion.IndexOf("-") + 1 
$suffix = $updatedVersion.Substring($separatorPosition)

# Only the following lines are appveyor-specific.
Set-AppveyorBuildVariable "suffix" $suffix
Set-AppveyorBuildVariable "version" $updatedVersion