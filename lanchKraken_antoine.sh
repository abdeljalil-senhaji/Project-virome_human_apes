#!/bin/bash





myfolder=$1
paired=$2
echo "kraken sur $myfolder"





if [ "$paired" == "paired" ];
then
  #for i 
  for file in $myfolder/*R1*_paired.fq.gz
  do
    f=$(basename "$file" | awk -F"R1" '{print $1}')
    suffix=$(basename "$file" | awk -F"R1" '{print $2}')
    fr2="$f""R2""$suffix"
    echo "$f"
    echo "$fr2"
    kraken2 --db /shared/bank/nt/nt_2021-01-29/kraken2/2021-02-02/ --gzip-compressed --threads 20 --paired --report $myfolder/$f.report.txt --classified-out $myfolder/$f.clseqs#.fastq --unclassified-out $myfolder/$f.unclseqs#.fq --output $myfolder/$f.output.txt $file $myfolder/$fr2
    unclassifiedReads=$(head -2 $myfolder/$f.report.txt | cut -f2 | head -1)
    classifiedReads=$(head -2 $myfolder/$f.report.txt | cut -f2 | tail -1)
    humanReads=$(grep 'Homo sapiens$' $myfolder/$f.report.txt | cut -f2 | head -1)
    bacterialReads=$(grep 'Bacteria$' $myfolder/$f.report.txt | cut -f2 | head -1)
    viralReads=$(grep 'Viruses$' $myfolder/$f.report.txt | cut -f2 | head -1)
    fungiReads=$(grep 'Fungi$' $myfolder/$f.report.txt | cut -f2 | head -1)
    infofile=$(ls $myfolder/$f*info.txt)
    echo $(($unclassifiedReads * 2 + $classifiedReads * 2)) >> ${infofile}
    echo $(($classifiedReads * 2)) >> ${infofile}
    if [ -z "$humanReads" ];
    then
      echo "0" >> ${infofile}
    else
      echo $(($humanReads * 2)) >> ${infofile}
    fi
    if [ -z "$bacterialReads" ];
    then
      echo "0" >> ${infofile}
    else
      echo $(($bacterialReads * 2)) >> ${infofile}
    fi
    if [ -z "$viralReads" ];
    then
      echo "0" >> ${infofile}
    else
      echo $(($viralReads * 2)) >> ${infofile}
    fi
    if [ -z "$fungiReads" ];
    then
      echo "0" >> ${infofile}
    else
      echo $(($fungiReads * 2)) >> ${infofile}
    fi
  done
elif [ "$paired" == "single" ];
then
  for file in $myfolder/*trimmed.fq.gz
  do
    f=$(basename "$file" *trimmed.fq.gz)
    echo "$f"
    kraken2 --db /shared/bank/nt/nt_2021-01-29/kraken2/2021-02-02/ --gzip-compressed --threads 10 --report $myfolder/$f.report.txt --classified-out $myfolder/$f.clseqs_1.fastq --unclassified-out $myfolder/$f.unclseqs_1.fq --output $myfolder/$f.output.txt $file
    unclassifiedReads=$(head -2 $myfolder/$f.report.txt | cut -f2 | head -1)
    classifiedReads=$(head -2 $myfolder/$f.report.txt | cut -f2 | tail -1)
    humanReads=$(grep 'Homo sapiens$' $myfolder/$f.report.txt | cut -f2 | head -1)
    bacterialReads=$(grep 'Bacteria$' $myfolder/$f.report.txt | cut -f2 | head -1)
    viralReads=$(grep 'Viruses$' $myfolder/$f.report.txt | cut -f2 | head -1)
    fungiReads=$(grep 'Fungi$' $myfolder/$f.report.txt | cut -f2 | head -1)
    infofile=$(ls $myfolder/$f*info.txt)
    echo $(($unclassifiedReads + $classifiedReads)) >> ${infofile}
    echo $(($classifiedReads)) >> ${infofile}
    echo $(($humanReads)) >> ${infofile}
    echo $(($bacterialReads)) >> ${infofile}
    echo $(($viralReads)) >> ${infofile}
    echo $(($fungiReads)) >> ${infofile}
  done
else
  echo "Missing argument (paired/single)"
fi

