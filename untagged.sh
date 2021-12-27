#!/bin/bash
kubectl get nodes | grep -v NAME | grep -v control-plane,master | awk '{ print $1}' > tmp.txt
NODES=`cat tmp.txt | awk '{print $1}'`
for i in $NODES
do
echo  "$i"
kubectl label nodes "$i" on-master-
done

KUBECTL="kubectl"

NODE=$($KUBECTL get nodes --show-labels)
echo "$NODE"
