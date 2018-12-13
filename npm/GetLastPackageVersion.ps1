<#
.SYNOPSIS
This script get the last version of a given package on the npm repository

.PARAMETER
packageName : is the name of the package as referenced on npm
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$packageName
)

$packageInfo = (npm info $packageName -json) | ConvertFrom-Json
$lastVersion = $packageInfo.versions[-1]

return $lastVersion