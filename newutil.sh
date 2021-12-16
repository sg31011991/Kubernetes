#!/bin/bash

NODE=$(kubectl top nodes)
echo "$NODE"         
         
kubectl top nodes | grep -v  NAME > tmp.txt         
NODES=`cat tmp.txt | awk '{print $1}'`         
for i in $NODES         
do
CPU_USAGE=`cat tmp.txt | grep $i | awk '{print $3}' | tr -d "\%"`
MEM_USAGE=`cat tmp.txt | grep $i | awk '{print $5}' | tr -d "\%"`
if [[ $CPU_USAGE -gt 60  ||  $MEM_USAGE -gt 60 ]]         
then
#echo  "$i high"
kubectl label nodes "$i" on-master-
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
rm tmp.txt
