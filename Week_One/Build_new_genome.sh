xx=(
hg38 # human
bosTau9 #cow
galGal6 # chicken
susScr11 # Pig
mm39 # mouse
equCab3 # horse
oryCun2 # Rabbit
rn7 # rat
oviAri4 # sheep
dm6 # fruit fly
sacCer3 # Yeast
wuhCor1 # Covid
felCat9 # cat
canFam5 # dog
gadMor1 # Atalantic cod fish
oreNil2 # Nile Tilapia fish
)


Out_Path='./Genomev1'


for x in ${xx[*]}
do
    if [ ! -f ${x}.fa.gz -a ! -f ${x}.fa ]
    then
        FILE_PATH="https://hgdownload.soe.ucsc.edu/goldenPath/${x}/bigZips/${x}.fa.gz"
        echo "Download this Path: $FILE_PATH"
        #wget ${FILE_PATH}
        #gunzip ${x}.fa.gz 
        #sed -ic "s/>chr/>${x}_chr/g" ${x}.fa ## Only replace chr
        
        #gzip ${x}.fa ${x}.fac
    else
        echo "${x} exists."
        #gunzip ${x}.fa.gz
        sed -ic "s/^>/>${x}_/g" ${x}.fa & ## replace > 
        #gzip ${x}.fa ${x}.fac
    fi
done


#sed -i "s/>chr/>${x}_chr/g"