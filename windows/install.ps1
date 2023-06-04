
# Unattended Install of Google Chrome

# Unattended Install of Google Chrome

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

$LogFile = "C:\temp\startup.log";
$Installer = $env:TEMP + "\chrome_installer.exe";
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Installer;
Start-Process -FilePath $Installer -Args "/silent /install" -Verb RunAs -Wait;
"Google Chrome installed." | Out-File -FilePath $LogFile -Append;

Invoke-WebRequest "https://www.voidtools.com/Everything-1.4.1.1024.x64-Setup.exe" -OutFile "C:/temp/Everything-1.4.1.1024.x64-Setup.exe"
Invoke-WebRequest "wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/Everything.exe" -OutFile "C:/temp/Everything.exe"
$installerPath="c:\temp\Everything-1.4.1.1024.x64-Setup.exe"
#Start-Process -FilePath $installerPath -Args "/quiet" -NoNewWindow -Wait



Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -OutFile "c:\temp\install-docker-ce.ps1"

Invoke-WebRequest -Uri  https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/FortiClientEndpointManagementServer_7.0.7.0398_x64.exe -OutFile "c:\temp\FortiClientEndpointManagementServer_7.0.7.0398_x64.exe"
echo "C:\Users\adminuser\AppData\Local\Temp/FortiClientEMS_20230604105623.log"

Invoke-WebRequest -Uri https://filestore.fortinet.com/forticlient/downloads/FortiClientEndpointManagementServer_6.2.4.0894_x64.exe -OutFile "c:\temp\FortiClientEndpointManagementServer_6.2.4.0894_x64.exe" 

Invoke-WebRequest -Uri https://download.sysinternals.com/files/SysinternalsSuite.zip -OutFile "c:\temp\systeminternal.zip"

#Start-Process -FilePath "c:\temp\/FortiClientEndpointManagementServer_7.0.7.0398_x64.exe" -Args "/quiet" -NoNewWindow -Wait
Start-Process -FilePath "c:\temp\FortiClientEndpointManagementServer_7.0.7.0398_x64.exe" -Args "/quiet", "AllowedWebHostnames=*" -NoNewWindow -Wait

#Start-Process -FilePath "c:\temp\FortiClientEndpointManagementServer_6.2.4.0894_x64.exe" -Args "/quiet" -NoNewWindow -Wait

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install vim -y
echo https://filestore.fortinet.com/forticlient/
choco install -y cygwin --params "/InstallDir:C:\tools /NoStartMenu /NoAdmin" --force -y
choco install curl -y
cd c:/temp
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
#Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile c:\temp\Ubuntu.appx -UseBasicParsing
#Add-AppxPackage c:\temp\Ubuntu.appx
#wsl --install -d Ubuntu
#C:\ProgramData\chocolatey/choco.exe
##/mingw64/bin/git
New-NetFirewallRule -DisplayName "Allow Docker API" -Direction Inbound -LocalPort 2375 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Apache HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow

#choco install apache-httpd --params '"/installLocation:C:\HTTPD /port:433"' -y
choco install git -y
choco install wget -y
choco install grep -y
choco install sed -y
choco install gawk -y
choco install make -y
choco install 7zip -y
choco install azure-cli -y
choco install -y microsoft-windows-terminal 
choco install -y windows-iso-downloader


c:\temp\install-docker-ce.ps1
Restart-Computer -Force
c:\temp\install-docker-ce.ps1
