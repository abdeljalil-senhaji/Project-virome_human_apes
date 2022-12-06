#!/bin/bash

#SBATCH --job-name=taxID
#SBATCH --cpus-per-task=28
#SBATCH --mem=250GB
#SBATCH --time=1-00:00:00  ## 3 j
#SBATCH --partition=fast
#SBATCH -o /shared/projects/virome_human_apes/virome_analysis/taxId/taxid_new_slurm_analysis.%N.%j.out
#SBATCH -e /shared/projects/virome_human_apes/virome_analysis/taxId/taxid_new_slurm_analysis.%N.%j.err
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

path='/shared/projects/virome_human_apes/virome_analysis/taxId'
pathdata='/shared/projects/virome_human_apes/virome_analysis/taxId/taxdump'

##script


perl ${path}/tax.pl ${pathdata}/nodes.dmp ${pathdata}/names.dmp ${path}/chimp_listTaxId_DNA.txt ${path}/chimp_DNA_taxids_export.txt
echo 'done chimp_listTaxId_DNA.txt'
perl ${path}/tax.pl ${pathdata}/nodes.dmp ${pathdata}/names.dmp ${path}/chimp_listTaxId_RNA.txt ${path}/chimp_RNA_taxids_export.txt
echo 'done chimp_listTaxId_RNA.txt'
perl ${path}/tax.pl ${pathdata}/nodes.dmp ${pathdata}/names.dmp ${path}/gori_listTaxId_DNA.txt ${path}/gori_DNA_taxids_export.txt
echo 'done gori_listTaxId_DNA.txt'
perl ${path}/tax.pl ${pathdata}/nodes.dmp ${pathdata}/names.dmp ${path}/gori_listTaxId_RNA.txt ${path}/gori_RNA_taxids_export.txt
echo 'done gori_listTaxId_RNA.txt'
perl ${path}/tax.pl ${pathdata}/nodes.dmp ${pathdata}/names.dmp ${path}/hum_taxids_DNA.txt ${path}/hum_DNA_taxids_export.txt
echo 'done hum_taxids_DNA.txt'
perl ${path}/tax.pl ${pathdata}/nodes.dmp ${pathdata}/names.dmp ${path}/hum_taxids_RNA.txt ${path}/hum_RNA_taxids_export.txt
echo 'done hum_taxids_RNA.txt'


echo '########################################'
echo 'Job finished' $(date --iso-8601=seconds)

