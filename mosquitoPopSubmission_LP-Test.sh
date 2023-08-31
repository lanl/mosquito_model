#!/bin/bash
#SBATCH -A y23_cimmid
#SBATCH -J test.%A_%a.log
#SBATCH -N 1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH -t 03:00:00
#SBATCH --array=0-80

module load python

export PATH="/usr/projects/cimmid/miniconda3/bin:$PATH"
conda config --prepend envs_dirs "/usr/projects/cimmid/miniconda3/envs"
conda init bash
source ~/.bashrc
conda activate mosq-R
conda env list

module load cray-R

# Loop through each hydropop unit in slurm array ID
while read p; do
    # echo "$p"
    bash run_mosq_toy.sh config/mosq_config_integration_default_chicoma.yaml "$p"
done < slurmArrayMapping/$SLURM_ARRAY_TASK_ID.txt

echo "Done"
