how to upgrade faz version 

1. deploy faz vm with it's own pvc.
2. after bootup, config add fortigate device, create new report template etc., backup config
3. deploy new version of faz VM with it's own PVC with it's own slb
4. do not add this new faz VM to previousl loadbalancer group (by not config label for lb)
kubevirt.io/domain: faz
5. import config on this new faz VM. 
6. update new faz VM label for new previous loadbaluser
7. remove old faz vm and new loadblancer

(note: each faz need a license)


