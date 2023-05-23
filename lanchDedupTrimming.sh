#!/bin/bash



#Abdeljalil v1.0.0
#SLS 20/09/2022
#CommandLine :
#sbatch launchDedupTrimming.sh {folder}


#SBATCH --job-name=preanalysis
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /new_slurm_analysis.%N.%j.out
#SBATCH -e /new_slurm_analysis.%N.%j.err
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



#load the tools : 
module load bbmap/39.00
module load trimmomatic/0.39



folderInput=$1
cd ${folderInput}
R1fastQgz=$(ls | grep -i R1.*\.fastq\.gz)
for R1fastQgzFile in ${R1fastQgz};
do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  outFile=$(echo ${R1fastQgzFile} | sed 's/R1.fastq.gz/out/')
  echo ${outFile}
  dedupe1=$(echo ${R1fastQgzFile} | sed 's/R1/R1_dedupe/')
  dedupe2=$(echo ${R1fastQgzFile} | sed 's/R1/R2_dedupe/')
  if [ -f "${R2fastQgzFile}" ];
  then
    #countReads=$(zcat ${R1fastQgzFile} | grep '^+$' | wc -l )
    #echo $(($countReads * 2)) > ${outFile}/${R1fastQgzFile%%.*}.info.txt
    echo "PairedEnd Sample"
    clumpify.sh qin=33 in1=${R1fastQgzFile} in2=${R2fastQgzFile} out1=${dedupe1} out2=${dedupe2} dedupe
    echo "Deduplicated"
    mkdir ${outFile}
    trimmomatic PE -threads 10 ${dedupe1} ${dedupe2} ${outFile}/${R1fastQgzFile%%.*}_paired.fq.gz ${R1fastQgzFile%%.*}_unpaired.fq.gz ${outFile}/${R2fastQgzFile%%.*}_paired.fq.gz ${R2fastQgzFile%%.*}_unpaired.fq.gz AVGQUAL:20 MINLEN:50
    echo "Trimmed"
    rm ${dedupe1} ${dedupe2}
    rm ${R1fastQgzFile%%.*}_unpaired.fq.gz ${R2fastQgzFile%%.*}_unpaired.fq.gz
  else
    zcat ${R1fastQgzFile} | grep '^+$' | wc -l > ${R1fastQgzFile%%.*}.info.txt
    echo "SingleEnd Sample"
    clumpify.sh qin=33 in=${R1fastQgzFile} out=${dedupe1} dedupe
    echo "Deduplicated"
    trimmomatic SE -threads 10 ${dedupe1} ${R1fastQgzFile%%.*}_trimmed.fq.gz AVGQUAL:20 MINLEN:50
    echo "Trimmed"
    rm ${dedupe1}
  fi
done





#unload the tools:
module unload bbmap
module unload trimmomatic






echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)
