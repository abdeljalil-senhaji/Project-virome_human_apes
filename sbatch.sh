#!/bin/bash

#SBATCH --job-name=data_incomplet
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/data_incompl/new_slurm_analysis.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/data_incompl/new_slurm_analysis.%N.%j.err
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


bash /shared/projects/virome_human_apes/virome_analysis/script_analysis/lanchDedupTrimming.sh /shared/projects/virome_human_apes/virome_analysis/data_incompl

echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)

