#!/bin/bash




#Abdeljalil v1.0.0
#SLS 20/09/2022
#CommandLine :
#sbatch launchAlignment.sh {folder}



#SBATCH --job-name=AlignmentAndUnmappedRead
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /new_slurm_.%N.%j.out
#SBATCH -e /new_slurm_.%N.%j.err
#SBATCH -A virome_human_apes

#load conda envirement :

source activate bwa_0.7.17

folderInput=$1

refGenome="/shared/bank/homo_sapiens/GRCh38/fasta"

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
   if [ -f "${R2fastQgzFile}" ];
   then
     echo "PairedEnd Sample"
     bwa mem -t 10 ${refGenome}/Homo_sapiens.GRCh38.dna.primary_assembly.fa ${R1fastQgzFile} ${R2fastQgzFile} | samtools view -@ 10 -b -o ${bam}
     samtools flagstat  ${bam} > ${bam}.txt 
     echo "Alignment done"
     samtools view -@ 10 -h -f 4 ${bam} -o ${unmmaped}
     echo "results file unmappd reads done"
     samtools sort -@ 10 -n ${unmmaped} -o ${unmmapedSort}
     echo "same order reads done"
     samtools fastq -@ 10 ${unmmapedSort} -1 ${fastq1} -2 ${fastq2} -0 /dev/null -s /dev/null -n
     echo "generated fastq done"
     rm ${bam}
     rm ${unmmaped}
     rm ${unmmapedSort}
   else
    echo "SingleEnd Sample"
    bwa mem -t 10 ${refGenome}/Homo_sapiens.GRCh38.dna.toplevel.fa ${R1fastQgzFile} | samtools view -@ 10 -b -o ${bam}
    echo "Alignment done"
    samtools view -@ 10 -h -f 4 ${bam} -o ${unmmaped}
    echo "results file unmappd reads done"
    samtools sort -@ 10 -n ${unmmaped} -o ${unmmapedSort}
    echo "same order reads done"
    samtools fastq -@ 10 ${unmmapedSort} ${fastq} -0 /dev/null -s /dev/null -n
    echo "generated fastq done"
    rm ${bam}
    rm ${unmmaped}
    rm ${unmmapedSort}
   fi
  cd ../ 
  done
done

#unload conda env
 
source deactivate




echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)
