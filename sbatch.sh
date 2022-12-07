#!/bin/bash

#SBATCH --job-name=metagenomic_analysis
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o ../new_slurm_analysis.%N.%j.out
#SBATCH -e ../new_slurm_analysis.%N.%j.err
#SBATCH -A virome_human_apes



# Useful information to print
echo '########################################'
echo 'Date:' $(date --iso-8601=seconds)
echo 'User:' $USER
echo 'Host:' $HOSTNAME
echo 'Job Name:' $SLURM_JOB_NAME
echo 'Job Id:' $SLURM_JOB_ID
echo 'Directory:' $(pwd)
echo '########################################'


##script




echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)

