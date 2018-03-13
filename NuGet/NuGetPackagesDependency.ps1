<#
.SYNOPSIS
This script gets the dependencies of the current solution
.PARAMETER
projectDirectory : path to the solution folder
csvFileName : name of the csv file 
projectId : id of the project
branchName : name of the branch we are building
.EXAMPLE
.\NuGetPackagesDependency.ps1 "${bamboo.build.working.directory}/PathToSolution" "${bamboo.GlobalVariableWithCsvFileName}" "ProjectId" "${bamboo.variable.with.branch.name}"
#>

param (
	[Parameter(Mandatory = $true)]
	[string]$projectDirectory,
	[Parameter(Mandatory = $true)]
	[string]$csvFileName,
	[Parameter(Mandatory = $true)]
	[string]$projectId,
	[Parameter(Mandatory = $true)]
	[string]$branchName
)

# Get a list of all packages written in all packages.config
Function List-AllPackages($baseDirectory) {

	# Get a list of packages.config files
    $listPackageConfig = Get-ChildItem -Recurse -Force $baseDirectory -ErrorAction SilentlyContinue | 
						Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -eq "packages.config")}
	
	$array  = @()
	
    foreach($packageConfig in $listPackageConfig)
        {
            $path = $packageConfig.FullName
            $xml = [xml]$packages = Get-Content $path
			foreach($package in $packages.packages.package)
			{
				 $array += $package
			}
        }
	return $array
}

# Filter the list with only *Va* packages (i.e. StartsWith(Va))
$listPackages = List-AllPackages($projectDirectory) | Where-Object {$_.Id -like 'Va*'} | Sort-Object -Property Id -Unique

# Build new CsvFile Name (pattern is CsvFileName_{WeekNumber}.{Year}.csv)
$fullCsvFileName = $csvFileName + "_" + (get-date -UFormat %V) + "." + (get-date).Year + ".csv"

# Append a new line to the $fullCsvFileName
foreach($package in $listPackages) {
	$hash = @{
		"Solution" = $projectId
		"Branch" = $branchName
		"Dependency" = $package.Id
		"DependencyVersion" = $package.Version
		"Date" = (Get-Date).ToString()
	}
	$newRow = New-Object PsObject -Property $hash
	Export-Csv $fullCsvFileName -inputobject $newrow -append -Force
}