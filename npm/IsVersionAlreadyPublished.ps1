<#
.SYNOPSIS
This script check if a specific version of a package is already deployed on the npm repository
and return 1 (true) if it find a package, else 0 (false)

.PARAMETER
packageName : is the name of the package as referenced on npm
version : is the version of the package we want to check
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$packageName,
	[Parameter(Mandatory = $true)]
	[string]$version
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

if ($packageInfo.versions -match $version) {
	Write-Host "This package version is already published"
    return 1
}

return 0