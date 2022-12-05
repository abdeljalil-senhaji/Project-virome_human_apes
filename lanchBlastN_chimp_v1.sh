#!/bin/bash

#SBATCH --job-name=chimp_blastN
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=10-00:00:00  ## 3 j
#SBATCH --partition=long
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/chimb_data/new_slurm_long_balstN.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/chimb_data/new_slurm_long_blastN.%N.%j.err
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
 contigFasta=$(ls | grep -i *ConvertAndConcat\.fa.gz)
 echo $contigFasta
 OutBlastN=$(echo ${contigFasta} | sed 's/_ConvertAndConcat.fa.gz/_blastn_v1.txt/')
 gunzip -c ${contigFasta} | blastn -task megablast -evalue 10e-50 -db /shared/bank/nt/current/blast/nt -num_threads 28 -outfmt "6 qseqid sseqid evalue pident bitscore staxids stitle" -max_target_seqs 1 -max_hsps 1 > ${OutBlastN}
 echo "blast done"
 cd ../
done


module unload blast/2.12.0


echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)



