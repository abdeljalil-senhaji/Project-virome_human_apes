#!/bin/bash

#SBATCH --job-name=data_incomplet
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/data_incompl/new_slurm_blastN_gori.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/data_incompl/new_slurm_blastN_gori.%N.%j.err
#SBATCH -A virome_human_apes


#Abdeljalil v1.1.0
#SLS 20/09/2022
#bash commandLine_align.sh {folder}

source activate bwa_0.7.17
module load bbmap/39.00

folderInput=$1
refGenome="/shared/bank/homo_sapiens/GRCh38/bwa"

cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
  cd ${i}
  #cd ${folderInput}
  R1fastQgz=$(ls | grep -i R1_*\paired.fq.gz)
  echo $R1fastQgz
  for R1fastQgzFile in ${R1fastQgz};
  do
   R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
   bam=$(echo ${R1fastQgzFile} | sed 's/-R1_paired.fq.gz/.bam/')
   unmmaped=$(echo ${R1fastQgzFile} | sed 's/-R1_paired.fq.gz/_unmmaped.bam/')
   unmmapedSort=$(echo ${R1fastQgzFile} | sed 's/-R1_paired.fq.gz/_unmmapedSort.bam/')
   fastq1=$(echo ${R1fastQgzFile} | sed 's/-R1_paired.fq.gz/_after_R1.fq.gz/')
   fastq2=$(echo ${R1fastQgzFile} | sed 's/-R1_paired.fq.gz/_after_R2.fq.gz/')
   NewR1fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R1_repair/')
   NewR2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2_repair/')
   SingletonsReads=$(echo ${R1fastQgzFile} | sed 's/R1/singletons/')
   if [ -f "${R2fastQgzFile}" ];
   then
     echo "PairedEnd Sample"
     bwa mem -p -t 14 ${refGenome}/Homo_sapiens.GRCh38.dna.primary_assembly.fa ${R1fastQgzFile} ${R2fastQgzFile} | samtools view -@ 10 -b -o ${bam}
     samtools flagstat  ${bam} > ${bam}.txt
     echo "Alignment done"
     samtools view -@ 20 -h -f 4 ${bam} -o ${unmmaped}
     echo "results file unmappd reads done"
     samtools flagstat  ${unmmaped} > ${unmmaped}.txt
     samtools sort -@ 20 -n ${unmmaped} -o ${unmmapedSort}
     echo "same order reads done"
     samtools fastq -@ 20 ${unmmapedSort} -1 ${fastq1} -2 ${fastq2} -0 /dev/null -s /dev/null -n
     echo "generated fastq done"
     repair.sh in1=${fastq1} in2=${fastq2} out1=${NewR1fastQgzFile} out2=${NewR2fastQgzFile} outs=${SingletonsReads} repair
     echo "repair paire reads fixed done"
     rm ${bam}
     rm ${unmmaped}
     rm ${unmmapedSort}
   else
    echo "SingleEnd Sample"
    bwa mem -t 10 ${refGenome}/Gorilla_gorilla.gorGor4.dna.toplevel.fa ${R1fastQgzFile} | samtools view -@ 10 -b -o ${bam}
    echo "Alignment done"
   fi
  cd ../
  done
done
source deactivate

module unload bbmap/39.00

