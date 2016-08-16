#!/bin/bash

NODE=$1

POOLS=`clusto info $1 | grep Parents | cut -b 22- | tr ',' '\n' | sed 's/^ //' | egrep -v "foo_user*" | egrep -v "carp*"`

for POOL in $POOLS
do
    clusto pool remove $POOL $NODE 2> /dev/null
done
