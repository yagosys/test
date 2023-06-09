
- Build EMS windows container 

-- Prepare Build VM

-- Prepare VM host 
  Windows 2022 Data Center Version

-- install Docker
```
  Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -OutFile "c:\temp\install-docker-ce.ps1"
c:\temp\install-docker-ce.ps1


```
-- enable 2375 optional
```
# 'C:\ProgramData\docker\config\daemon.json'
{
  "hosts": ["tcp://0.0.0.0:2375", "npipe://"],
  "experimental": true
}
```
-- allow 2375 tcp port optional
```
New-NetFirewallRule -DisplayName "Allow Docker API" -Direction Inbound -LocalPort 2375 -Protocol TCP -Action Allow
```

-- Build EMS container


--- creaet Dockerfile
```
#https://hub.docker.com/_/microsoft-windows-server/?tab=description
# Set the base image
FROM mcr.microsoft.com/windows/server:ltsc2022


# Switch the shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Run the installer
ADD https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/FortiClientEndpointManagementServer_7.0.7.0398_x64.exe c:/temp/setup.exe
#RUN Start-Process -FilePath "c:/temp/setup.exe" -Args "/quiet" -NoNewWindow -Wait

# Expose the required port
EXPOSE 443

# Set the default command
CMD [ "cmd" ]
```
--- Build contaienr
```
docker build -t ems7 . 
```

--- Startup EMS container

```
 docker run -it --rm  ems7 POWERSHELL
```
--- Install EMS 
```
RUN Start-Process -FilePath "c:/temp/setup.exe" -Args "/quiet" -NoNewWindow -Wait

```

this step is failed, the setup will go on, but at last, it will rollback and uninstall the EMS

```
