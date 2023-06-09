> above is only to luanch a windows container with ems installer inside.
> however ,the install of EMS is not sucessful yet. 

## create POD

```
kubectl create -f ems.yaml
```
### wait for POD be ready

```
kubectl wait --for=condition=Ready pod -l app=ems
```
result
```
andy [ ~/test/deploy_ems_container_with_slb ]$ kubectl get pod -l app=ems
NAME                  READY   STATUS    RESTARTS   AGE
ems-db546977c-wn6d9   1/1     Running   0          15m
```

### login into POD

```

podname=$(kubectl get pod -l app=ems | grep '1/1' | awk '{print $1}')

kubectl exec -it po/$podname -- POWERSHELL

```
result
```
Copyright (C) Microsoft Corporation. All rights reserved.

Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows


PS C:\> cd c:\temp
PS C:\temp> 
```

### install ems 
once inside the container 

```
.\setup.exe /quiet /AllowedWebHostnames=* 
```

result
install failed , the install will be carry on, but will rollback and remove all installed files

```
PS C:\Program Files (x86)\Fortinet\FortiClientEMS> dir


    Directory: C:\Program Files (x86)\Fortinet\FortiClientEMS


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----          6/9/2023   6:59 AM                Apache24
d-----          6/9/2023   6:59 AM                Clients
d-----          6/9/2023   6:59 AM                ClientUninstaller
d-----          6/9/2023   6:59 AM                Fcm
d-----          6/9/2023   7:01 AM                fctuploads
d-----          6/9/2023   6:59 AM                google
d-----          6/9/2023   6:59 AM                locales
d-----          6/9/2023   7:03 AM                logs
d-----          6/9/2023   7:00 AM                Python
d-----          6/9/2023   6:59 AM                signatures
d-----          6/9/2023   6:59 AM                swiftshader
d-----          6/9/2023   7:00 AM                wfcustompages
-a----         8/24/2022   1:54 PM         269312 7za.dll
-a----         8/24/2022   1:54 PM         739840 7za.exe
-a----         11/3/2019  10:32 AM        2891555 cef.pak
-a----         11/3/2019  10:20 AM         756491 cef_100_percent.pak
-a----         11/3/2019  10:20 AM         908424 cef_200_percent.pak
-a----         11/3/2019  10:32 AM        1706198 cef_extensions.pak
-a----         8/24/2022   2:07 PM        1010320 chrome_elf.dll
-a----         8/24/2022   2:07 PM         112784 ConnectionStringHelperx64.dll
-a----         8/24/2022   2:07 PM        4340880 d3dcompiler_47.dll
-a----          6/9/2023   7:00 AM            372 das.conf
-a----          6/9/2023   7:00 AM           1331 db.conf
-a----         8/24/2022   2:07 PM        3771536 DBTools.dll
-a----         11/3/2019   9:59 AM        6353657 devtools_resources.pak
-a----         8/24/2022   2:07 PM         109712 DirectoryAuthx64.dll
-a----         8/24/2022   2:07 PM        1000080 DiscUtils.dll
-a----         8/24/2022   2:07 PM          29840 DistinguishedNameParser.dll
-a----         8/24/2022   2:07 PM          36496 DMGTool.exe
-a----         8/24/2022   2:07 PM        2547856 EMSDiagnosticTool.exe
-a----         8/24/2022   1:54 PM         110592 fasle.dll
-a----         8/24/2022   2:07 PM         170128 FcmAdDaemon.exe
-a----         8/24/2022   1:54 PM            357 FcmAdDaemon.exe.config
-a----         8/24/2022   2:07 PM         540816 FcmChromebookDaemon.exe
-a----         8/24/2022   1:54 PM            914 FcmChromebookDaemon.exe.conf
-a----         8/24/2022   2:07 PM         505488 FcmDaemon.exe
-a----         8/24/2022   1:54 PM            596 FcmDaemon.exe.conf
-a----         8/24/2022   2:07 PM         357008 FcmDeploy.exe
-a----         8/24/2022   1:54 PM           1057 FcmDeploy.exe.conf
-a----         8/24/2022   2:07 PM         644240 FcmMonitor.exe
-a----         8/24/2022   1:54 PM            558 FcmMonitor.exe.conf
-a----         8/24/2022   2:07 PM        2582672 FcmUpdateDaemon.exe
-a----         8/24/2022   2:07 PM         376976 fcp.dll
-a----         8/24/2022   2:07 PM       16409232 FCTDas.exe
-a----         8/24/2022   2:07 PM         359056 FctRepackager.exe
-a----         8/24/2022   1:54 PM           1757 FctRepackager.exe.conf
-a----         8/24/2022   2:07 PM        1629840 FortiClientEndpointManagementServer.exe
-a----         8/24/2022   2:07 PM        9395344 FOS_Server.exe
-a----         11/1/2019   3:26 PM       10426784 icudtl.dat
-a----         8/24/2022   2:07 PM         175760 impipsdb.exe
-a----         8/24/2022   2:07 PM         783504 impvulndb.exe
-a----         8/24/2022   1:54 PM       37408256 lego.exe
-a----         8/24/2022   2:07 PM      115636368 libcef.dll
-a----         8/24/2022   1:54 PM        3430504 libcrypto-1_1-x64.dll
-a----         8/24/2022   1:54 PM        2535528 libcrypto-1_1.dll
-a----         8/24/2022   2:07 PM         385680 libEGL.dll
-a----         8/24/2022   2:07 PM        7614608 libGLESv2.dll
-a----         8/24/2022   1:54 PM         695400 libssl-1_1-x64.dll
-a----         8/24/2022   1:54 PM         544360 libssl-1_1.dll
-a----         8/24/2022   1:54 PM         193400 libtcmalloc_minimal.dll
-a----         11/3/2019  10:06 AM          82118 natives_blob.bin
-a----         8/24/2022   1:54 PM         700336 Newtonsoft.Json.dll
-a----         8/24/2022   2:07 PM        2110096 policyhelper.dll
-a----         8/24/2022   2:07 PM        2007184 SendFailureReport.exe
-a----         8/24/2022   2:07 PM        8334480 setdbcredentials.exe
-a----         8/24/2022   1:54 PM          55808 setupbld.exe
-a----         8/24/2022   1:54 PM          57344 SetupBuilder.dll
-a----         11/3/2019  10:50 AM         280424 snapshot_blob.bin
-a----         8/24/2022   1:54 PM            197 sw_inventory_staging.fmt
-a----         8/24/2022   1:54 PM            185 sw_inventory_staging_v2.fmt
-a----         8/24/2022   1:54 PM          27840 System.Buffers.dll
-a----         8/24/2022   1:54 PM         180296 System.Collections.Immutable.dll
-a----         8/24/2022   1:54 PM         144016 System.Memory.dll
-a----         8/24/2022   1:54 PM          22160 System.Runtime.CompilerServices.Unsafe.dll
-a----         11/3/2019  10:56 AM         701096 v8_context_snapshot.bin
-a----         8/24/2022   1:54 PM            460 vcm_sig_linux_pkey.pem
-a----         8/24/2022   2:07 PM          16528 Zip.exe

then these files will be deleted automatically.

```
