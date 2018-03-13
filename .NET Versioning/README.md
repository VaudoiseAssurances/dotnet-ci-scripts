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
