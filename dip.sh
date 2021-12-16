kubectl get deployment | grep -v  NAME > dep.txt
DEPLOYMENT=`cat dep.txt | awk '{print $1}'`
echo "$DEPLOYMENT"
rm -rf dep.txt
