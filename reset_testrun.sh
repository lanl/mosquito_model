#!/bin/sh

rm mosquitoPopSubmission_testSlurm.sh slurm-* slurmArrayMapping/*
python batchScriptSetup.py -n testSlurm -m hpus_testSlurm.txt
