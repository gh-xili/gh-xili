#!/usr/bin/env python
# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import os
import argparse

def Add_multi_molecules(_df_tem):
    df_tem = _df_tem
    df_tem.loc[:, "FRAGSIZE"] = df_tem.loc[:, "end"] - df_tem.loc[:, "start"]
    extra_read = []
    for read in df_tem[df_tem.num_molecules>1].itertuples():
        #print (read)
        num = int(read.num_molecules)
        for num_y in range(1,num):
            extra_read.append(read)
    return pd.concat([df_tem, pd.DataFrame(extra_read)], axis=0)

def Generate_Distribution_From_Table(_df_tem, _min, _max):
    Min_Fragsize=_min
    Max_Fragsize=_max
    df_tem = _df_tem
    
    Out_table = np.zeros(Max_Fragsize-Min_Fragsize, dtype=int)
    for idx, x in df_tem.loc[:, "FRAGSIZE"].value_counts(sort=False).items():  
        #print (idx) ## index = fragsize
        if (idx <= Max_Fragsize):
            Out_table[idx-1]=x
    return Out_table

def Process_chunk(_chunk):
    chunk_group = _chunk.groupby(by=["bin_idx"])
    Min_Fragsize=0
    Max_Fragsize=500

    Out_Sum = []
    Out_idx = []
    for group in chunk_group:
        Out_idx.append(group[0])
        df_chunk = Add_multi_molecules(group[1])
        Out_Sum.append(Generate_Distribution_From_Table(df_chunk, Min_Fragsize, Max_Fragsize))

    return Out_idx, Out_Sum

def Merge_ChunkResults(_df_out):
    df_out = _df_out
    df_out_dup = df_out.loc[df_out.index.duplicated(keep=False), :]
    if (df_out_dup.empty):
        print("NO Chunk is used.")
    else:
        out_extra_idx   = []
        out_extra_table = []
        for dup_group in df_out_dup.groupby(level=0):
            out_extra_idx.append(dup_group[0])
            out_extra_table.append(dup_group[1].sum(axis=0))  ## merge edge of chunksize. by simply addition
        df_out_extra = pd.DataFrame(data=out_extra_table, index=out_extra_idx)
        df_out = pd.concat( [df_out.loc[df_out.index.drop_duplicates(keep=False), :], df_out_extra], axis=0).sort_index()
    return df_out

def Return_FRAG_from_path(_path, _chunsize, _outpath):
    Out_PATH = _outpath   #'/ghess/groups/algorithms/projects/Study_Fragment_Size/Counting_Table/FragSize_Distribution/'
    chunksize=10**_chunsize
    Min_Fragsize=0
    Max_Fragsize=500
    datatype={"start": int,"end": int,"num_molecules": int,"bin_idx": int}### Specify data tpye will reduce mem usage.
    if (os.path.isfile(_path)):
        #print ("Yes")
        out_idx= []
        out_table = []
        for chunk in pd.read_csv(_path, sep="\t", chunksize=chunksize, usecols=datatype.keys(), dtype=datatype):
            tem_idx, tem_table = Process_chunk(chunk)
            out_idx.extend(tem_idx)
            out_table.extend(tem_table)
        df_out = Merge_ChunkResults(pd.DataFrame(data=out_table, index=out_idx))
        Outfile_PATH= Out_PATH+_path.split("/")[-1].replace("molecule_table.tsv", "fragsize_distribution.txt")
        df_out.to_csv(Outfile_PATH, sep='\t')
    return None#df_out

def get_args():
    """
    Parse command line arguments and return argument object.
    :return: object
    """
    parser = argparse.ArgumentParser(description='"Some Input argu for Generate Fragsize Distribution.')
    parser.add_argument('-i', '--input', required=True, action='store',
                        help="Input File of .molucule.table")
    parser.add_argument('-o', '--output', required=True, action='store',
                        help="Output File of .fragsize_distribution.txt")
              
    return parser.parse_args()
    
def run():
    # get args
    args = get_args()
    Return_FRAG_from_path(args.input, 6, args.output)
    return 0

if __name__ == '__main__':
    # use this section to either run unit tests or execute as command line utility 
    # get args
	run()
