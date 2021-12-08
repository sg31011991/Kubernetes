#!/bin/bash
#
# Monitor overall Kubernetes cluster utilization and capacity.
#
# Original source:
# https://github.com/kubernetes/kubernetes/issues/17512#issuecomment-367212930
#
# Tested with:

#set -ax

KUBECTL="kubectl"
NODES=$($KUBECTL get nodes --no-headers -o custom-columns=NAME:.metadata.name)

function usage() {
  local node_count=0
  local total_percent_cpu=0
  local total_percent_mem=0
  local readonly nodes=$@

  for n in $nodes; do
    local requests=$($KUBECTL describe node $n | grep -A3 -E "\\s\sRequests" | tail -n2)
    local percent_cpu=$(echo $requests | awk -F "[()%]" '{print $2}')
    local percent_mem=$(echo $requests | awk -F "[()%]" '{print $8}')
    echo "$n: ${percent_cpu} CPU, ${percent_mem} memory"

    node_count=$((node_count + 1))
    total_percent_cpu=$((total_percent_cpu + percent_cpu))
    total_percent_mem=$((total_percent_mem + percent_mem))
  done

  local readonly avg_percent_cpu=$((total_percent_cpu / node_count))
  local readonly avg_percent_mem=$((total_percent_mem / node_count))

  echo "Average usage: ${avg_percent_cpu}% CPU, ${avg_percent_mem}% memory."
}
kubectl describe nodes | awk '/Allocated resources/,/Events/' | head -n-1

usage $NODES
if [[ ${percent_cpu} -gt 60 || ${percent_mem}  -gt 60 ]];

then

echo "reschedule the POD "

else

#echo "Size is less than 60"




cat <<EOF | kubectl apply -f -

apiVersion: v1
kind: Pod
metadata:
  name: pod21
spec:
  containers:
        - name: con1
          image: nginx
          imagePullPolicy: Never
  nodeSelector:
          size: large

EOF
fi
