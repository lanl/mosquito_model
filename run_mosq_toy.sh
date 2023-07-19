#!/bin/sh

# Takes two arguments:
# Path to config file

if [ "$1" == "" ]; then
    echo "Error: Must specify both configuration file path and location id"
    exit 1
fi

if [ "$2" == "" ]; then
    echo "Error: Must specify both configuration file path and location id"
    exit 1
fi



CONFIG_FILE=$1
LOCATION_ID=$2

Rscript pbm-hu-main.R -c $CONFIG_FILE -m culex -l $LOCATION_ID
