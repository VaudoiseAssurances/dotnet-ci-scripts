<#
.SYNOPSIS
This script updates the AssemblyinformationVersion in the $assemblyInfoPath file.
.DESCRIPTION
Consider a package A.
	- get the AssemblyInformationVersion stored in the $assemblyInfoPath file ;
	- it checks the $repoNuGet if package A exists :
		- get the last available version in the NuGet's repository.
	- set the AssemblyInformationalVersion to 
		- X.Y.Z-Beta(n+1) when building on branches different than 'master'
		- X.Y.Z when building on branch 'master'
.PARAMETER
assemblyInfoPath : path to the AssemblyInfo.cs
packageName : Name of the package. used to find the package in the NuGet repository
branchName : Name of the branch. Used to set Beta version (or not)
repoNuGet : path to the NuGet server
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$assemblyInfoPath,
	[Parameter(Mandatory = $true)]
	[string]$packageName,
	[Parameter(Mandatory = $true)]
	[string]$branchName,
	[Parameter(Mandatory = $true)]
	[string]$repoNuGet,
	[Parameter(Mandatory = $false)]
	[string]$propFileName
)

"PSScriptRoot:" + $PSScriptRoot

# Get AssemblyInfo version
$assemblyInfoVersion = Select-String -Path $assemblyInfoPath -Pattern 'AssemblyInformationalVersion\("([0-9]*).([0-9]*).([0-9]*)(.*?)"\)'  | % { $_.Matches }
$assemblyInfoVersion_major = $assemblyInfoVersion.Groups[1].Value
$assemblyInfoVersion_minor = $assemblyInfoVersion.Groups[2].Value
$assemblyInfoVersion_patch = $assemblyInfoVersion.Groups[3].Value

# Get all available package versions
$packageVersions = Find-Package $packageName -AllVersions -AllowPrereleaseVersions -Source $repoNuGet

# Get the matching version
$filteredVersions = $packageVersions | Where-Object -property Version -Match "$($assemblyInfoVersion_major).$($assemblyInfoVersion_minor).$($assemblyInfoVersion_patch)-[bB]eta([0-9]*)"

# Is there a final version already ?
$finalVersion = $packageVersions | Where-Object -property Version -Match  "$($assemblyInfoVersion_major).$($assemblyInfoVersion_minor).$($assemblyInfoVersion_patch)(?!-[bB]eta([0-9]*))" | Select-Object -ExpandProperty Version -First 1

# If NuGet already has a final version, then we can't do anything. Developers need to udpate their AssemblyInfo first
if($finalVersion -eq $assemblyInfoVersion_major + "." + $assemblyInfoVersion_minor + "." + $assemblyInfoVersion_patch) 
{
    throw "A version $($finalVersion) already exists in the package repository. Please update your $($assemblyInfoPath)"
}

if($branchName -eq "master")
{
     $nextVersion = $assemblyInfoVersion_major + "." + $assemblyInfoVersion_minor + "." + $assemblyInfoVersion_patch
}
else 
{
    if($filteredVersions.Length -eq 0) {
	
	    $nextVersion = $assemblyInfoVersion_major + "." + $assemblyInfoVersion_minor + "." + $assemblyInfoVersion_patch + "-beta01"
	
    } 
	else 
	{
	    # Get last version available
	    $lastVersion = $filteredVersions | Sort-Object -Property Version | Select-Object -ExpandProperty Version -Last 1
	
	    # Get next beta available
	    $semanticVersion    = $lastVersion | Select-String -Pattern "([0-9]*).([0-9]*).([0-9]*)-[bB]eta([0-9]*)" | % { $_.Matches }
	    $nextBeta = ([int]$semanticVersion.Groups[4].Value + 1).ToString("00")

	    # Set the next version
	    $nextVersion = $assemblyInfoVersion_major + "." + $assemblyInfoVersion_minor + "." + $assemblyInfoVersion_patch + "-beta" + $nextBeta
    }
}

# Write next version on console
"Next version is " + $nextVersion

# Replace AssemblyInfo.cs with the newer version ($nextVersion)
[IO.File]::WriteAllLines($assemblyInfoPath, ((Get-Content $assemblyInfoPath) | ForEach-Object { $_ -replace 'AssemblyInformationalVersion\("([0-9]*).([0-9]*).([0-9]*)(.*?)"\)', "AssemblyInformationalVersion(""$nextVersion"")" }))

# Inject in prop file
if ($propFileName.Length -eq 0) {
    $propFileName = 'release.props'
}

# Set assembly version
$assemblyversion=  "$nextVersion.$((get-date).ToString("HHmmssff"))"

# Write Assembly version on console
"Assembly version : " + $assemblyversion

# Build properties to inject into file
$prop = "version=" + $nextVersion + "`r`n"
$prop = $prop + "assemblyversion=" + $assemblyversion 

# Create or update file
if (!(Test-Path $propFileName)){
    "Create file " + $propFileName
    New-Item -Path . -Name $propFileName -Value $prop
} 
else {
    Add-Content $propFileName $prop
}
