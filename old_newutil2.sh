#!/bin/bash


kubectl top nodes | grep -v  NAME > tmp.txt
NODES=`cat tmp.txt | awk '{print $1}'`
for i in $NODES
do
CPU_USAGE=`cat tmp.txt | grep $i | awk '{print $3}' | tr -d "\%"`
MEM_USAGE=`cat tmp.txt | grep $i | awk '{print $5}' | tr -d "\%"`
if [[ $CPU_USAGE -gt 60  ||  $MEM_USAGE -lt 30 ]]
then
echo  "$i node have high usage"

else

echo "$i node have low usage"

fi

done

rm tmp.txt
