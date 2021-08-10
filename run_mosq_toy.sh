#!/bin/sh

# Takes one argument:
# Path to config file

if [ "$#" -lt 1 ] || ! [ -f "$1" ] ; then
    echo "ERROR!! Must specify configuration file path as an argument."
fi


CONFIG_FILE=$1

Rscript toy_model_main.R $CONFIG_FILE
