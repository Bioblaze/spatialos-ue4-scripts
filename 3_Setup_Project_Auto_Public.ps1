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
      Write-Output "Downloading Project Files from Git."
      $EnvironmentVar = Join-Path $ProjectDirectory 'ProjectFiles'
      $UE4Dir = Get-ChildItem -Path env:UNREAL_HOME
      $UE4Dir = $UE4Dir.value;

      $Repo = "https://" + $github_username + "@github.com/spatialos/UnrealGDKStarterProject.git"
      git clone $Repo ProjectFiles

      $pSet = Join-Path $EnvironmentVar "Game"
      Set-Location $pSet
      new-item -Name "Plugins" -ItemType directory
      $pSet = Join-Path $pSet "Plugins"

      Set-Location $pSet
      $Repo = "https://" + $github_username + "@github.com/spatialos/UnrealGDK.git"
      git clone $Repo
      Write-Output "Now Triggering Setup.bat to Setup UnrealGDK for SpatialOS."
      $Setup = Join-Path $EnvironmentVar 'Game\Plugins\UnrealGDK\Setup.bat'
      Start-Process $Setup -Verb runas

      Write-Output "Now Setting Version for the Project."
      $upPath = Join-Path $EnvironmentVar "StarterProject.uproject"
      $vsArgs = "-switchversionsilent " + $upPath + " " + $UE4Dir;
      $vsDir = Join-Path $UE4Dir 'Engine\Binaries\Win64\UnrealVersionSelector.exe'
      $vsProc = Start-Process -FilePath $vsDir -ArgumentList $vsArgs -PassThru -Verb RunAs
      $vsProc.WaitForExit()

      Set-Location $EnvironmentVar
      $pf = "programfiles(x86)"
      $msBuildDir = Get-ChildItem -Path env:$pf
      $msBuildDir = Join-Path $msBuildDir.value "\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe"
      $msArgs = "StarterProject.sln /target:Games\StarterProject"
      $msBuild = Start-Process $msBuildDir -ArgumentList $msArgs -Passthru -Verb RunAs
      $msBuild.WaitForExit()
      Write-Output "Now go back to the Tutorial and Read the Rest! We're Done Here!";
      Set-Location $PSScriptRoot;
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
