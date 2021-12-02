configuration SharePointBinaries
{
    Import-DscResource -ModuleName "xDownloadFile"
    
    Node localhost
    {
        xDownloadFile SharePointImgFile
        {
            SourcePath = "https://download.microsoft.com/download/C/B/A/CBA01793-1C8A-4671-BE0D-38C9E5BBD0E9/officeserver.img"
            FileName = "officeserver.img"
            DestinationDirectoryPath = "c:\binaries\"
        }
    }
}

$ConfigData = @{
    AllNodes = @(
    @{
        NodeName = "localhost";
        PSDscAllowPlainTextPassword = $true;
        PSDscAllowDomainUser = $true;
    }
)}

SharePointBinaries -ConfigurationData $ConfigData