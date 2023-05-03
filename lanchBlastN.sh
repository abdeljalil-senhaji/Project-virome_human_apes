#!/bin/bash

#SBATCH --job-name=job_name
#SBATCH --cpus-per-task=30
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o ../slurm_blast.%N.%j.out
#SBATCH -e ../slurm_blast.%N.%j.err
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




module load blast/2.12.0

folderInput=$1

cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}
 cd *_assembly_megahit_out
 contigFasta=$(ls | grep -i *contigs\.fa)
 echo $contigFasta  
 OutBlastN=$(echo ${contigFasta} | sed 's/_out.contigs/_blastn.txt/')
 srun blastn -task megablast -query ${contigFasta} -evalue 10e-50 -db /shared/bank/nt/current/blast/nt -num_threads 28 -outfmt "6 qseqid sseqid sstart send evalue bitscore slen staxids" -max_target_seqs 1 -max_hsps 1 > ${OutBlastN}
 echo "blast done"
 cd ../../
done


module unload blast 



echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)
