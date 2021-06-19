xx=(
/ghds/groups/bioinformatics_research/flowcentral/190327_A00277_0148_AHGTLMDSXX.bd443b97-c987-4235-a235-529d9f41a8f3.20190329175509/
/ghds/ivd/flowcentral/201013_A00277_0318_AHJF7YDSXY.0dff62e9-3f64-47a1-8301-a51b6a5e625d.20201015214504/
/ghds/groups/bioinformatics_research/flowcentral/200623_A00274_0333_BHF7M5DSXY.74b0eac6-ba94-4334-9d33-f67cfbc0c310.20200626011505/
/ghds/groups/bioinformatics_research/flowcentral/190327_A00277_0148_AHGTLMDSXX.bd443b97-c987-4235-a235-529d9f41a8f3.20190329175509/
/ghds/groups/bioinformatics_research/flowcentral/200602_A00770_0118_AHF7LVDSXY.17a95de6-c955-41b8-b52a-e8c045d4900f.20200604220009/
)

yy=(
DL19032524
A017381552
A017381551
A0260122S1
DL19032527
)

OUT_PATH=/ghds/groups/algorithms/ref/non_human_contaminants/test_sample_cram/ 

for (( i = 0; i <= $(expr ${#xx[*]} - 1); i++ ))  ### Loop Operation [Ref.1]
do 
    ## with some key words
    cd ${OUT_PATH}
    File_2bfound=$(find -wholename "*${yy[i]}*short*.cram")
    if [ -n "$File_2bfound" ]; then
        echo "$File_2bfound exists"
    else
        echo "cd ${xx[i]}"
        cd ${xx[i]}
        File_2bCopy=$(find -wholename "*${yy[i]}*short*.cram")
        echo "cp ${File_2bCopy} ${OUT_PATH}"
        cp ${File_2bCopy} ${OUT_PATH} #&
    fi
done