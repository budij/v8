# Setup Ubuntu
Follow the following steps to setup a new Ubuntu machine that can be used as a build machine. Save the script below as setup<i></i>.sh, add execute permission for the script (*chmod +x setup<i></i>.sh*), and execute it from a command prompt (*./setup.sh*).

```shell
#!/bin/sh

# The line 'export DEBIAN_FRONTEND=noninteractive' is only needed for automatic deployment using Azure built-in image
# This line can be commented out for setting up personal ubuntu server
export DEBIAN_FRONTEND=noninteractive
echo Current directory: ${PWD}

echo Update and upgrade to the latest version
apt-get update
apt-get upgrade -y

echo Install JDK because Jenkins need it
echo And, also install the following software: cmake, compiler, OpenSSL, Azure linux agent, flex, and bison
apt-get install default-jdk git cmake build-essential libssl-dev curl nano icu-devtools libicu-dev walinuxagent flex bison -y

echo Install the latest CMake

curl --location https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.3-Linux-x86_64.sh --output cmake-3.18.3-Linux-x86_64.sh
chmod +x cmake-3.18.3-Linux-x86_64.sh
./cmake-3.18.3-Linux-x86_64.sh --prefix=/usr --skip-license

echo Register Microsoft key and feed
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

echo Install the .NET SDK
apt-get update
apt-get install apt-transport-https -y
apt-get update
apt-get install dotnet-sdk-3.1 -y

echo Add the Mono repository to your system
apt install gnupg ca-certificates -y
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt update

echo Install Mono
apt-get install mono-devel -y

echo Install arduino-cli
wget -q https://github.com/arduino/arduino-cli/releases/download/0.11.0/arduino-cli_0.11.0_Linux_64bit.tar.gz -O arduino-cli.tar.gz
# For Raspberry pi
# wget -q https://github.com/arduino/arduino-cli/releases/download/0.11.0/arduino-cli_0.11.0_Linux_ARMv7.tar.gz -O arduino-cli.tar.gz
mkdir $HOME/arduino
tar -C $HOME/arduino -zxvf arduino-cli.tar.gz
$HOME/arduino/arduino-cli core update-index
$HOME/arduino/arduino-cli core install arduino:avr
ln -s /home/budij/arduino/arduino-cli /usr/local/bin/arduino-cli

# Follow instructions on https://github.com/Microsoft/Git-Credential-Manager-for-Mac-and-Linux/blob/master/Install.md to install git credential manager for linux

echo Prints out the versions for the tools that have been installed
git --version
cmake --version
gcc --version
g++ --version
mono --version
dotnet --version
flex --version
bison --version
arduino-cli --version

chown -R agentadmin:agentadmin ~/.dotnet

ls -la ~

# For Raspberry PI, we may need to increase the swap file. Follow the steps below:
# 1. Create an empty file (1K * 4M = 4 GiB).
#    sudo mkdir -v /var/cache/swap
#    cd /var/cache/swap
#    sudo dd if=/dev/zero of=swapfile bs=1K count=4M
#    sudo chmod 600 swapfile
# 2. Convert newly created file into a swap space file.
#    sudo mkswap swapfile
# 3. Enable file for paging and swapping.
#    sudo swapon swapfile
# 4. Verify by: swapon -s or top
#    sudo swapon -s
#    top -bn1 | grep -i swap
#    Should display line like: KiB Swap:  4194300 total,  4194300 free
# 5. Add it into fstab file to make it persistent on the next system boot.
#    echo "/var/cache/swap/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
# 6. Re-test swap file on startup by (Note: Below commands re-checks the syntax of fstab file, otherwise your Linux could not boot up properly):
#    sudo swapoff swapfile
#    sudo swapon -va
```

# Deploy Azure Agent VM
To automatically deploy Azure Agent VM in Jenkins, please install *Azure VM Agents* plugin.

Fill in the forms in Jenkins for the "Add Azure Virtual Machine Template":
* **Name**: *name of the VM* (e.g. ubuntu-vm)
* **Labels**: *Label for the VM* (e.g. ubuntu)
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
* **Image Publisher**: *publisher* (e.g. Canonical)
* **Image Offer**: *offer* (e.g. UbuntuServer)
* **Image SKU**: *sku* (e.g. 18.04-LTS)
* **Image Version**: *version* (e.g. latest)
* **OS Type**: Linux
* **Launch Method**: SSH
* **Pre-Install SSH in Windows Slave (Check when using Windows and SSH)**: ticked
* **Initialization Script**: Copied from above
* **Run Initialization Script As Root (Linux Only)**: ticked
* **Dont Use VM If Initialization Script Fails**: ticked

# Create Ubuntu VM image on Azure
Sometimes it is beneficial to prepare a VM to be used with Jenkins. This VM can be stored as a vhd file in a storage blob account

## Steps to create a new VHD
1. Create a new VM on Azure
2. Copy the script above to the new VM, and call it setup<i></i>.sh
3. chmod +x setup<i></i>.sh
4. sudo ./setup.sh 2>&1 | tee setup.log
5. Review setup.log, and make sure that there are no errors
6. After the installation is completed, manually modify /etc/waagent.conf
   - ResourceDisk.Format=y
   - ResourceDisk.Filesystem=ext4
   - ResourceDisk.MountPoint=/mnt/resource
   - ResourceDisk.EnableSwap=y
   - ResourceDisk.SwapSizeMB=2048    ## NOTE: Set this to your desired size.
7. sudo waagent -force -deprovision+user
8. export HISTSIZE=0
9. logout

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
* **Name**: *name of the VM* (e.g. ubuntu-vm)
* **Labels**: *Label for the VM* (e.g. ubuntu)
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
* **Custom Image URI**: *url for the blob storage* (e.g. https<i></i>://blobstorage/vhds/vm-ubuntu-bld.vhd)
* **OS Type**: Linux
* **Launch Method**: SSH
* **Pre-Install SSH in Windows Slave (Check when using Windows and SSH)**: ticked
* **Initialization Script**:
        <pre>
echo Make sure that the commands below is executed in non-interactive mode
export DEBIAN_FRONTEND=noninteractive
        </pre>
* **Run Initialization Script As Root (Linux Only)**: ticked
* **Dont Use VM If Initialization Script Fails**: ticked
