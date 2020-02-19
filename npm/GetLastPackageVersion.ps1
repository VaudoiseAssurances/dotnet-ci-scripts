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

Try
{
	$packageInfo = (npm info $packageName -json) | ConvertFrom-Json
}
Catch
{
	Write-Host "The request to the npm server failed"
	exit 1
}

if ($packageInfo.error.code -eq "E404") {
	# package not found on the npm server
	Write-Host $packageInfo.summary
	return 0
}

$lastVersion = $packageInfo.versions[-1]
return $lastVersion