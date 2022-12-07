#!/usr/bin/env python


import pandas as pd
import os

df = pd.DataFrame()
directory = '../stats_bam_samples/'

for stats_file in os.listdir(directory):
    file = open(directory + stats_file, 'r')
    lines = file.readlines()
    num_reads = lines[0].split(' + ')[0]
    #myList_1.append(num_reads)
    percentage = lines[4].split('(')[-1].split('%')[0]
    #myList_2.append(percentage)
    samples = stats_file.split('.bam.txt')[0]
    df_tmp = pd.DataFrame({'samples' : samples, 'number of reads' : num_reads, 'per alignment %' : percentage}, index=[0])
    df = pd.concat([df, df_tmp], axis=0)
df.to_csv(directory+'per_alignment_hum.csv', index=False)
print(df)
