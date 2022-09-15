#!/usr/bin/env bash
##############################################################################
# show how much space,etc we have at this moment
##############################################################################
echo ">>>> space available and used <<<<<<"
echo "directory: `pwd`"
echo
echo ">>>> files and their sizes <<<<<<"
ls -ltrh
echo
echo ">>>> system space utilization <<<<<<"
df -h

