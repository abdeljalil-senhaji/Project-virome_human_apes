#!/bin/bash

#bash lanchRepair.sh {folder}

#Abdeljalil v1.0.0
#SLS 03/10/2022


source activate bbmap

folderInput=$1


cd ${folderInput}
folder=$(ls -1d */)
echo $folder

for i in ${folder};
do
 cd ${i}
 R1fastQgz=$(ls | grep -i after_R1_*\.fq.gz)
 echo $R1fastQgz
 for R1fastQgzFile in ${R1fastQgz};
 do
  R2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2/')
  NewR1fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R1_repair/')
  NewR2fastQgzFile=$(echo ${R1fastQgzFile} | sed 's/R1/R2_repair/')
  SingletonsReads=$(echo ${R1fastQgzFile} | sed 's/R1/singletons/')
  if [ -f "${R2fastQgzFile}" ];
   then
    echo "PairedEnd assembly Sample"
    repair.sh in1=${R1fastQgzFile} in2=${R2fastQgzFile} out1=${NewR1fastQgzFile} out2=${NewR2fastQgzFile} outs=${SingletonsReads} repair
    echo "repair paire reads fixed done"
  else
   echo "SingleEnd Sample"
   repair.sh in1=${R1fastQgzFile} out1=${NewR1fastQgzFile} repair
   echo "repair unpaire reads fixed done"
  fi
 cd ../
 done
done
source deactivate

