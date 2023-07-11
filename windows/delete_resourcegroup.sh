[[ -z $1 ]] || LOCATION="eastasia" && LOCATION=$1
#LOCATION="eastasia"
RESOURCEGROUP="wandyaks"
az group delete -g $RESOURCEGROUP --yes
