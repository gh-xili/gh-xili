xx=(
/ghds/ivd/flowcentral/201013_A00277_0318_AHJF7YDSXY.0dff62e9-3f64-47a1-8301-a51b6a5e625d.20201015214504/
/ghds/ivd/flowcentral/201015_A00277_0319_AHJFC5DSXY.43362916-fdec-423f-9e5c-fe2b9e026f96.20201017200005/
/ghds/ivd/flowcentral/201013_A00277_0318_AHJF7YDSXY.0dff62e9-3f64-47a1-8301-a51b6a5e625d.20201015214504/
/ghds/ivd/flowcentral/210122_A00274_0426_BHT257DSXY.590cdb46-4557-47cf-8e87-2b35038a161f.20210126061516/
/ghds/groups/bioinformatics_research/flowcentral/190327_A00277_0148_AHGTLMDSXX.bd443b97-c987-4235-a235-529d9f41a8f3.20190329175509/
/ghds/ivd/flowcentral/201013_A00277_0318_AHJF7YDSXY.0dff62e9-3f64-47a1-8301-a51b6a5e625d.20201015214504/
/ghds/groups/bioinformatics_research/flowcentral/200623_A00274_0333_BHF7M5DSXY.74b0eac6-ba94-4334-9d33-f67cfbc0c310.20200626011505/
/ghds/groups/bioinformatics_research/flowcentral/190327_A00277_0148_AHGTLMDSXX.bd443b97-c987-4235-a235-529d9f41a8f3.20190329175509/
/ghds/groups/bioinformatics_research/flowcentral/200602_A00770_0118_AHF7LVDSXY.17a95de6-c955-41b8-b52a-e8c045d4900f.20200604220009/
/ghds/ivd/flowcentral/201208_A00277_0361_BHN72CDSXY.b9acc4a7-cb17-4509-86b4-8c1b9e79f340.20201210233028/
/ghds/ivd/flowcentral/201207_A00770_0198_AHN5VNDSXY.aafa59a7-80cc-49de-b8d0-edcbf0f39876.20201210010012/
)

yy=(
A017383551 # No contamination sample
A017383552 # No contamination sample
A017383651 # No contamination sample
A031438301 # Salmon
DL19032524
A017381552
A017381551
A0260122S1
DL19032527
A0186048MMC-02
A0261917HP4-05
A0261917PRE-05
)

OUT_PATH=/ghess/groups/algorithms/projects/non_human_contamination/test_sample_cram/cram

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
        cp ${File_2bCopy} ${OUT_PATH} &
    fi
done