#!/bin/bash

NODE=$(kubectl top nodes)
echo "$NODE"
##Getting Node information######################
kubectl get nodes | grep -v NAME | grep -v control-plane,master | awk '{ print $1}' > tmp1.txt
NODES1=`cat tmp1.txt | awk '{print $1}'`
for i in $NODES1
do
#Node utlization details
kubectl top nodes $i | grep -v  NAME | awk '{ print $1}' > tmp.txt
NODES=`cat tmp.txt | awk '{print $1}'`
#for i in $NODES
#do
CPU_USAGE=`cat tmp.txt | awk '{print $3}' | tr -d "\%"`
MEM_USAGE=`cat tmp.txt | awk '{print $5}' | tr -d "\%"`
if [[ $CPU_USAGE -gt 60  ||  $MEM_USAGE -lt 35 ]]
then
echo  "$i"
kubectl label nodes "$i" on-master-
#kubectl label nodes "$i" on-master="true"

kubectl top nodes $i | grep -v  NAME > tmpx.txt
x=`cat tmpx.txt | awk '{print $1}'`
for z in $x
do
CPU_USAGE=`cat tmpx.txt | grep $i | awk '{print $3}' | tr -d "\%"`
MEM_USAGE=`cat tmpx.txt | grep $i | awk '{print $5}' | tr -d "\%"`
if [[ $CPU_USAGE -gt 60  ||  $MEM_USAGE -gt 35 ]]
then
kubectl label nodes "$z" on-master="true"
fi
done
rm -rf tmpx.txt
#Deployments
kubectl get deployment | grep -v  NAME > dep.txt
DEPLOYMENT=`cat dep.txt | awk '{print $1}'`
echo "$DEPLOYMENT"
rm -rf dep.txt
kubectl rollout restart deployment "$DEPLOYMENT"
PODS=$(kubectl get pods -o wide)
echo "$PODS"
else
#echo "$i"
kubectl label nodes "$i" on-master=true
cat <<EOF | kubectl apply -f -

apiVersion: apps/v1
kind: Deployment
metadata:
  name: streamer-v4-deployment
  labels:
    app: streamer-v4
spec:
  replicas: 2
  selector:
    matchLabels:
      app: streamer-v4
  template:
    metadata:
      labels:
        app: streamer-v4
    spec:
      containers:
      - name: streamer-v4
        image: nginx
        ports:
        - containerPort: 8880
      nodeSelector:
        on-master: "true"

EOF

fi
done
rm tmp.txt tmp1.txt
