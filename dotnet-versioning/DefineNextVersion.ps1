<#
.SYNOPSIS
This script return the version that should be set as the current version of the assembly/package. It will define it from a reference version passed, a package name and a branch name (develop branch should add a beta suffix).
.DESCRIPTION
Consider a given version.
    - will check the branch we are on:
        - if master, returns the passed version
        - if develop, continue de script
    - get the last available version in the NuGet's repository.
    - increment the version
    - returns the version
.PARAMETER
version : The actual version we want to suffix or not
packageName : Name of the package. used to find the package in the NuGet repository
branchName : Name of the branch. Used to set beta version (or not)
repoNuGet : path to the NuGet server
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$version,
	[Parameter(Mandatory = $true)]
	[string]$packageName,
	[Parameter(Mandatory = $true)]
	[string]$branchName,
	[Parameter(Mandatory = $true)]
	[string]$repoNuGet
)

Write-Host "PSScriptRoot: " + $PSScriptRoot

# Get AssemblyInfo version
$splittedVersion = Select-String -inputObject $version -Pattern '([0-9]*).([0-9]*).([0-9]*)(.*?)' | % { $_.Matches }
$splittedVersion_major = $splittedVersion.Groups[1].Value
$splittedVersion_minor = $splittedVersion.Groups[2].Value
$splittedVersion_patch = $splittedVersion.Groups[3].Value

# Get all available package versions
$packageVersions = & "$PSScriptRoot\.nuget\NuGet.exe" list $packageName -prerelease -allversions # -source $repoNuGet 
Write-Host $packageVersions

# Get the matching version
$filteredVersions = $packageVersions | Select-String -Pattern "$($splittedVersion_major).$($splittedVersion_minor).$($splittedVersion_patch)-[bB]eta([0-9]*)" -AllMatches | % { $_.Matches }


if($branchName -eq "master")
{	
	 $nextVersion = $splittedVersion_major + "." + $splittedVersion_minor + "." + $splittedVersion_patch
	 
	 if ($version -eq $nextVersion)
	 {
		 Write-Error "The current version $version was already deployed on $repoNuGet"
		 exit 1
	 }
}
else 
{
	if($filteredVersions.Length -eq 0)
	{	
	    $nextVersion = $splittedVersion_major + "." + $splittedVersion_minor + "." + $splittedVersion_patch + "-beta01"	
    } 
	else 
	{
	    # Get last version available
	    $lastVersion = $filteredVersions | Sort-Object -Property Groups[1] -desc | Select-Object -first 1 | % { $_.Value }
	
	    # Get next beta available
	    $semanticVersion    = $lastVersion | Select-String -Pattern "([0-9]*).([0-9]*).([0-9]*)-[bB]eta([0-9]*)" | % { $_.Matches }
	    $nextBeta = ([int]$semanticVersion.Groups[4].Value + 1).ToString("00")

	    # Set the next version
	    $nextVersion = $splittedVersion_major + "." + $splittedVersion_minor + "." + $splittedVersion_patch + "-beta" + $nextBeta
    }
}

# Write next version in the console
Write-Host "Next version is " + $nextVersion

return $nextVersion