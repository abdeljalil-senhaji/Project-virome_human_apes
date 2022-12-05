#!/bin/bash

#SBATCH --job-name=long_hum
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=10-00:00:00  ## 3 j
#SBATCH --partition=long
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/done_chimb/new_slurm_long_hum_blastN_hum.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/done_chimb/new_slurm_long_hum_blastN_hum.%N.%j.err
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
module load blast/2.12.0

folderInput=$1

cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}
 contigFasta=$(ls | grep -i *_ConvertAndConcat\.fa.gz)
 echo $contigFasta  
 OutBlastN=$(echo ${contigFasta} | sed 's/_ConvertAndConcat.fa.gz/_blastn_v1.csv/')
 #cat ${contigFasta} | parallel --block 100k --recstart '>' --pipe blastn -task megablast -evalue 10e-50 -db /shared/bank/nt/current/blast/nt -num_threads 1 -outfmt 6 -max_target_seqs 1 -max_hsps 1  > ${OutBlastN}
 gunzip -c ${contigFasta} | blastn -task megablast -evalue 10e-50 -db /shared/bank/nt/current/blast/nt -num_threads 25 -outfmt "6 qseqid sseqid evalue pident bitscore staxids ssciname scomnames sblastnames sskingdoms stitle" -max_target_seqs 1 -max_hsps 1 > ${OutBlastN}
 echo "blast done"
 cd ../
done


module unload blast/2.12.0



echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)
