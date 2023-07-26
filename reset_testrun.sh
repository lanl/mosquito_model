#!/bin/sh

rm slurm-*
python batchScriptSetup.py -n testSlurm -m hpus_testSlurm.txt
