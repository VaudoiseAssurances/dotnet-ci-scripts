param (
	[Parameter(Mandatory = $true)]
	[string]$csprojPath,
	[Parameter(Mandatory = $true)]
	[string]$packageName,
	[Parameter(Mandatory = $true)]
	[string]$branchName,
)

# Find setted version
$version = & '.\ic-tools\.NET Versioning\GetVersionDotnetCore.ps1' $csprojPath
# Decide if the version should be changed
$updatedVersion = & '.\ic-tools\.NET Versioning\DefineNextVersion.ps1' $version $packageName $branchName 'DummyParameterBecauseImSureThisIsUseless'

# get the version suffix (ex: beta01) if any
$separatorPosition = $updatedVersion.IndexOf("-") + 1 
$suffix = $updatedVersion.Substring($separatorPosition)

# Only the following lines are appveyor-specific.
Set-AppveyorBuildVariable "suffix" $suffix
Set-AppveyorBuildVariable "version" $updatedVersion