configuration SharePoint2019Prereqs
{
    Import-DscResource -ModuleName "xDownloadFile"
    
    Node localhost
    {
        xDownloadFile AppFabricKBDL
        {
            SourcePath = "https://download.microsoft.com/download/F/1/0/F1093AF6-E797-4CA8-A9F6-FC50024B385C/AppFabric-KB3092423-x64-ENU.exe"
            FileName = "AppFabric-KB3092423-x64-ENU.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
        }

        xDownloadFile MicrosoftIdentityExtensionsDL
        {
            SourcePath = "http://download.microsoft.com/download/0/1/D/01D06854-CA0C-46F1-ADBA-EBF86010DCC6/rtm/MicrosoftIdentityExtensions-64.msi"
            FileName = "MicrosoftIdentityExtensions-64.msi"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]AppFabricKBDL"
        }

        xDownloadFile MSIPCDL
        {
            SourcePath = "https://download.microsoft.com/download/3/C/F/3CF781F5-7D29-4035-9265-C34FF2369FA2/setup_msipc_x64.exe"
            FileName = "setup_msipc_x64.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]MicrosoftIdentityExtensionsDL"
        }

        xDownloadFile SQLNCLIDL
        {
            SourcePath = "https://download.microsoft.com/download/B/E/D/BED73AAC-3C8A-43F5-AF4F-EB4FEA6C8F3A/ENU/x64/sqlncli.msi"
            FileName = "sqlncli.msi"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]MSIPCDL"
        }

        xDownloadFile WcfDataServices56DL
        {
            SourcePath = "http://download.microsoft.com/download/1/C/A/1CAA41C7-88B9-42D6-9E11-3C655656DAB1/WcfDataServices.exe"
            FileName = "WcfDataServices56.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]SQLNCLIDL"
        }

        xDownloadFile AppFabricDL
        {
            SourcePath = "http://download.microsoft.com/download/A/6/7/A678AB47-496B-4907-B3D4-0A2D280A13C0/WindowsServerAppFabricSetup_x64.exe"
            FileName = "WindowsServerAppFabricSetup_x64.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]WcfDataServices56DL"
        }

        xDownloadFile DotNet472
        {
            SourcePath = "http://go.microsoft.com/fwlink/?linkid=863265"
            FileName = "NDP472-KB4054530-x86-x64-AllOS-ENU.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]AppFabricDL"
        }

        xDownloadFile SynchronizationDL
        {
            SourcePath = "http://download.microsoft.com/download/E/0/0/E0060D8F-2354-4871-9596-DC78538799CC/Synchronization.msi"
            FileName = "Synchronization.msi"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]DotNet472"
        }

        xDownloadFile MSVCRT141
        {
            SourcePath = "https://aka.ms/vs/15/release/vc_redist.x64.exe"
            FileName = "vc_redist.x64.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn = "[xDownloadFile]SynchronizationDL"
        }

        xDownloadFile MSVCRT11
        {
            SourcePath               = "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
            FileName                 = "vcredist_x64.exe"
            DestinationDirectoryPath = "c:\temp\prereqs\"
            DependsOn                = "[xDownloadFile]MSVCRT141"
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

SharePoint2019Prereqs -ConfigurationData $ConfigData