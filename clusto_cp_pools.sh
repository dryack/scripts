#!/bin/bash

FROM=$1
TO=$2
POOLS=`clusto info $FROM | grep Parents | cut -b 22- | tr ',' '\n' | sed 's/^ //' | grep -v prod | egrep -v "^foo_user*" | egrep -v "^carp*"`

for ORIGIN in $POOLS
do
    clusto pool insert $ORIGIN $TO 2> /dev/null
#    echo "clusto pool insert $ORIGIN $TO" #debug
done
