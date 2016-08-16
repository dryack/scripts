#!/bin/bash

TO_PXE=()

# check for required arguments; display usage if empty
if [ -z "$1" ]
then
    echo "Usage:  pxe_machines [node1] {node2.. nodeN}"
    echo "ex:  pxe_machines s0999 s0666"
    exit 1
fi

until [ -z "$1" ]
do
    TO_PXE+=(`clusto attr show $1 2>/dev/null | grep drac_ip | awk '{ print $4}'`)
    if [ -z $TO_PXE ]
    then
        echo "ERROR:  $1 does not appear to be a valid server name"
        exit 17
    fi
    shift
done

#echo ${TO_PXE[@]}  # debug

for NODE in "${TO_PXE[@]}"
do
    if echo "$NODE" | egrep -v '^10.128.[5|6].[0-9][0-9]*$' > /dev/null
    then
        echo "ERROR: $NODE does not appear to be a valid company idrac IP"
        exit 17
    fi
    ipmitool -U root -P foo_pass -I lanplus -H $NODE chassis bootdev pxe
    ipmitool -U root -P foo_pass -I lanplus -H $NODE chassis power reset
    if [ $? > 0 ]
    then
        echo "Node powered down, unable to reset, starting node."
        ipmitool -U root -P calvin -I lanplus -H $NODE chassis power on
    fi
    #echo "ipmitool -U root -P foo_pass -I lanplus -H $NODE chassis bootdev pxe" #debug
    #echo "ipmitool -U root -P foo_pass -I lanplus -H $NODE chassis power reset" #debug
done

exit 0
