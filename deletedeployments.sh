#!/bin/bash
kubectl get deployment | grep -v  NAME > dep1.txt

DEPLOYMENTS=`cat dep1.txt | awk '{print $1}'`
for i in $DEPLOYMENTS
do
echo "$i"

rm -rf dep1.txt

kubectl delete deployments "$i"
done
