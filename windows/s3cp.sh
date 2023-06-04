#!/bin/bash -x

filename=$1
echo  $filename
bucket=$(aws s3 ls | grep wandy  | cut -d ' ' -f 3)
aws s3 cp $filename s3://$bucket
aws s3api put-object-acl --bucket $bucket --key $filename --acl public-read
#wget  https://$bucket.s3.ap-southeast-1.amazonaws.com/$filename
