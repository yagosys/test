- Prepare use az shell 

- install tools
use below script to insall netcat (nc), in the script, this tool is used to check whether peer is live. if you already have nc installed. skip this.

```
install_tools_for_azshell.sh

```

- Prepare for demo 

- prepare license


you need have 2 FMG and 2 FAZ license for demo
```
please these license under $HOME/ 
andy [ ~/test ]$ ls -l $HOME/*.lic
-rw-r--r-- 1 andy andy 9236 Jun  6 10:57 /home/andy/xxx.lic
-rw-r--r-- 1 andy andy 9171 Jun  8 00:09 /home/andy/xxx.lic
-rw-r--r-- 1 andy andy 9171 Jun  8 00:09 /home/andy/xxx.lic

```
- install aks cluster

create aks with one windows node, and one linux node. 

```
cd windows
./create_aks_and_ubuntu_win_node.sh
```

after deployment, your existing kubectl config will be overwritten. 

- demo use case

- FMG container

- use case 1

```
cd deploy_fmg_container_with_slb
use_case_1_clean_boot_fmg.sh

```
result

```
andy [ ~/test/deploy_fmg_container_with_slb ]$ cat usecase1_2023-06-08.txt 
fortimanager bootup record
boot at Thu Jun 8 03:46:23 AM UTC 2023
service ready at Thu Jun 8 03:50:48 AM UTC 2023
```
- use case 2 

```
use_case_2_apply_license_and_enable_api.sh
```
result
```
andy [ ~/test/deploy_fmg_container_with_slb ]$ cat usecase_2_2023-06-08.txt 
license applied
 user admin has password Welcome.123
use cli to get system status
FMG-DOCKER # Platform Type                   : FMG-DOCKER
Platform Full Name              : FortiManager-DOCKER
Version                         : v7.0.7-build0419 230320 (GA)
Serial Number                   : FMG-VMTM23008863
BIOS version                    : 04000002
Hostname                        : FMG-DOCKER
Max Number of Admin Domains     : 10000
Max Number of Device Groups     : 10000
Admin Domain Configuration      : Disabled
FIPS Mode                       : Disabled
HA Mode                         : Stand Alone
Branch Point                    : 0419
Release Version Information     : GA
Current Time                    : Wed Jun 07 21:07:37 PDT 2023
Daylight Time Saving            : Yes
Time Zone                       : (GMT-8:00) Pacific Time (US & Canada).
x86-64 Applications             : Yes
Disk Usage                      : Free 5.88GB, Total 6.80GB
License Status                  : Valid

FMG-DOCKER # start enable json rpc api for fortimanager-deployment-554bd468fb-zj6kp
admin user json rpc api enable

```
- use case 3

```
./use_case_3_rollupgrade.sh

```
result

```
andy [ ~/test/deploy_fmg_container_with_slb ]$ cat usecase_3_2023-06-08.txt 
get device list from current version of fmg
DNHv6ApecLqjUaGIIw6vyG1RujRw5LnP5JPSPbkJMptPbHIzvWwCYSkJqX/L6CibVZzXaT00S41oPj5CZFERFw==
{ "id": 1, "result": [ { "status": { "code": -3, "message": "Object does not exist" }, "url": "\/dvmdb\/device\/fgt" } ] }upgraded to 7.2.2 done
DNHv6ApecLrAtHgEHJoxpvd4PGb6iojb3ki34L7RX2BUr8gWWkSq/Ps6PL4IWWYa+qRK47s+XxiQlPDGkfqubA==
{ "id": 1, "result": [ { "status": { "code": -3, "message": "Object does not exist" }, "url": "\/dvmdb\/device\/fgt" } ] }diag cdb upgrade summary
FMG-DOCKER # 
   ==== New configuration database initiated ====
2023-06-07 21:41:20     v7.0.7-build0419 230320 (GA)
2023-06-07 21:49:55     v7.2.2-build1334 230201 (GA)

FMG-DOCKER # FMG-DOCKER # diag cdb  upgrade log
FMG-DOCKER # 
   ==== New configuration database initiated ====
2023-06-07 21:41:20     v7.0.7-build0419 230320 (GA)
2023-06-07 21:49:55     v7.2.2-build1334 230201 (GA)
2023-06-07 21:49:55             Success         Upgrade rtm db
2023-06-07 21:49:56             Success         Unify template urls
2023-06-07 21:49:56             Success         Upgrade meta variables
2023-06-07 21:49:57             Success         Default configs for SD-WAN template
2023-06-07 21:49:57             Success         Upgrade Management ID to UUID
2023-06-07 21:49:57             Success         Upgrade IPS Templates
2023-06-07 21:49:58             Success         Add default cli templates
2023-06-07 21:49:58             Success         Pre-configured route maps for SD-WAN overlay templates
2023-06-07 21:49:58             Success         Upgrade endpoint-control fctems
2023-06-07 21:50:00             Success         Add default addresses and address group for the RFC1918 space
2023-06-07 21:50:00             Success         Add global default entries to double-scoped objects for vdom enabled devices

FMG-DOCKER # FMG-DOCKER # diag cdb upgrade check +all
```

- use case 4 

normal scale out

```
kubectl scale deployment fortimanager-deployment --replicas=2
```
result

```
kubectl rollout status deployment fortimanager-deployment
Waiting for deployment "fortimanager-deployment" rollout to finish: 1 of 2 updated replicas are available...
deployment "fortimanager-deployment" successfully rolled out
kubectl get ep fmgcontainerhttps
NAME                ENDPOINTS                                                         AGE
fmgcontainerhttps   10.224.0.73:8793,10.224.0.82:8793,10.224.0.73:8889 + 21 more...   20m
```

- use case 5 
normal kill pod, new pod wil be generated with different ip , and this pod will be remvoed from load balacner until it pass readiness check.

```
kubectl delete pod fortimanager-deployment-b456747b5-6ztw2 
```

- FMG VM as container 

- prepare cloudinit disk 
modify meta-data and user-data  content with your own key
use mkiso.sh to create iso
copy iso to your own s3 directory for fetch. 

```
andy [ ~/test ]$ ls -l fazisoinitdisk/
total 12
-rw-r--r-- 1 andy andy   48 Jun  8 00:00 meta-data
-rwxr-xr-x 1 andy andy  167 Jun  8 00:00 mkiso.sh
-rw-r--r-- 1 andy andy 1009 Jun  8 00:00 user-data

andy [ ~/test ]$ ls -l fmgisoinitdisk
total 80
-rw-r--r-- 1 andy andy     48 Jun  8 00:28 meta-data
-rwxr-xr-x 1 andy andy    162 Jun  8 00:28 mkiso.sh
-rw-r--r-- 1 andy andy   1009 Jun  8 00:28 user-data
andy [ ~/test ]$ 
```

- install kubevirt

```
cd windows
./install_kubevirt.sh 

```
- use case 1 
```
cd deploy_fmg_with_slb
./use_case_1_clean_boot_fmg.sh
```

result 
```
andy [ ~/test/deploy_fmg_with_slb ]$ cat usecase1_fmg_boot_time_2023-06-08.txt 
fmg bootup record
boot at Thu Jun 8 05:18:38 AM UTC 2023
service ready at Thu Jun 8 05:24:53 AM UTC 2023
```

- use case 2
```
cd deploy_fmg_with_slb
./use_case_2_apply_license_and_enable_api.sh
```
result
```
andy [ ~/test/deploy_fmg_with_slb ]$ cat usecase_2_2023-06-08.txt 
license applied
 user admin has password Welcome.123
use cli to get system status
kvmfmg # Platform Type                   : FMG-VM64-IBM
Platform Full Name              : FortiManager-VM64-IBM
Version                         : v7.0.7-build0419 230320 (GA)
Serial Number                   : FMG-VMTM23008454
BIOS version                    : 04000002
Hostname                        : kvmfmg
Max Number of Admin Domains     : 10000
Max Number of Device Groups     : 10000
Admin Domain Configuration      : Disabled
FIPS Mode                       : Disabled
HA Mode                         : Stand Alone
Branch Point                    : 0419
Release Version Information     : GA
Current Time                    : Wed Jun 07 22:39:56 PDT 2023
Daylight Time Saving            : Yes
Time Zone                       : (GMT-8:00) Pacific Time (US & Canada).
x86-64 Applications             : Yes
Disk Usage                      : Free 3.59GB, Total 6.61GB
File System                     : Ext4
License Status                  : Valid
```

- FAZ container

- use case 1  bootup time

measure from boot to ready for service

```
cd  deploy_faz_container_with_slb
./use_case_1_clean_boot_faz.sh
```

result

```
andy [ ~/test/deploy_faz_container_with_slb ]$ cat usercase1_faz_boot_time_2023-06-08.txt
faz bootup record
boot at Thu Jun 8 09:52:16 PM UTC 2023
service ready at Thu Jun 8 09:56:41 PM UTC 2023
```

- use case 2 apply license

apply license via kubectl command 

```
./use_case_2_apply_license_and_enable_api.sh

```

result
```
license applied
 user admin has password Welcome.123
use cli to get system status
FAZ-DOCKER # Platform Type                   : FAZ-DOCKER
Platform Full Name              : FortiAnalyzer-DOCKER
Version                         : v7.0.7-build0419 230320 (GA)
Serial Number                   : FAZ-VMTM23008295
BIOS version                    : 04000002
Hostname                        : FAZ-DOCKER
Max Number of Admin Domains     : 1200
Admin Domain Configuration      : Disabled
FIPS Mode                       : Disabled
HA Mode                         : Stand Alone
Branch Point                    : 0419
Release Version Information     : GA
Current Time                    : Thu Jun 08 15:07:25 PDT 2023
Daylight Time Saving            : Yes
Time Zone                       : (GMT-8:00) Pacific Time (US & Canada).
x86-64 Applications             : Yes
Disk Usage                      : Free 5.65GB, Total 6.80GB
License Status                  : Valid

FAZ-DOCKER # start enable json rpc api for fortianalyzer-deployment-794dd855f9-xlsg6
admin user json rpc api enable
```


- use case 3 upgrade

upgrade from versio 7.0.7 to 7.2.2 

```
./use_case_3_rollupgrade.sh
```
result
```
andy [ ~/test/deploy_faz_container_with_slb ]$ cat usercase_3_2023-06-08.txt
get device list from current version of faz
WfwRnC9fbyffgzmbj/KYnG3CCcX7BYNdU3Zq1z1Ux/iubJLyBtnFzXFVxWmfTnkjrHOcSzOsR0S7mMN3rR6OGP34bTunemc9
{ "id": 1, "result": [ { "status": { "code": -3, "message": "Object does not exist" }, "url": "\/dvmdb\/device\/fgt" } ] }upgraded to 7.2.2 done
WfwRnC9fbyfFqrpHujuoZlf33DEkVU6iFmRy6MiOCPe4sk+GWoW1es8imbbS0j4i2vFedUw+tetvnSfMFUbp8gosL94p2q2m
{ "id": 1, "result": [ { "status": { "code": -3, "message": "Object does not exist" }, "url": "\/dvmdb\/device\/fgt" } ] }fortianalyzer-deployment-7b47b55c86-qj2qz
diag cdb upgrade summary
diag cdb upgrade summary
FAZ-DOCKER # FAZ-DOCKER # 

   ==== New configuration database initiated ====
2023-06-08 15:02:25     v7.0.7-build0419 230320 (GA)
2023-06-08 15:12:59     v7.2.2-build1334 230201 (GA)

FAZ-DOCKER # FAZ-DOCKER #    ==== New configuration database initiated ====
2023-06-08 15:02:25     v7.0.7-build0419 230320 (GA)
2023-06-08 15:12:59     v7.2.2-build1334 230201 (GA)

FAZ-DOCKER # FAZ-DOCKER # diag cdb  upgrade log
diag cdb  upgrade log
FAZ-DOCKER # 
FAZ-DOCKER # 
   ==== New configuration database initiated ====
2023-06-08 15:02:25     v7.0.7-build0419 230320 (GA)
2023-06-08 15:12:59     v7.2.2-build1334 230201 (GA)
2023-06-08 15:12:59             Success         Upgrade rtm db
2023-06-08 15:12:59             Success         Upgrade Management ID to UUID
   ==== New configuration database initiated ====
2023-06-08 15:02:25     v7.0.7-build0419 230320 (GA)
2023-06-08 15:12:59     v7.2.2-build1334 230201 (GA)
2023-06-08 15:12:59             Success         Upgrade rtm db
2023-06-08 15:12:59             Success         Upgrade Management ID to UUID

FAZ-DOCKER # FAZ-DOCKER # 
FAZ-DOCKER # FAZ-DOCKER # diag cdb upgrade check +all
diag cdb upgrade check +all
FAZ-DOCKER # FAZ-DOCKER # 
Checking: Resync and add any missing vdoms from device database to DVM database
No error found.

FAZ-DOCKER # FAZ-DOCKER # 
Checking: Resync and add any missing vdoms from device database to DVM database
No error found.

```

- use case 4 scale out

scale deployment from one pod to 2 pod

```
use_case_4_scaleout.sh
```
result
```
andy [ ~/test/deploy_faz_container_with_slb ]$ cat usecase_4_2023-06-08.txt
start use kubectl scale deployment fortianalyer-deployment --replicas=2 to scale out
Ping successful, breaking loop
HTTP/1.1 200 OK
Date: Thu, 08 Jun 2023 22:21:00 GMT
X-Frame-Options: SAMEORIGIN
Last-Modified: Thu, 02 Feb 2023 05:11:02 GMT
ETag: "59-5f3b09750c580"
Accept-Ranges: bytes
Content-Length: 89
Vary: Accept-Encoding
Strict-Transport-Security: max-age=63072000
X-UA-Compatible: IE=Edge
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Security-Policy: default-src 'none'; script-src 'sha256-PoMasaLzN2PWG4ByL9UkAULQUkNpN9b1gLHfuQHsYhM=';
Content-Type: text/html

NAME                ENDPOINTS                                                       AGE
fazcontainerhttps   10.224.0.68:8793,10.224.0.68:8889,10.224.0.68:161 + 9 more...   22m
kubernetes          52.246.140.183:443                                              39m
NAME                                        READY   STATUS    RESTARTS   AGE
fortianalyzer-deployment-7b47b55c86-qj2qz   1/1     Running   0          12m
start use kubectl scale deployment fortianalyzer-deployment --replicas=2 to scale out
deployment.apps/fortianalyzer-deployment scaled
Ping successful, breaking loop
HTTP/1.1 200 OK
Date: Thu, 08 Jun 2023 22:26:27 GMT
X-Frame-Options: SAMEORIGIN
Last-Modified: Thu, 02 Feb 2023 05:11:02 GMT
ETag: "59-5f3b09750c580"
Accept-Ranges: bytes
Content-Length: 89
Vary: Accept-Encoding
Strict-Transport-Security: max-age=63072000
X-UA-Compatible: IE=Edge
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Security-Policy: default-src 'none'; script-src 'sha256-PoMasaLzN2PWG4ByL9UkAULQUkNpN9b1gLHfuQHsYhM=';
Content-Type: text/html

NAME                ENDPOINTS                                                         AGE
fazcontainerhttps   10.224.0.68:8793,10.224.0.76:8793,10.224.0.68:8889 + 21 more...   27m
kubernetes          52.246.140.183:443                                                45m
NAME                                        READY   STATUS    RESTARTS   AGE
fortianalyzer-deployment-7b47b55c86-qj2qz   1/1     Running   0          17m
fortianalyzer-deployment-7b47b55c86-tvdxx   1/1     Running   0          3m13s
```

- use case 5 HA

kill one of POD

```
use_case_5_ha_by_delete_pod.sh
```
result 
```
andy [ ~/test/deploy_faz_container_with_slb ]$ cat usecase_5_2023-06-08.txt
start use kubectl scale deployment fortianalyer-deployment --replicas=2 to scale out
deployment.apps/fortianalyzer-deployment scaled
Ping successful, breaking loop
HTTP/1.1 200 OK
NAME                ENDPOINTS                                                         AGE
fazcontainerhttps   10.224.0.68:8793,10.224.0.76:8793,10.224.0.68:8889 + 21 more...   70m
kubernetes          52.246.140.183:443                                                87m
NAME                                        READY   STATUS    RESTARTS   AGE
fortianalyzer-deployment-7b47b55c86-kcdcb   1/1     Running   0          6m18s
fortianalyzer-deployment-7b47b55c86-tvdxx   1/1     Running   0          45m
\n

 delete one of the pod fortianalyzer-deployment-7b47b55c86-kcdcb

\n
pod "fortianalyzer-deployment-7b47b55c86-kcdcb" deleted
Public IP assigned: 20.187.160.210
Ping successful, breaking loop
HTTP/1.1 200 OK
NAME                                        READY   STATUS    RESTARTS   AGE
fortianalyzer-deployment-7b47b55c86-fwhpz   0/1     Running   0          37s
fortianalyzer-deployment-7b47b55c86-tvdxx   1/1     Running   0          46m
NAME                ENDPOINTS                                                       AGE
fazcontainerhttps   10.224.0.76:8793,10.224.0.76:8889,10.224.0.76:161 + 9 more...   71m
kubernetes          52.246.140.183:443                                              88m
NAME                                        READY   STATUS    RESTARTS   AGE
fortianalyzer-deployment-7b47b55c86-fwhpz   0/1     Running   0          38s
new pod come back
NAME                                        READY   STATUS    RESTARTS   AGE
fortianalyzer-deployment-7b47b55c86-fwhpz   1/1     Running   0          3m15s
fortianalyzer-deployment-7b47b55c86-tvdxx   1/1     Running   0          49m
NAME                ENDPOINTS                                                         AGE
fazcontainerhttps   10.224.0.76:8793,10.224.0.84:8793,10.224.0.76:8889 + 21 more...   73m
kubernetes          52.246.140.183:443      
```

- FAZ VM container

*
miminal memory required for luanch FAZ VM is **8G** Memory and **4** vCPU. 
*


- prepare cloudinit disk
modify meta-data and user-data  content with your own key
use mkiso.sh to create iso
copy iso to your own s3 directory for fetch.

above can be skipped if already done. 

```
andy [ ~/test ]$ ls -l fazisoinitdisk/
total 12
-rw-r--r-- 1 andy andy   48 Jun  8 00:00 meta-data
-rwxr-xr-x 1 andy andy  167 Jun  8 00:00 mkiso.sh
-rw-r--r-- 1 andy andy 1009 Jun  8 00:00 user-data

andy [ ~/test ]$ ls -l fmgisoinitdisk
total 80
-rw-r--r-- 1 andy andy     48 Jun  8 00:28 meta-data
-rwxr-xr-x 1 andy andy    162 Jun  8 00:28 mkiso.sh
-rw-r--r-- 1 andy andy   1009 Jun  8 00:28 user-data
andy [ ~/test ]$
```

- install kubevirt
this can be skipped if kubevirt already installed 
```
cd windows
./install_kubevirt.sh

```
- use case 1
```
cd deploy_faz_with_slb
./use_case_1_clean_boot_faz.sh
```
result
```
andy [ ~/test/deploy_faz_with_slb ]$ cat usecase1_faz_boot_time_2023-06-08.txt
faz bootup record
boot at Thu Jun 8 11:21:32 PM UTC 2023
service ready at Thu Jun 8 11:28:17 PM UTC 2023
```

- use case 2 
apply license and enable api access

```
./use_case_2_apply_license_and_enable_api.sh
```
result 
```
andy [ ~/test/deploy_faz_with_slb ]$ cat usecase_2_2023-06-08.txt
license applied
 user admin has password Welcome.123
use cli to get system status
fmg-boot-strap # Platform Type                   : FAZVM64-IBM
Platform Full Name              : FortiAnalyzer-VM64-IBM
Version                         : v7.0.7-build0419 230320 (GA)
Serial Number                   : FAZ-VMTM23008181
BIOS version                    : 04000002
Hostname                        : fmg-boot-strap
Max Number of Admin Domains     : 2
Admin Domain Configuration      : Disabled
FIPS Mode                       : Disabled
HA Mode                         : Stand Alone
Branch Point                    : 0419
Release Version Information     : GA
Current Time                    : Thu Jun 08 16:43:07 PDT 2023
Daylight Time Saving            : Yes
Time Zone                       : (GMT-8:00) Pacific Time (US & Canada).
x86-64 Applications             : Yes
Disk Usage                      : Free 3.36GB, Total 6.61GB
File System                     : Ext4
License Status                  : Valid

```
- use case 3 

upgrade image via faz cli 

```
fmg-boot-strap # execute restore image scp /root/FAZ_VM64_IBM-v7.2.2-build1334-FORTINET.out "deletedip" "deleteduser" "deletedpassword"
andy [ ~/test/deploy_faz_with_slb ]$ k get pod
NAME                      READY   STATUS    RESTARTS   AGE
virt-launcher-faz-tf56q   0/1     Running   0          42s
andy [ ~/test/deploy_faz_with_slb ]$ virtctl console faz
Successfully connected to faz console. The escape sequence is ^]
                                                                Serial number:FAZ-VMTM23008181

Upgrading sample reports...Done.

Initialize file systems... 
Old version: v7.0.7-build0419 branchpt0419 230320 (GA)
New version: v7.2.2-build1334 branchpt1334 230201 (GA)
Upgrade database ... adom[18] dev[0] global[1]

Upgrading: Upgrade rtm db
        Total 19 databases...
...upgrading progress is 5%, estimated remain time is 0s. (1/19 step1/2)

Upgrading: Upgrade Management ID to UUID
Database upgrade finished, using 0m4s
Upgrading report config from version:7, patch:7, branch point:419
  Exporting existing config... (step 1/4)
    Exporting existing config took 1.350 seconds.
  Initializing default config... (step 2/4)
    Initializing default config took 9.428 seconds.
  Upgrading existing config... (step 3/4)
    Upgrading V7.0.3->V7.2.0...
    Upgrading V7.2.0->V7.2.1...
    Upgrading V7.2.1->V7.2.2...
    Upgrading existing config took 1.545 seconds.
  Importing upgraded config... (step 4/4)
    Importing upgraded config took 3.171 seconds.
Upgrading report config completed, took 15.951 seconds.


Please login with username=admin and password=[instance-id]
 (Press 'a' to accept):Generate SIEM config file.

0:0 2000/1/1
ioc_bl_logs_tbls_trim() drop 0 tables OK!



```
check result
```
fmg-boot-strap # diagnose cdb upgrade  summary 

   ==== New configuration database initiated ====
2023-06-08 16:36:12     v7.0.7-build0419 230320 (GA)
2023-06-08 18:16:09     v7.2.2-build1334 230201 (GA)

fmg-boot-strap # diagnose cdb upgrade log 

   ==== New configuration database initiated ====
2023-06-08 16:36:12     v7.0.7-build0419 230320 (GA)
2023-06-08 18:16:09     v7.2.2-build1334 230201 (GA)
2023-06-08 18:16:09             Success         Upgrade rtm db
2023-06-08 18:16:10             Success         Upgrade Management ID to UUID

fmg-boot-strap # diagnose cdb upgrade check +all

Checking: Resync and add any missing vdoms from device database to DVM database
No error found.

fmg-boot-strap # 
```








