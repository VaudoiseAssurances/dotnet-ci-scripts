<#
.SYNOPSIS
This script get the version of the node project we are in.
It searches for a package.json file and then resolve the actual version from that file

.PARAMETER
packageJsonFilePath : is the full path to the package.json file. If not given, the default 'package.json' value will be used
#>

param (
	[string] $packageJsonFilePath = "package.json"
)

$info = Get-Content $packageJsonFilePath | Out-String | ConvertFrom-Json

return $info.version