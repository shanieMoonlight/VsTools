using System.IO;
using System.Reflection;
using System.Xml.Linq;
using Xunit;

namespace StronglyTypedAppSettings.Tests;

public class VersionConsistencyTests
{
    [Fact]
    public void ProjectVersion_ShouldMatch_VersionProviderVersion()
    {
        // Act
        string projectVersion = GetProjectVersion("C:\\Users\\Shaneyboy\\source\\repos\\VsTools\\Apps\\AppSettings\\StronglyTypedAppSettings\\StronglyTypedAppSettings.csproj");
        string codeVersion = VersionProvider.Version;
        
        // Assert
        Assert.Equal(projectVersion, codeVersion);
    }


    private static string GetProjectVersion(string projectFilePath)
    {
        XDocument projectFile = XDocument.Load(projectFilePath);
        XElement? versionElement = projectFile.Root
            ?.Elements("PropertyGroup")
            ?.Elements("Version")
            ?.FirstOrDefault();

        if (versionElement == null)
            throw new InvalidDataException("Version element not found in project file");

        return versionElement.Value;
    }
}