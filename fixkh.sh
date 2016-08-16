#!/bin/bash
line=$1
# echo $line #debug
vim /Users/daveryack/.ssh/known_hosts -c ":$line" -c "normal dd" -c ":wq"
