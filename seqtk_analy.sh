# number read :

zcat 13-FB-004-DNA_after_R1.fq.gz | echo $((`wc -l`/4))

# quality/summary

srun -A virome_human_apes -n 2 --mem=1000GB --cpus-per-task 60  seqtk fqchk 35-FB-001-RNA_after_R2.fq.gz

# 


scontrol show partitions

sacct -u 
squeue -u  
seff jobid
scontrol show job 26369718

# Quota by user :
sacctmgr -p show qos format=Name,MaxTRESPU
sacctmgr -p show qos format=Name,MaxTRESPerUser
