param(
    [Parameter(Mandatory=$true)][string]$drive,
    [Parameter(Mandatory=$true)][string]$project_folder,
    [string]$ToolChainURL = "http://cdn.unrealengine.com/CrossToolchain_Linux/v11_clang-5.0.0-centos7.zip"
)
Clear-Host;

$DriveLetters = (Get-Volume).DriveLetter;
if ($DriveLetters -contains $drive) {
    Write-Output "Valid Drive Letter Found.";
    $DriveLetter = $drive.ToUpper() + ":";
    $DeviceID = "DeviceID='$DriveLetter'";
    $CDisk = GWMI Win32_LogicalDisk -Filter $DeviceID;
    $FreeSpace = [Math]::Round($CDisk.FreeSpace / 1GB);
    if ($FreeSpace -gt "75") {
        Write-Output "$DriveLetter Drive has $FreeSpace GB Available, continuing Setup.";

        $gitInstalled = $null -ne ( (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*) + (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) | Where-Object { $null -ne $_.DisplayName -and $_.Displayname.Contains('Git') })

        if ($gitInstalled) {
          Write-Verbose "GIT Found, Continuing...";
          $WindowsSDK = $(Get-Item "hklm:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SDKs\Windows").GetValue("CurrentVersion");
          $WSDKVersion = $WindowsSDK.split('.');
          if ($WSDKVersion[0] -ge '8') {
            if ($WSDKVersion[2] -ge '50727') {
            Write-Output "Windows 8.1 SDK Found, Continuing..";
              $spatialInstalled = $null -ne ( (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*) + (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) | Where-Object { $null -ne $_.DisplayName -and $_.Displayname.Contains('SpatialOS') });
              if ($spatialInstalled) {
                Write-Output "SpatialOS Launcher/CLI Found, Continuing..";
                $ToolChainDirectory = $DriveLetter, $project_folder, $toolchain_directory;
                $ToolChainDirectory = $ToolChainDirectory -join "\";
                if (!(Test-Path $ToolChainDirectory)) {
                    Write-Output "Toolchain Directory does not exist, creating now.";
                    try {
                        [void](mkdir $ToolChainDirectory);
                    } catch {
                        Write-Error "Failed to Create Directory (Error: " $_.Exception.Message ")";
                        exit;
                    }
                } else {
                    Write-Output "Toolchain Directory Already Exists, Continuing...";
                }

                $ToolchainZipName = $ToolChainURL.Split("/")[-1];
                $ToolchainFilePath = Join-Path $ToolChainDirectory $ToolchainZipName;
                Write-Output ("[{0} Downloading to [{1}]" -f $ToolChainURL,$ToolchainFilePath);

                Invoke-WebRequest $ToolChainURL -OutFile $ToolchainFilePath;

                Write-Output ("Unpacking {0}" -f $ToolchainZipName);

                try {
                  $shell = New-Object -ComObject Shell.Application
                  $shell.Namespace($ToolChainDirectory).copyhere(($shell.NameSpace($ToolchainFilePath)).items())
                } catch {
                  Write-Warning -Message "Unexpected Error. (Error: " $_.Exception.Message ")"
                }

                $ToolChain = Get-ChildItem -Path $ToolchainFilePath -Recurse -Filter 'toolchain'
                [Environment]::SetEnvironmentVariable('LINUX_ROOT', $ToolChain.FullName, 'Machine') //LINUX_MULTIARCH_ROOT
                $multi = Join-Path $ToolChain.FullName '..'
                [Environment]::SetEnvironmentVariable('LINUX_MULTIARCH_ROOT', $multi, 'Machine')
                Get-Childitem $ToolChainDirectory -filter *.zip | Remove-item -force
                Write-Output "OK all Done!"
                Read-Host "Press any key to exit..."
exit
              } else {
               Write-Output "Please Install SpatialOS from: https://console.improbable.io/installer/download/stable/latest/win";
               Read-Host "Press any key to exit..."
exit
              }
            } else {
              Write-Output "Please Install Windows SDK 8.1 From: https://developer.microsoft.com/en-us/windows/downloads/sdk-archive";
              Read-Host "Press any key to exit..."
exit
            }
          } else {
            Write-Output "Please Install Windows SDK 8.1 From: https://developer.microsoft.com/en-us/windows/downloads/sdk-archive";
            Read-Host "Press any key to exit..."
  exit
          }
        } else {
          Write-Output "Please install GIT from: https://gitforwindows.org/";
          Read-Host "Press any key to exit..."
exit
        }

    } else {
        Write-Output "Please free up about 75gigs of Data for the Installation, and compiling of UE4 Editor";
        Read-Host "Press any key to exit..."
        exit
    }

} else {
    Write-Output "Please input a Valid Drive Letter.";
    Read-Host "Press any key to exit..."
exit
}
