[[ -z $1 ]] && LOCATION="westus2" || LOCATION=$1
url="https://fgtvmtest1.$LOCATION.cloudapp.azure.com:18443"
echo $url
curl -k $url
url="https://fgtvmtest1.$LOCATION.cloudapp.azure.com:19443"
echo $url
curl -k $url
