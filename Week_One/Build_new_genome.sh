xx=(
hg38
bosTau9
galGal6
susScr11 #
mm39 # mouse
equCab3 # horse
balAcu1 # Minke whale
oryCun2 # Rabbit
rn7 # rat
oviAri4 # sheep
danRer11 # Zebrafish
#dm6 # fruit fly
#sacCer3 # Yeast
wuhCor1 # Covid
)


Out_Path='./Genomev1'


for x in ${xx[*]}
do
    if [ ! -f ${x}.fa.gz -a ! -f ${x}.fa ]
    then
        FILE_PATH="https://hgdownload.soe.ucsc.edu/goldenPath/${x}/bigZips/${x}.fa.gz"
        echo "Download this Path: $FILE_PATH"
        #wget ${FILE_PATH}
    else
        echo "${x} exists."
        #gunzip ${x}.fa.gz
        sed -ic "s/>chr/>${x}_chr/g" ${x}.fa &
        #gzip ${x}.fa ${x}.fac
    fi
done


#sed -i "s/>chr/>${x}_chr/g"