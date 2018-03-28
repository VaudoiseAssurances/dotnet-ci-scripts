
param (
	[Parameter(Mandatory = $true)]
	[string]$solutionPath,
	[Parameter(Mandatory = $true)]
	[string]$configuration,
	[Parameter(Mandatory = $true)]
	[string]$outputPath,
	[Parameter(Mandatory = $false)]
	[string]$suffix
)

if($suffix)
{
    & dotnet pack $solutionPath --configuration $configuration --include-symbols --output "$outputPath" --no-build --version-suffix $suffix
}
else
{
    & dotnet pack $solutionPath --configuration $configuration --include-symbols --output "$outputPath" --no-build
}