mkisofs -output fazcloudinitdata.iso -volid cidata -joliet -rock  user-data meta-data
cp fazcloudinitdata.iso ./../windows/
./../windows/s3cp.sh fazcloudinitdata.iso

