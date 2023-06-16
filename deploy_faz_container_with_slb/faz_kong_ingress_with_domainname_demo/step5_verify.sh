fazdnslabel="fazweb"
location="eastasia"
fazdns="$fazdnslabel.$location.cloudapp.azure.com"
echo $fazdns
curl -k  $fazdns
