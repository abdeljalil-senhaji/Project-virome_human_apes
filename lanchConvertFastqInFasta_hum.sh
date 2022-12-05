#!/bin/bash

#SBATCH --job-name=hum_conv
#SBATCH --cpus-per-task=22
#SBATCH --mem=22GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/hum_data/slurm_convert_cat_chimp.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/hum_data/slurm_convert_cat_chimp.%N.%j.err
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

module load seqtk/1.3

folderInput="/shared/projects/virome_human_apes/virome_analysis/hum_data/"

cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}
 R1fastQgz=$(ls | grep -i after_R1*\.fq.gz)
 echo $R1fastQgz
 for R1fastQgzFile in ${R1fastQgz};
 do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  Concatenat=$(echo ${R1fastQgzFile} | sed 's/_after_R1.fq.gz/_ConvertAndConcat.fa.gz/')
  fasta1=$(echo ${R1fastQgzFile} | sed 's/_after_R1.fq.gz/_R1_convert.fa/')
  fasta2=$(echo ${R1fastQgzFile} | sed 's/_after_R1.fq.gz/_R2_convert.fa/')
  echo "PairedEnd convert Sample"
  seqtk seq -a ${R1fastQgzFile} > ${fasta1}
  echo "convert R1 fastq in fasta done"
  seqtk seq -a ${R2fastQgzFile} > ${fasta2}
  echo "convert R2 fastq in fasta done"
  cat ${fasta1} ${fasta2} | gzip > ${Concatenat}
  echo "concatenation done"
  rm ${fasta1} ${fasta2}  
  echo "remove R1 fasta R2 fasta done"
  cd ../
 done
done
module unload seqtk/1.3



echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)
