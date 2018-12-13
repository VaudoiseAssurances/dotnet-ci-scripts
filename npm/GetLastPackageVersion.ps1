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

$json = (npm info $packageName -json) | ConvertFrom-Json
$lastVersion = $json.versions[$json.versions.Length-1]

return $lastVersion
 