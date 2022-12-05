#!/bin/bash

#bash lanchAssembly_megahit.sh {folder}

#Abdeljalil v1.0.0
#SLS 20/09/2022

module load megahit


folderInput=$1
#refGenome="/data/virome_analysis/chimb_data/ref_genome"


cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}
 R1fastQgz=$(ls | grep -i after_R1*\.fq.gz)
 echo $R1fastQgz
 for R1fastQgzFile in ${R1fastQgz};
 do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  contigFasta=$(echo ${R1fastQgzFile} | sed 's/_after_R1.fq.gz/_assembly_megahit_out/')
  if [ -f "${R2fastQgzFile}" ];
   then
    echo "PairedEnd assembly Sample"
    megahit -t 28 -1 ${R1fastQgzFile} -2 ${R2fastQgzFile} -o ${contigFasta}  
    echo "assembly megahit done"
    #cd ${contigFasta}
     
  else
   echo "SingleEnd Sample"
   megahit -t 20 -s ${R1fastQgzFile} -o ${contigFasta}
   echo "Assembly done"
  fi
 cd ../
 done
done
module unload megahit
