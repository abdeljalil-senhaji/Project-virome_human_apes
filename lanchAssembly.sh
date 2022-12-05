#!/bin/bash

#bash lanchAssembly.sh {folder}

#Abdeljalil v1.0.0
#SLS 20/09/2022

#module load spades
source activate spades_3.15.5

folderInput=$1
#refGenome="/data/virome_analysis/chimb_data/ref_genome"


cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}
 R1fastQgz=$(ls | grep -i after_R1_repair*\.fq.gz)
 echo $R1fastQgz
 for R1fastQgzFile in ${R1fastQgz};
 do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  contigFasta=$(echo ${R1fastQgzFile} | sed 's/_after_R1_repair.fq.gz/_assembly/')
  if [ -f "${R2fastQgzFile}" ];
   then
    echo "PairedEnd assembly Sample"
    metaspades.py -t 20 -m 225 -1 ${R1fastQgzFile} -2 ${R2fastQgzFile} -o ${contigFasta}  
    echo "assembly done"
    #cd ${contigFasta}
     
  else
   echo "SingleEnd Sample"
   metaspades.py -t 20 -s ${R1fastQgzFile} -o ${contigFasta}
   echo "Assembly done"
  fi
 cd ../
 done
done
source deactivate
#module unload spades
