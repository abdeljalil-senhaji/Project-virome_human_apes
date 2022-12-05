#!/bin/bash

#SBATCH --job-name=hum5
#SBATCH --cpus-per-task=30
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/hum5/kraken2_slurm_metaspades.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/hum5/kraken2_slurm_metaspades.%N.%j.err
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

module load kraken2/

folderinput=$1
paired=$2

cd ${folderinput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do 
 cd ${i}
 echo "kraken sur $i"
 if [ "$paired" == "paired" ];
 then
   for file in *-R1_repair_paired.fq.gz
   do
     f=$(basename "$file" | awk -F"R1" '{print $1}')
     suffix=$(basename "$file" | awk -F"R1" '{print $2}')
     fr2="$f""R2""$suffix"
     echo "$f"
     echo "$fr2"
     kraken2 --db /shared/bank/nt/nt_2021-01-29/kraken2/2021-02-02/ --gzip-compressed --threads 30 --paired --report $f.report.txt --classified-out $f.clseqs#.fastq --unclassified-out $f.unclseqs#.fq --output $f.output.txt $file $fr2
   done
 rm *.unclseqs*.fq 
 rm *.clseqs*.fastq
 cd ../
 elif [ "$paired" == "single" ];
 then
   for file in *repair_paired.fq.gz
   do
     f=$(basename "$file" *repair_paired.fq.gz)
     echo "$f"
     kraken2  --gzip-compressed  --use-mpa-style --paired  --report $f.report.txt --classified-out $f.clseqs_1.fastq --unclassified-out $f.unclseqs_1.fq --output $f.output.txt $file
   done
 else
   echo "Missing argument (paired/single)"
 fi
done




module unload kraken2/


echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)

