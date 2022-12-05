#!/bin/bash

#SBATCH --job-name=gori_megahit
#SBATCH --cpus-per-task=38
#SBATCH --mem=150GB
#SBATCH --time=1-00:00:00
#SBATCH --partition=fast
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/gorilla_data/slurm_gorilla_data_megahit.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/gorilla_data/slurm_gorilla_data_megahit.%N.%j.err
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

#source activate spades_3.15.5
module load megahit

folderInput="/shared/projects/virome_human_apes/virome_analysis/gorilla_data/"
#refGenome="/data/virome_analysis/chimb_data/ref_genome"


cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}                  
 R1fastQgz=$(ls | grep -i R1_repair_paired*\.fq.gz)
 echo $R1fastQgz
 for R1fastQgzFile in ${R1fastQgz};
 do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  contigFasta=$(echo ${R1fastQgzFile} | sed 's/-R1_repair_paired.fq.gz/_assembly_megahit_out/')
  prefix=$(echo ${R1fastQgzFile} |  sed 's/-R1_repair_paired.fq.gz/_out/')
  if [ -f "${R2fastQgzFile}" ];
   then
    echo "PairedEnd assembly Sample"
    srun megahit -t 28 --out-prefix ${prefix} --min-contig-len 500 -1 ${R1fastQgzFile} -2 ${R2fastQgzFile} -o ${contigFasta}
    echo "Megahit assembly done"
  else
   echo "SingleEnd Sample"
   srun megahit -t 28 --out-prefix ${prefix} --min-contig-len 500 -r ${R1fastQgzFile} -o ${contigFasta}
   echo "Megahit Assembly done"
  fi
 cd ../
 done
done
#source deactivate

module unload megahit


echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)

