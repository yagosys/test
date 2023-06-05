#https://hub.docker.com/_/microsoft-windows-server/?tab=description
# Set the base image
FROM mcr.microsoft.com/windows/server:ltsc2022

# Copy the installer into the image
#ADD FortiClientEndpointManagementServer_7.0.7.0398_x64.exe c:/temp/setup.exe

# Switch the shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Run the installer
ADD https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/FortiClientEndpointManagementServer_7.0.7.0398_x64.exe c:/temp/setup.exe
#RUN Start-Process -FilePath "c:/temp/setup.exe" -Args "/quiet" -NoNewWindow -Wait
#RUN Start-Process -FilePath C:\temp\setup.exe -Args "/quiet" -WindowStyle Hidden -Wait
# Expose the required port
EXPOSE 443

# Set the default command
CMD [ "cmd" ]

