cat "upgradestart at $(date)" > upgraderesult.txt
kubectl set image deployment/fortianalyzer-deployment fortianalyzer=fortinet/fortianalyzer:7.2.2
./ping.sh
