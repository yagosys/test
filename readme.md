- Prepare use az shell 
-- install tools
use below script to insall netcat (nc), in the script, this tool is used to check whether peer is live. if you already have nc installed. skip this.
```
install_tools_for_azshell.sh
```

- Prepare for demo 


-- prepare license


you need have 2 FMG and 2 FAZ license for demo
please these license under $HOME/ 
andy [ ~/test ]$ ls -l $HOME/*.lic
-rw-r--r-- 1 andy andy 9236 Jun  6 10:57 /home/andy/xxx.lic
-rw-r--r-- 1 andy andy 9171 Jun  8 00:09 /home/andy/xxx.lic
-rw-r--r-- 1 andy andy 9171 Jun  8 00:09 /home/andy/xxx.lic

-- install aks cluster

create aks with one windows node, and one linux node. 

```
cd windows
./create_aks_and_ubuntu_win_node.sh
```

after deployment, your existing kubectl config will be overwritten. 

- demo use case

-- FMG container

-- use case 1
```
cd deploy_fmg_container_with_slb
use_case_1_clean_boot_fmg.sh
``
result

```
andy [ ~/test/deploy_fmg_container_with_slb ]$ cat usecase1_2023-06-08.txt 
fortimanager bootup record
boot at Thu Jun 8 03:46:23 AM UTC 2023
service ready at Thu Jun 8 03:50:48 AM UTC 2023
```
-- use case 2 
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
-- use case 3

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

-- use case 4 

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

-- use case 5 
normal kill pod, new pod wil be generated with different ip , and this pod will be remvoed from load balacner until it pass readiness check.

```
kubectl delete pod fortimanager-deployment-b456747b5-6ztw2 
```

- FMG VM as container 

-- prepare cloudinit disk 
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

-- install kubevirt
```
cd windows
./install_kubevirt.sh 

```
-- use case 1 
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

-- use case 2
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










