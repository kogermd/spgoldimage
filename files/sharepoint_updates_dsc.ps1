configuration SharePointUpdates
{
    Import-DscResource -ModuleName "xDownloadFile"
    
    Node localhost
    {
        xDownloadFile SharePointCU
        {
            SourcePath               = "https://download.microsoft.com/download/8/5/5/8550cdeb-d803-44b4-b0a4-f245675adc40/sts2019-kb5002028-fullfile-x64-glb.exe"
            FileName                 = "sts2019-kb5002028-fullfile-x64-glb.exe"
            DestinationDirectoryPath = "c:\binaries\updates\"
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

SharePointUpdates -ConfigurationData $ConfigData