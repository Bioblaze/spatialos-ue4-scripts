param(
    [Parameter(Mandatory=$true)][string]$drive,
    [Parameter(Mandatory=$true)][string]$project_folder,
    [Parameter(Mandatory=$true)][string]$github_username
)
Clear-Host;

$DriveLetters = (Get-Volume).DriveLetter;
if ($DriveLetters -contains $drive) {
    Write-Output "Valid Drive Letter Found.";
    $DriveLetter = $drive.ToUpper() + ":";
    $ProjectDirectory = $DriveLetter, $project_folder;
    $ProjectDirectory = $ProjectDirectory -join "\";
    if ((Test-Path $ProjectDirectory)) {
      Set-Location $ProjectDirectory;
      Write-Output "Downloading Unreal Engine|Spatial OS Build from Git."
      git clone https://$github_username@github.com/improbableio/UnrealEngine.git

      $EnvironmentVar = Join-Path $ProjectDirectory 'UnrealEngine'
      [Environment]::SetEnvironmentVariable('UNREAL_HOME', $EnvironmentVar, 'Machine')
      Write-Output "Setup Environment Variable for UNREAL_HOME";
      $Setup = Join-Path $EnvironmentVar 'Setup.bat'
      $sProc = Start-Process $Setup -PassThru -Verb RunAs
      $sProc.WaitForExit()
      $Generate = Join-Path $EnvironmentVar 'GenerateProjectFiles.bat'
      $gProc = Start-Process $Generate -PassThru -Verb RunAs
      $gProc.WaitForExit()

      Set-Location $EnvironmentVar
      $pf = "programfiles(x86)"
      $msBuildDir = Get-ChildItem -Path env:$pf
      $msBuildDir = Join-Path $msBuildDir.value "\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe"
      $msArgs = 'UE4.sln /target:Engine\UE4 /p:Configuration="Development Editor" /p:Platform="Win64"'
      $msBuild = Start-Process $msBuildDir -ArgumentList $msArgs -Passthru -Verb RunAs
      $msBuild.WaitForExit()

      Write-Output "Now Follow the Rest of the Guide.";
      Read-Host "Press any key to exit..."
      exit
    } else {
      Write-Output "Please run the 1_Setup_ToolChain.ps1 first, or Create a Folder called "+$project_folder+" in the Drive you Selected.";
      Read-Host "Press any key to exit..."
exit
    }
} else {
    Write-Output "Please input a Valid Drive Letter.";
    Read-Host "Press any key to exit..."
exit
}
