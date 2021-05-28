# Setup Windows
Follow the following steps to setup a new Windows machine that can be used as a build machine. Save the script below as setup.ps1, and execute it on a Powershell prompt.

```powershell
# Setup Powershell
Set-ExecutionPolicy Unrestricted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Default workspace location
Set-Location C:\


# Install Java
Write-Host "Download and Install Java"
$source = "https://download.oracle.com/otn-pub/java/jdk/14.0.2+12/205943a0976c4ed48cb16f1043c5c647/jdk-14.0.2_windows-x64_bin.exe"
$destination = "C:\jdk-14.0.1_windows-x64_bin.exe"
$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
$client.downloadFile($source, $destination)

Write-Host "Start Java installation"
$proc = Start-Process -FilePath $destination -ArgumentList "/s" -Wait -PassThru
$proc.WaitForExit()
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-14.0.1")
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-14.0.1", "Machine")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";C:\Program Files\Java\jdk-14.0.1\bin")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";C:\Program Files\Java\jdk-14.0.1\bin", "Machine")


# Install Git
Write-Host "Download and Install Git"
$source = "https://github.com/git-for-windows/git/releases/latest"
$latestRelease = Invoke-WebRequest -UseBasicParsing $source -Headers @{"Accept"="application/json"}
$json = $latestRelease.Content | ConvertFrom-Json
$latestVersion = $json.tag_name
$versionHead = $latestVersion.Substring(1, $latestVersion.IndexOf("windows")-2)
$source = "https://github.com/git-for-windows/git/releases/download/v${versionHead}.windows.1/Git-${versionHead}-64-bit.exe"
$destination = "C:\Git-${versionHead}-64-bit.exe"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)

Write-Host "Start Git installation"
$proc = Start-Process -FilePath $destination -ArgumentList "/VERYSILENT" -Wait -PassThru
$proc.WaitForExit()
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Program Files\Git\cmd')
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Program Files\Git\cmd', 'Machine')

# Disable git credential manager, get more details in https://support.cloudbees.com/hc/en-us/articles/221046888-Build-Hang-or-Fail-with-Git-for-Windows
git config --system --unset credential.helper


# Install CMake
Write-Host "Download and Install CMake"
$source = "https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.3-win64-x64.msi"
$destination = "C:\cmake-3.18.3-win64-x64.msi"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)
Write-Host "Start CMake installation"
$proc = Start-Process -FilePath $destination -ArgumentList "/passive" -Wait -PassThru
$proc.WaitForExit()
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Program Files\CMake\bin')
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Program Files\CMake\bin', 'Machine')


# Install Strawberry perl
Write-Host "Download and Install Strawberry Perl"
$source = "http://strawberryperl.com/download/5.30.2.1/strawberry-perl-5.30.2.1-64bit.msi"
$destination = "C:\strawberry-perl-5.30.2.1-64bit.msi"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)

Write-Host "Start Strawberry Perl installation"
$proc = Start-Process -FilePath $destination -ArgumentList "/passive" -Wait -PassThru
$proc.WaitForExit()
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Strawberry\perl\bin')
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Strawberry\perl\bin', 'Machine')


# Install NASM 2.14.02
Write-Host "Download and Install NASM"
$source = "https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/win64/nasm-2.14.02-win64.zip"
$destination = "C:\nasm-2.14.02-win64.zip"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)

Write-Host "Start NASM installation"
Expand-Archive -Path $destination -DestinationPath C:\
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\nasm-2.14.02')
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\nasm-2.14.02', 'Machine')


# Install arduino-cli 0.11
Write-Host "Download and Install Arduino CLI 0.11"
$source = "https://github.com/arduino/arduino-cli/releases/download/0.11.0/arduino-cli_0.11.0_Windows_64bit.zip"
$destination = "C:\arduino-cli_0.11.0_Windows_64bit.zip"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)

Write-Host "Start Arduino CLI installation"
Expand-Archive -Path $destination -DestinationPath C:\arduino-cli
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\arduino-cli')
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\arduino-cli', 'Machine')
arduino-cli core update-index
arduino-cli core install arduino:avr

# Install Dotnet Core 3.1
Write-Host "Download and Install Dotnet Core 3.1"
$source = "https://download.visualstudio.microsoft.com/download/pr/43660ad4-b4a5-449f-8275-a1a3fd51a8f7/a51eff00a30b77eae4e960242f10ed39/dotnet-sdk-3.1.200-win-x64.exe"
$destination = "C:\dotnet-sdk-3.1.200-win-x64.exe"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($source, $destination)

Write-Host "Start Dotnet Core 3.1 installation"
$proc = Start-Process -FilePath $destination -ArgumentList "/passive" -Wait -PassThru
$proc.WaitForExit()
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Program Files\dotnet;')
[Environment]::SetEnvironmentVariable('PATH', $Env:Path + ';C:\Program Files\dotnet;', 'Machine')


# Install google chrome
Write-Host "Download and Install Google Chrome"
$Path = $env:TEMP
$Installer = "chrome_installer.exe"
Invoke-WebRequest "https://dl.google.com/chrome/install/latest/$Installer" -OutFile $Path\$Installer
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait


# Prints out the versions for the tools
Write-Host "Dotnet version:"
dotnet --version

Write-Host "Git version:"
git --version

Write-Host "Cmake version:"
cmake --version

Write-Host "Nasm version:"
nasm --version

Write-Host "Perl version:"
perl --version

Write-Host "Arduino-cli version:"
arduino-cli version

Write-Host "Chrome version:"
wmic datafile where name="C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe" get Version /value
```

# Deploy Azure Agent VM
To automatically deploy Azure Agent VM in Jenkins, please install *Azure VM Agents* plugin.

Fill in the forms in Jenkins for the "Add Azure Virtual Machine Template":
* **Name**: *name of the VM* (e.g. win2019-vm)
* **Labels**: *Label for the VM* (e.g. win2019)
* **Region**: *VM region* (e.g. East US 2)
* **Availability Options**: No Infrastructure redundancy required
* **Virtual Machine Size**: *Size of the virtual machine* (e.g. Standard_DS3_v2)
* **Storage Account Type**: Standard_LRS
* **Storage Account Name**: *Name of the storage account to be used* (e.g. JenkinsBuild)
* **Choose disks type**: Managed Disk
* **Retention Strategy**: Azure VM Idle Retention Strategy
* **Retention Time in Minute**: 15
* **Usage**: Use this node as much as possible
* **Image Configuration**: Use Advanced Image Configuration > "Image Reference"
* **Image Publisher**: *publisher* (e.g. MicrosoftVisualStudio)
* **Image Offer**: *offer* (e.g. visualstudio2019latest)
* **Image SKU**: *sku* (e.g. vs-2019-ent-latest-ws2019)
* **Image Version**: *version* (e.g. latest)
* **OS Type**: Windows
* **Launch Method**: SSH
* **Pre-Install SSH in Windows Slave (Check when using Windows and SSH)**: ticked
* **Initialization Script**: Copied from above
* **Run Initialization Script As Root (Linux Only)**: ticked
* **Dont Use VM If Initialization Script Fails**: ticked

# Create Windows VM image on Azure
Sometimes it is beneficial to prepare a VM to be used with Jenkins. This VM can be stored as a vhd file in a storage blob account

## Steps to create a new VHD
1. Create a new VM on Azure
2. Copy the script above to the new VM, and call it setup.ps1
3. Open powershell, and navigate to the script location
4. ./setup.ps1
5. After the installation is completed, manually install chrome browser
6. Open a Command Prompt window as an administrator. Change the directory to %windir%\system32\sysprep, and then run sysprep.exe.
7. In the System Preparation Tool dialog box, select Enter System Out-of-Box Experience (OOBE) and select the Generalize check box.
8. For Shutdown Options, select Shutdown.
9. Select OK.
10. When Sysprep completes, it shuts down the VM. Do not restart the VM.

## The following steps are to be done with Azure CLI to copy the VHD file to a blob storage account
1. az vm deallocate --resource-group myResourceGroup --name myVM
2. az vm generalize --resource-group myResourceGroup --name myVM
3. Find out the name of the managed disk
   - az vm show --resource-group myResourceGroup --name myVM
   - Find the "osdisk" name, e.g. myVM_disk1_436bbafffd3f45f7a50fb8446ec419ab
4. Grant access to read from the managed disk:
   - az disk grant-access --access-level Read --duration-in-seconds 86400 --resource-group myResourceGroup --name myVM_disk1_436bbafffd3f45f7a50fb8446ec419ab
   - Note the accessSas for the next step
5. Get the storage account key:
   - az storage account keys list --account-name myStorageAccountName --resource-group myResourceGroup
   - Note the first key for the next step
6. Start asynchronous copy:
   - az storage blob copy start --destination-blob myVM.vhd --destination-container vhds --source-uri "mySourceSaS" --account-name myStorageAccountName --account-key myStorageAccountKey
7. Check the status of the copy:
   - az storage blob show --account-name myStorageAccountName --container-name vhds --name myVM.vhd
   - Wait for the copy status to be successful
8. Delete the resources used by the original VM

## Deploy Azure Agent VM using the VHD file from the blob storage
To automatically deploy Azure Agent VM in Jenkins, please install *Azure VM Agents* plugin.

Fill in the forms in Jenkins for the "Add Azure Virtual Machine Template":
* **Name**: *name of the VM* (e.g. win2019-vm)
* **Labels**: *Label for the VM* (e.g. win2019)
* **Region**: *VM region* (e.g. East US 2)
* **Availability Options**: No Infrastructure redundancy required
* **Virtual Machine Size**: *Size of the virtual machine* (e.g. Standard_DS3_v2)
* **Storage Account Type**: Standard_LRS
* **Storage Account Name**: *Name of the storage account to be used* (e.g. JenkinsBuild)
* **Choose disks type**: Managed Disk
* **Retention Strategy**: Azure VM Idle Retention Strategy
* **Retention Time in Minute**: 15
* **Usage**: Use this node as much as possible
* **Image Configuration**: Use Advanced Image Configuration > "Custom User Image"
* **Custom Image URI**: *url for the blob storage* (e.g. https<i></i>://blobstorage/vhds/vm-win2019-bld.vhd)
* **OS Type**: Windows
* **Launch Method**: SSH
* **Pre-Install SSH in Windows Slave (Check when using Windows and SSH)**: ticked
* **Initialization Script**:
        <pre>
Set-ExecutionPolicy Unrestricted
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-Location C:\
        </pre>
* **Run Initialization Script As Root (Linux Only)**: ticked
* **Dont Use VM If Initialization Script Fails**: ticked
