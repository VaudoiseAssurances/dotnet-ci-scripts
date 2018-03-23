<#
.SYNOPSIS
This script get the version from the AssemblyinformationVersion in the $assemblyInfoPath file.
.DESCRIPTION
Consider a package A.
	- get the AssemblyInformationVersion stored in the $assemblyInfoPath file
.PARAMETER
assemblyInfoPath : path to the AssemblyInfo.cs
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$assemblyInfoPath
)


# Get AssemblyInfo version
$assemblyInfoVersion = Select-String -Path $assemblyInfoPath -Pattern 'AssemblyInformationalVersion\("([0-9]*).([0-9]*).([0-9]*)(.*?)"\)'  | % { $_.Matches }

$assemblyInfoVersion_major = $assemblyInfoVersion.Groups[1].Value
$assemblyInfoVersion_minor = $assemblyInfoVersion.Groups[2].Value
$assemblyInfoVersion_patch = $assemblyInfoVersion.Groups[3].Value

$version = $assemblyInfoVersion_major + "." + $assemblyInfoVersion_minor + "." + $assemblyInfoVersion_patch
return $version