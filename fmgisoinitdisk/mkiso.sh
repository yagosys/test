isoname="fmgcloudinitdata.iso"
mkisofs -output $isoname -volid cidata -joliet -rock  user-data meta-data
cp $isoname ./../windows/
./../windows/s3cp.sh $isoname

