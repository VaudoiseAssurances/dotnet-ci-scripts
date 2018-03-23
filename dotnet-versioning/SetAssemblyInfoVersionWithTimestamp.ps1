<#
.SYNOPSIS
	This script updates the AssemblyVersion of all sub-AssemblyInfo's files
.DESCRIPTION
	Loop through all AssemblyInfo.cs files, and set the new version with the following timestamp : ddMMyyHHmmss
.PARAMETER
	none
.EXAMPLE
	.\SetAssemblyInfoVersionWithTimestamp.ps1 myAmazingPath
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$solutionPath
)

# Get timestamp
$timestamp = Get-Date -Format ddMMyyHHmmss

# Loop through sub-folders
Get-ChildItem $solutionPath -Filter AssemblyInfo.cs -Recurse | 
	ForEach-Object {
		
		# Get AssemblyInfo version
		$assemblyFileVersion = Select-String -Path $_.FullName -Pattern 'AssemblyFileVersion\("([0-9]*).([0-9]*).([0-9]*).([0-9]*)"\)'  | % { $_.Matches }
		$assemblyFileVersion_major = $assemblyFileVersion.Groups[1].Value
		$assemblyFileVersion_minor = $assemblyFileVersion.Groups[2].Value
		$assemblyFileVersion_patch = $assemblyFileVersion.Groups[3].Value

		# Build $nextVersion
		$nextVersion = $assemblyFileVersion_major + "." + $assemblyFileVersion_minor + "." + $assemblyFileVersion_patch + "." + $timestamp

		# Information to user
		Write-Host "Replace AssemblyInfo version of " $_.FullName " with " $nextVersion
		
		# Replace AssemblyInfo.cs with the timestamped version
		[IO.File]::WriteAllLines($_.FullName, ((Get-Content $_.FullName) | 
			ForEach-Object { 
				$_ -replace 'AssemblyFileVersion\("([0-9]*).([0-9]*).([0-9]*).([0-9]*)"\)', "AssemblyFileVersion(""$nextVersion"")" 
			}
		))
		
		# Warning : This only gets the last assemblyVersion (and not all of them). We suppose they are all the same (through a SharedAssemblyInfo)
		[IO.File]::WriteAllLines($solutionPath + "/semanticVersion.prop", "semanticVersion=" + $nextVersion)
	}
