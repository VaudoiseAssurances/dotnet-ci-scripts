# .NET Versioning

## Scripts descriptions

### DefineNextVersion
The purpose of this Script is only to return the deducted version number according to the passed version and the branch name.
If we are on the develop branch we suffix with a "betaXX", if we are on Master we keep it as is.

### GetDllProps
This script get the dll properties (version) of a specific dll and print them into a prop file

### GetVersionDotnet
Get the version setted in the assemblyInfo of a .NET project

### GetVersionDotnetCore
Get the version setted in the csproj of a .NetCore project

### SetAssemblyInfoVersionWithTimestamp
This script updates the AssemblyVersion of all sub-AssemblyInfo's files

### SetNextVersion
This script updates the AssemblyinformationVersion in the $assemblyInfoPath file.

### define-version-variables-appveyor
This script is focused on AppVeyor, and sets thw $suffix and $updatedVersion environment variables, in order to be used for the creation and publication of NuGet packages. In order to achieve this, the script makes use of other scripts in this repository.

### dotnet-pack-optionalsuffix
This script makes a safe call to ``dotnet pack $solutionPath --configuration $configuration --include-symbols --output "$outputPath" --no-build --version-suffix $suffix``. Contrary to calling ``dotnet pack`` directly, it will not fail if ``$suffix`` is not set. 
