param (
	[Parameter(Mandatory = $true)]
	[string]$csprojPath,
	[Parameter(Mandatory = $true)]
	[string]$scriptsPath,
	[Parameter(Mandatory = $true)]
	[string]$packageName,
	[Parameter(Mandatory = $true)]
	[string]$branchName
)

# Find setted version
$version = & "$scriptsPath\GetVersionDotnetCore.ps1" $csprojPath

# TODO: Here : if the .csproj is malformed $version could be an array instead of a string, and throw an exception later.
# should we check and write an error message instead of retrieving the first cell ?
if ($version -is [array])
{
	$version = $version[0]
}

if (!$version)
{
    # The following line is appveyor-specific.
    Add-AppveyorMessage -Message "failed to read assembly version in $csprojPath" -Category Error -Details "Make sure the $csprojPath file contains a Project.PropertyGroup.AssemblyVersion node."
    exit 1
}

# Decide if the version should be changed
$updatedVersion = & "$scriptsPath\DefineNextVersion.ps1" $version $packageName $branchName 'DummyParameterBecauseImSureThisIsUseless'

# get the version suffix (ex: beta01) if any
$separatorPosition = $updatedVersion.IndexOf("-") + 1 


Add-AppveyorMessage -Message "assembly version detected: $updatedVersion" -Category Information 


if ($separatorPosition -gt 0)
{
    $suffix = $updatedVersion.Substring($separatorPosition)
    Add-AppveyorMessage -Message "suffix detected: $suffix" -Category Information
}
else
{
    $suffix = ""
    Add-AppveyorMessage -Message "No suffix detected. This is normal if the current branch ($branchName) is 'master' " -Category Information
}


Set-AppveyorBuildVariable "suffix" $suffix
Set-AppveyorBuildVariable "version" $updatedVersion