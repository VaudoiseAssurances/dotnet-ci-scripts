<#
.SYNOPSIS
	This script get the dll properties (version) and set them into a prop file
.DESCRIPTION
	Read the passed dll (full file path) and get the version number. Then create the passed output file with the prop
.PARAMETER
	dllPath : the full path to the dll to read
	outputFile : the output file path to create and where the props will be stored
.EXAMPLE
	 .\GetDllProps.ps1 myAmazing.dll propsOutput.prop
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$dllPath,
	[Parameter(Mandatory = $true)]
	[string]$outputFile
)

$version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($dllPath).FileVersion

$prop = "version=" + $version

Add-Content $outputFile $prop