#!/bin/bash

#SBATCH --job-name=metaspades
#SBATCH -n 4
#SBATCH --cpus-per-task=27
#SBATCH --mem=250GB
#SBATCH --time=5-00:00:00
#SBATCH --partition=long
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/chimb_data/4noeuds_chimp_data_metaspades.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/chimb_data/4noeuds_chimp_data_metaspades.%N.%j.err
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

source activate spades_3.15.5
#module load spades

folderInput="/shared/projects/virome_human_apes/virome_analysis/chimb_data/"
#refGenome="/data/virome_analysis/chimb_data/ref_genome"


cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}                  
 R1fastQgz=$(ls | grep -i after_R1_repair*\.fq.gz)
 echo $R1fastQgz
 for R1fastQgzFile in ${R1fastQgz};
 do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  contigFasta=$(echo ${R1fastQgzFile} | sed 's/_after_R1_repair.fq.gz/_assembly/')
  if [ -f "${R2fastQgzFile}" ];
   then
    echo "PairedEnd assembly Sample"
    srun metaspades.py --threads 100 -m 1000 -1 ${R1fastQgzFile} -2 ${R2fastQgzFile} -o ${contigFasta}
    echo "assembly done"
  else
   echo "SingleEnd Sample"
   metaspades.py  -s ${R1fastQgzFile} -o ${contigFasta}
   echo "Assembly done"
  fi
 cd ../
 done
done
source deactivate

#module unload spades


echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)

