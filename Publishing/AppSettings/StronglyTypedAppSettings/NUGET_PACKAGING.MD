Pack :
		-  dotnet pack -c Release -o <output_directory>  (. for current folder)

List Sources :
		dotnet nuget list source

Create Source :
		dotnet nuget add source -n <name> -s <source> --username <username> --password <password>

Push To Source :
		dotnet nuget push -s <source> -k <key> <package>

Push To Source (Local) :
		dotnet nuget push  <package>  -s C:\LocalNuget 