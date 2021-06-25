#!/bin/bash
# /mnt/c/Users/Xiang/Dropbox/AResearch/version.beta

#set -e	#### terminating the script if any command exited with a nonzero exit status
set +H #### to disable the C shell-style command history,‘!’ as a special character.
set -u #### prevents the error by aborting the script if a variable’s value is unset
set -o pipefail 	#### check on the p398 of book Bioinformatics Data Skills.
#set -o noclobber ####The noclobber option tells bash not to overwrite any existing files when you redirect output.

#echo "[$(date "+%Y-%m-%d %H:%M")]  <YOUR CONTENT>"

## INTRODUCTION
########################################################################
## 12/01/2017
## By Xiang Li, basing on codes in Peng lab
## xili@guardanthealth.com
## Ver.1.0
########################################################################

## DECLARATION
########################################################################

  #  means NEED MODIFICATION. "VERY IMPORTANT INFORMATION"
  ## means Title_level 1.
 ### means Title_level 2.
#### means comment.
########################################################################
########################################################################
###    Global Variables
	Tools_DIR=${PATH}
	Python_Tools_DIR="~/Python_tools"
	Annotation_DIR="~/"
	THREADS=40
######################################

##	FUNDEMENTAL FUNCTIONS FOR ANALYSIS MODULES

PRE_READS_DIR(){
	### PRE_READS_DIR ${PATH_FOLDER} ${__INPUT_SAMPLE_DIR_List[i]} "fastq.gz" "Pairs SRA or anyother pattern"
	CHECK_arguments $# 4 # No less than 3
	echo "[$(date "+%Y-%m-%d %H:%M")]--------------INPUT FILE PREPARING"
	echo "Entering Directory: ${__INPUT_PATH} ----------------- Searching File as: $1 + $3 + $2"

	local Current_DATA_DIR=${1}
	cd ${Current_DATA_DIR}
	local INPUT_Key_Word=${2/Sample_/}
	local INPUT_Ext=${3}
	local Pair_Type=${4}
	
########################################################################

	case ${Pair_Type} in
	"Pair")
	echo "Pair End Mode, R1 and R2 to be found........................."
	local DIRLIST_R1_gz="$( find -name "*${INPUT_Key_Word}*R1*.${INPUT_Ext}" | sort -n | xargs)"
	local DIRLIST_R2_gz="$( find -name "*${INPUT_Key_Word}*R2*.${INPUT_Ext}" | sort -n | xargs)"
	;;
	"SRA")
	echo "SRA Mode, _1 and _2 to be found.............................."
	local DIRLIST_R1_gz="$( find -name "*${INPUT_Key_Word}*_1*.${INPUT_Ext}" | sort -n | xargs)"
	local DIRLIST_R2_gz="$( find -name "*${INPUT_Key_Word}*_2*.${INPUT_Ext}" | sort -n | xargs)"
	;;
	*)
	echo "Reads ERR: Did Not Find Any Matched Reference...... Exit"
	exit
	;;
	esac
	
#### R1 Saving		
	local k=0
	unset __FASTQ_DIR_R1
	for FILE_DIR in ${DIRLIST_R1_gz[*]}
	do
		__FASTQ_DIR_R1[k]="${Current_DATA_DIR}/${FILE_DIR: 2}"
		echo "Saving R1 reads DIR as ${__FASTQ_DIR_R1[k]}"
		k=`expr $k + 1`
	done
	

#### R2 Saving	
	local k=0
	__FASTQ_DIR_R2=""
	for FILE_DIR in ${DIRLIST_R2_gz[*]}
	do
		__FASTQ_DIR_R2[k]="${Current_DATA_DIR}/${FILE_DIR: 2}"
		echo "Saving R2 reads DIR as ${__FASTQ_DIR_R2[k]}"
		k=`expr $k + 1`
	done
	
	echo "Finish Preparing READS of Library: $1"
	echo "------------------------------------------INPUT FILE PREPARING COMPLETED !"
	echo " "
	unset k
	}

FUNC_Download (){
	CHECK_arguments $# 2
	## wget -m --user=username --password=password ftp://ip.of.old.host
	### Download Login information and the download directory.
	#### -nH --cut-dirs=3   Skip 3 directory components.
	local Web_Address=${1}
	local Directory_Skip_Num=5
	#local USER='gec'
	local USER='hui.hai.xue'
	#local PASSWORD='aardvark dryer rummage'
	local PASSWORD='M!JmsXZBMs'
	local DOWNLOAD_STORE_NAME=${2};
	
	local Down_dir=${__INPUT_PATH}/${DOWNLOAD_STORE_NAME}/;
	DIR_CHECK_CREATE ${Down_dir}
	####If download file is a folder. IT MUST END WITH trailing slash  "/"
	########################################################################
	cd ${Down_dir}
	if [ -n "${USER}" -a -n "${PASSWORD}" ]
	then
	echo " [$(date "+%Y-%m-%d %H:%M")] Start Download................."
	echo "wget --no-check-certificate -nv -r -c -nH --cut-dirs=${Directory_Skip_Num} --user=${USER} --password=${PASSWORD} --accept=gz --no-parent ${Web_Address}"
	wget --no-check-certificate -nv -r -c -nH --cut-dirs=${Directory_Skip_Num} --user=${USER} --password=${PASSWORD} --accept=gz --no-parent ${Web_Address}
	#echo "wget -r --user='${USER}' --password='${PASSWORD}' ftp://ftp.admerahealth.com/19092-05/"
	#wget -r --user=${USER} --password=${PASSWORD} ftp://ftp.admerahealth.com/19092-05/
	else
	#### NO PASSCODE
	echo "wget --no-check-certificate -nv -r -c -nH --cut-dirs=${Directory_Skip_Num} --accept=gz --no-parent ${Web_Address}"
	wget --no-check-certificate -nv -r -c -nH --cut-dirs=${Directory_Skip_Num} --accept=gz --no-parent ${Web_Address}
	fi
	echo "[$(date "+%Y-%m-%d %H:%M")] Downloaded Completed"
	echo ""
	}

RUN_COPY_AND_CHANGE_NAME(){
	### RUN_COPY_AND_CHANGE_NAME $1 $2 $3 ($1 is INPUT_NAME $2> OUTPUT_NAME $3 "fastq.gz")
	CHECK_arguments $# 3
	local INPUT_DATA_PATH="${__INPUT_PATH}/${1}"
	local OUTPUT_DATA_PATH="${__OUTPUT_PATH}/${2}"
	
	mkdir -p ${OUTPUT_DATA_PATH}
	
	cp ${INPUT_DATA_PATH}.${3} ${OUTPUT_DATA_PATH}/${2}.${3}
	echo "Finished Copying File: ${2}"
	}
	
RUN_Trim_Galore_QC(){
# Not compatible with bowtie2
	##https://github.com/FelixKrueger/TrimGalore/blob/master/Docs/Trim_Galore_User_Guide.md
####	RUN_Trim_Galore_QC
####	Usage: RUN_Trim_Galore_QC $INPUT_DATA_DIR
########################################################################

### FASTQC Output DIR setting ...
	echo "[$(date "+%Y-%m-%d %H:%M")]-----------------------RUN_Trim_Galore_QC"
	local Output_Trim_QC=${__OUTPUT_PATH}/Trim_Galore_QC
	DIR_CHECK_CREATE ${Output_Trim_QC}
	
	for (( i = 0; i <= $(expr ${#__FASTQ_DIR_R1[*]} - 1); i++ ))
	do
		#echo ${__FASTQ_DIR_R1[*]}
		if [ -n "${__FASTQ_DIR_R1[*]}" -a -n "${__FASTQ_DIR_R2[*]}" ]
		then
		#R1 5'---------------------------> 3'
		#R2 3'<--------------------------- 5'
			echo "Pair End Mode"
			echo "trim_galore --cores 4 --gzip --length 20 --fastqc --output_dir ${Output_Trim_QC} --paired ${__FASTQ_DIR_R1[i]} ${__FASTQ_DIR_R2[i]}"
			trim_galore --cores 4 --gzip --length 20 --fastqc --output_dir ${Output_Trim_QC} --paired ${__FASTQ_DIR_R1[i]} ${__FASTQ_DIR_R2[i]} --suppress_warn --three_prime_clip_R1 25 --three_prime_clip_R2 25 --clip_R1 25 --clip_R2 25
		else
			echo "Single End Mode."
			echo "trim_galore --gzip --length 30 --fastqc --output_dir ${Output_Trim_QC} ${__FASTQ_DIR_R1[i]} --suppress_warn"
			trim_galore --cores 4 --gzip --length 20 --fastqc --output_dir ${Output_Trim_QC} ${__FASTQ_DIR_R1[i]} --suppress_warn &
		fi
	done
	
	wait
	
	echo "[$(date "+%Y-%m-%d %H:%M")]---------RUN_Trim_Galore_QC-----COMPLETED!"
	echo " "
	
	local xx=$(find -name "${__OUTPUT_PATH}/Trim_Galore_QC/*R2*.gz_trimming_report.txt")
	for x in ${xx[*]}
	do 
		tail -n 7 ${x} | awk NF >> ${__OUTPUT_PATH}/Trim_Galore_QC/Summary_Trim_Galore_Report.log
		echo "=====================================================================================================" >> ${__OUTPUT_PATH}/Trim_Galore_QC/Summary_Trim_Galore_Report.log 
		echo " " >> ${__OUTPUT_PATH}/Trim_Galore_QC/Summary_Trim_Galore_Report.log
	done
	
	
	#Picard
	#xx=$(find -name "Marked_dup_metrics.txt")
	#for x in ${xx[*]}; do echo $x >> Summary_Duplication.log ; cat $x | awk '{if(NR==8) print $0}' >> Summary_Duplication.log ; cat $x | awk -v OFS="\t" '{if(NR==8) print "Input:",$4,"Output:",$4-$8}' >> Summary_Duplication.log ; done
	}

RUN_FAST_QC(){
####	RUN_FAST_QC
####	Usage: RUN_FAST_QC $INPUT_DATA_DIR
########################################################################
### FASTQC Output DIR setting ...
	echo "[$(date "+%Y-%m-%d %H:%M")]-----------------------RUN_FAST_QC"
	local Output_fastqc=${__INPUT_PATH}/fastqc
	DIR_CHECK_CREATE ${Output_fastqc}
	cd ${__INPUT_PATH}
	
	for fastq_file in ${__FASTQ_DIR_R1[*]}
	do
	echo "fastqc -q -o ${Output_fastqc} $fastq_file"
	fastqc -t ${THREADS} -o ${Output_fastqc} ${fastq_file} &
	done
	
	for fastq_file in ${__FASTQ_DIR_R2[*]}
	do
	echo "fastqc -q -o ${Output_fastqc} $fastq_file"
	fastqc -t ${THREADS} -o ${Output_fastqc} ${fastq_file} &
	done
	echo "[$(date "+%Y-%m-%d %H:%M")]---------RUN_FAST_QC-----COMPLETED!"
	echo " "
	
	#echo "cd ${Output_fastqc}"
	#cd ${Output_fastqc}
	#if [ -f multiqc_report.html ];then
	#echo "multiqc *fastqc.zip --ignore *.html"
	#multiqc *fastqc.zip --ignore *.html
	#fi
	}

RUN_READLINE(){
	#### USAGE: RUN_READLINE $INPUT $OUTPUT
	CHECK_arguments $# 2
	echo "READ_LINE"
	while read -a line
	do
		if [ ${line[6]} \> 4.0 ]; then
			#echo ${line[6]}
			echo ${line[*]} >> $2 # OUTPUT file
		fi
	done < $1   #INPUT file
	}

RUN_Read_Process_Data(){
	#### USAGE: RUN_READLINE $INPUT $OUTPUT
	CHECK_arguments $# 2
	echo "READ_LINE"
	while read -a line
	do
		if [ ${line[6]} \> 0.0 ]; then
			echo ${line[0]} ${line[1]} $(expr ${line[6]} + ${line[1]}) ${line[6]} >> $2 # OUTPUT file
		fi
	done < $1 #INPUT file
	}

RUN_awk_Extension_Data(){
	#### USAGE: RUN_awk_Extension_Data $INPUT $OUTPUT
	CHECK_arguments $# 2
	echo "READ_LINE"
	awk 'BEGIN{print "Don\47t Panic!"}'
	awk '$2-=100' OFS='\t' ${${CONTRO_FOLDER}}/${CONTRO_FILE: 2} | awk '$3+=100' OFS='\t' > ${OUT_FOLDER}/${CONTRO_FILE: 2}_ex100
	}

RUN_CHANGE_STR(){
	
	#!/usr/bin/env bash
# cookbook filename: suffixer
#
# rename files that end in .bad to be .bash
for FN in *.bad
do
mv "${FN}" "${FN%bad}bash"
done
	}

RUN_CHECK_SEQ(){
#### Check a specific seq in fastq.gz
####	1.Raw_data 2.Seq
	cd $1   #### Entering the Raw_Data_DIR 
	OUT_REPORT="$1/seq_check_report"
	DIR_CHECK_CREATE $OUT_REPORT
	CHECK_SEQ=$2
	
	filename="${OUT_REPORT}/same_seq_counts.txt"
#### Head for oupput report	
	echo "Checing Sequence: $CHECK_SEQ " >>$filename
	echo "SAME_Seq_LINES  TOTAL_LINES  FILE_NAME" >>$filename
	
	echo "Detecting all files ..."
	DIRLIST_R="$( find -name "*.fastq.gz"| xargs)"
	echo "Saving the DIR of all fastq.gz files ..."

	for FILE_DIR in $DIRLIST_R
	do
	echo "gunzip -c ${FILE_DIR: 2}"
	gunzip ${FILE_DIR: 2}
####	Check GATCGGAAGCG
	TOTAL_LINES=$(wc -l ${FILE_DIR: 2: -3})
	LINES=$(grep $CHECK_SEQ ${FILE_DIR: 2: -3} | wc -l)
	
	echo ""
	echo "$LINES	$TOTAL_LINES" >>$filename
	echo "gzip ${FILE_DIR: 2: -3}"
	
	gzip ${FILE_DIR: 2: -3}
	
	done
}

RUN_SELECT_SEQ_SAM(){
	#### Usage: RUN_SELECT_SEQ_SAM $INPUT_SAM_FOLDER ${INPUT_NAME} ${NAME_EXTENSION} (Such as _unaligned for xxx_unaligned)
	#### Given a sam file DIR
	local INPUT_NAME=${1}
	local NAME_EXTENSION=${3}
	local INPUT_SAM_FOLDER=${__OUTPUT_PATH}/${INPUT_NAME}/bowtie2_results
	local OUTPUT_RNAME=${2}
	CHECK_arguments $# 3
	
	echo "Entering one Library of SAM_DATA_FOLDER: $INPUT_SAM_FOLDER"
	cd ${INPUT_SAM_FOLDER}
	local INPUT_SAM=${1}${3}.sam
	local SORT_BAM=${1}${3}\_sorted.bam
	#local SORT_SAM=$INPUT_NAME\_sorted.sam
	
	if [ ! -e $SORT_BAM ];then
	echo "samtools sort -@ 4 -o ${SORT_BAM} -O BAM ${INPUT_SAM}"
	samtools sort -@ 4 -o ${SORT_BAM} -O BAM ${INPUT_SAM}
	
	echo "Create a BAI INDEX: samtools index -b ${SORT_BAM}"
	samtools index -b ${SORT_BAM}
	fi 
	
	echo "Only output alignment with the ref: ${OUTPUT_RNAME}"
	samtools view -h -b ${SORT_BAM} ${OUTPUT_RNAME} -o ${OUTPUT_RNAME}.bam
	
	echo "samtools view -@ 4 -h ${SORT_BAM} ${OUTPUT_RNAME} -o ${OUTPUT_RNAME}.sam"
	samtools view -h ${SORT_BAM} ${OUTPUT_RNAME} -o ${OUTPUT_RNAME}.sam
	
	echo "samtools sort -n -o ${OUTPUT_RNAME}.bam -O BAM ${OUTPUT_RNAME}.sam"
	samtools sort -@ 4 -n -o ${OUTPUT_RNAME}.bam -O BAM ${OUTPUT_RNAME}.sam
	samtools sort -@ 4 -n -o ${OUTPUT_RNAME}.sam -O SAM ${OUTPUT_RNAME}.sam
	
	#### Single End reads
	#bedtools bamtofastq -i $OUTPUT_RNAME.bam -fq $INPUT_SAM_FOLDER/$OUTPUT_RNAME\_R1.fastq
	
	#### Pair Ends reads
	echo "bedtools bamtofastq -i ${OUTPUT_RNAME}.bam  -fq ${INPUT_SAM_FOLDER}/${OUTPUT_RNAME}\_R1.fastq  -fq2 ${INPUT_SAM_FOLDER}/${OUTPUT_RNAME}\_R2.fastq"
	bedtools bamtofastq -i ${OUTPUT_RNAME}.bam  -fq ${INPUT_SAM_FOLDER}/${OUTPUT_RNAME}\_R1.fastq  -fq2 ${INPUT_SAM_FOLDER}/${OUTPUT_RNAME}\_R2.fastq
	
	#rm *.bam

	}

RUN_REMOVE_SEQ(){
## USAGE:	RUN_REMOVE_SEQ ${__INPUT_SAMPLE_DIR_List[i]}
#### Check a specific seq in fastq.gz
####	1.Raw_data 2.Seq
local bbmap=${Tools_DIR}/bbmap
local REMOVE_SEQ=~/cloud_research/PengGroup/XLi/Raw_Data/Haihui/CD8-HP/DNase_seq/Adapter_Remove/TruSeq_Adapter_Index_5.fq
local OUTPUT_NAME=${__INPUT_PATH}/Adapter_Removed/${1}
DIR_CHECK_CREATE ${OUTPUT_NAME}
local KERS=${2}
########################################################################
echo ""
local DIRLIST_gz="$( find -name "*.fastq.gz" | sort -n | xargs)"

	if [ -n "${__FASTQ_DIR_R1[*]}" -a -n "${__FASTQ_DIR_R2[*]}" ]
	then
	echo "Pair End."
	echo 
	${bbmap}/bbduk.sh in1=${__FASTQ_DIR_R1[0]} in2=${__FASTQ_DIR_R2[0]} out1=$OUT/unmatched_R1.fastq.gz out2=$OUT/unmatched_R2.fastq.gz outm1=$OUT/matched_R1.fastq.gz outm2=$OUT/matched2_R2.fastq.gz ref=$REMOVE_SEQ k=$KERS hdist=0 stats=stats.txt
	echo ""
	#### concordantly pair output
	#echo "bowtie2 -p $THREADS --end-to-end --very-sensitive -k 1 --no-mixed --no-discordant --no-unal -x $BOWTIEINDEXS -1 ${__FASTQ_DIR_R1[0]} -2 ${__FASTQ_DIR_R2[0]} -S ${OUTPUT_BOWTIE2} --un-conc-gz ${OUTPUT_BOWTIE2_FOLDER}/un_conc_aligned_R%.fastq.gz"
	#bowtie2 -p $THREADS --end-to-end --very-sensitive -k 1 --no-mixed --no-discordant --no-unal -x $BOWTIEINDEXS -1 ${__FASTQ_DIR_R1[0]} -2 ${__FASTQ_DIR_R2[0]} -S ${OUTPUT_BOWTIE2} --un-conc-gz ${OUTPUT_BOWTIE2_FOLDER}/un_conc_aligned_R%.fastq.gz
	# using un concordantly pair-ends do bowtie2 again.
	#echo "bowtie2 -p $THREADS --end-to-end --very-sensitive -k 1 --no-mixed --no-discordant --no-unal -x ${BOWTIEINDEXS} -1 $(echo ${__FASTQ_DIR_R1[*]} | tr " " ",") -2 $(echo ${__FASTQ_DIR_R2[*]} | tr " " ",") -S ${OUTPUT_BOWTIE2}"
	#bowtie2 -p $THREADS --end-to-end --very-sensitive -k 1 --no-mixed --no-discordant --no-unal -x ${BOWTIEINDEXS} -1 $(echo ${__FASTQ_DIR_R1[*]} | tr " " ",") -2 $(echo ${__FASTQ_DIR_R2[*]} | tr " " ",") -S ${OUTPUT_BOWTIE2}
	
	else
	echo "Single End."
	echo "bowtie2 -p $THREADS --no-unal --non-deterministic -x $BOWTIEINDEXS -U $(echo ${__FASTQ_DIR_R1[*]} | tr " " ",") -S $OUTPUT_BOWTIE2"
	${bbmap}/bbduk.sh in1=${__FASTQ_DIR_R1[0]} in2=${__FASTQ_DIR_R2[0]} out1=$OUT/unmatched_R1.fastq.gz out2=$OUT/unmatched_R2.fastq.gz outm1=$OUT/matched_R1.fastq.gz outm2=$OUT/matched2_R2.fastq.gz ref=$REMOVE_SEQ k=$KERS hdist=0 stats=stats.txt
	fi

	echo ""




echo "nohup $bbmap/bbduk.sh in1=${__FASTQ_DIR_R1[0]} in2=${__FASTQ_DIR_R2[0]} out1=$OUT/unmatched_R1.fastq.gz out2=$OUT/unmatched_R2.fastq.gz outm1=$OUT/matched_R1.fastq.gz outm2=$OUT/matched2_R2.fastq.gz ref=$REMOVE_SEQ k=$KERS hdist=0 stats=stas.txt"
nohup $bbmap/bbduk.sh in1=${__FASTQ_DIR_R1[0]} in2=${__FASTQ_DIR_R2[0]} out1=$OUT/unmatched_R1.fastq.gz out2=$OUT/unmatched_R2.fastq.gz outm1=$OUT/matched_R1.fastq.gz outm2=$OUT/matched2_R2.fastq.gz ref=$REMOVE_SEQ k=$KERS hdist=0 stats=stats.txt

########################################################################
	}

#RUN_Sam2Wig

RUN_bed2fastq(){
#### Usage: RUN_bed2fastq $1 $2($1 = Input_Name, $2 = FRAGMENT_SIZE) 
#	#RUN_bed2fastq ${__INPUT_SAMPLE_DIR_List[i]} ${SPECIES}
CHECK_arguments $# 2

local INPUT_PATH=${__INPUT_PATH}
local OUT_PATH=${__OUTPUT_PATH}/Associated_fastq
local INPUT_NAME=${1/.bed/}
local SPECIES=${2}
########################################################################
DIR_CHECK_CREATE ${OUT_PATH}

### Find Input File

cd ${__INPUT_PATH}
local IN_FILES="$( find -name "*${INPUT_NAME}*.bed" | sort -n | xargs)"

local k=0
for in_files in ${IN_FILES}
do
	IN_FILES[k]="${__INPUT_PATH}/${in_files: 2}"
	k=`expr $k + 1`
done
echo "Saving Bed INPUT File as ${IN_FILES[*]}"
### Find Input File

case ${SPECIES} in
	"mm9")
	echo "Reference SPECIES is ${SPECIES}"
	local FA_SEQUENCE=~/cloud_research/PengGroup/XLi/Annotation/UCSC/Mouse_Genome/MM9/mm9.fa
	;;
	"mm10") 
	echo "Reference SPECIES is ${SPECIES}"
	local FA_SEQUENCE=~/cloud_research/PengGroup/XLi/Annotation/UCSC/Mouse_Genome/MM10/mm10.fa
	;;
	"hg19")
	echo "Reference SPECIES is ${SPECIES}"
	local FA_SEQUENCE=~/cloud_research/PengGroup/XLi/Annotation/UCSC/Human_Genome/HG19/hg19.fa
	;;
	"hg38")
	echo "Reference SPECIES is ${SPECIES}"
	local FA_SEQUENCE=~/cloud_research/PengGroup/XLi/Annotation/UCSC/Human_Genome/HG38/hg38.fa
	;;
	"dm6") 
	echo "Reference SPECIES is ${SPECIES} Not Setup Yet!"
	;;
	*)
	echo "ERR: Did Not Find Any Matched Reference...... Exit"
	exit
	;;
esac

### extension
local yesno='yes'
#awk '$2-=100' OFS='\t' ${input_file} | awk '$3+=100' OFS='\t' > ${input_file}_ex
#awk -F',' 'BEGIN {OFS='\t'} {$4 = "\tUnion_peaks_"(NR); print}' 28459_Union_peaks.bed >28459_Union_peaks_x.bed
#cd ${OUT_PATH}

cat ${IN_FILES} | awk -v OFS="\t" '{ if ($1!="chr") print $1,$2,$3,"id"NR}' > ${IN_FILES}.4

for input_file in ${IN_FILES[*]}
do
	echo "bedtools getfasta -name -fi ${FA_SEQUENCE} -bed ${input_file}.4 -fo ${INPUT_NAME}.fastq"
	bedtools getfasta -fi ${FA_SEQUENCE} -bed ${input_file}.4 -fo ${OUT_PATH}/${INPUT_NAME}.fastq -name
done



	}

RUN_bam2bedpe(){
	#### Usage: RUN_Sam2Wig $1 $2 ($1 = Input_Name, $2 = FRAGMENT_SIZE)
CHECK_arguments $# 2
local INPUT_PATH=${__INPUT_PATH}/${1}/bowtie2_results/${1}
local OUT_PATH=${__OUTPUT_PATH}/${1}
local FRAGMENT_SIZE=${2}
########################################################################

local SICER="/home/lxiang/Software/SICER1.1/SICER"
local EXEDIR="${SICER}/extra/tools/wiggle"
local WINDOW_SIZE=200
local SPECIES=mm10


#samtools view ${INPUT_PATH}.sam -Sb | bamToBed -i stdin > ${INPUT_PATH}.bed

bamToBed -i ${INPUT_PATH}.bam > ${INPUT_PATH}.bed

sh $EXEDIR/bed2wig.sh ${__INPUT_PATH}/${1}/bowtie2_results ${1} ${WINDOW_SIZE} ${FRAGMENT_SIZE} ${SPECIES}
	
	}

RUN_Sam2Wig(){
	#### Usage: RUN_Sam2Wig $1 $2 ($1 = Input_Name, $2 = FRAGMENT_SIZE)
CHECK_arguments $# 2
local INPUT_PATH=${__INPUT_PATH}/${1}/bowtie2_results/${1}
local OUT_PATH=${__OUTPUT_PATH}/${1}
local FRAGMENT_SIZE=${2}
########################################################################

local SICER="/home/lxiang/Software/SICER1.1/SICER"
local EXEDIR="${SICER}/extra/tools/wiggle"
local WINDOW_SIZE=200
local SPECIES=mm10


#samtools view ${INPUT_PATH}.sam -Sb | bamToBed -i stdin > ${INPUT_PATH}.bed

bamToBed -i ${INPUT_PATH}.bam > ${INPUT_PATH}.bed

sh $EXEDIR/bed2wig.sh ${__INPUT_PATH}/${1}/bowtie2_results ${1} ${WINDOW_SIZE} ${FRAGMENT_SIZE} ${SPECIES}
	
	}

##END OF FUNDEMENTAL FUNCTIONS

######################################

########################################################################

######################################

##	MODOLES
########################################################################
########################################################################
## Alignor
RUN_Search_Copy(){
	#http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml
	### #RUN_BOWTIE2 ${__INPUT_SAMPLE_List[i]} ${SPECIES} "Pre_Tfh_Th1" ${Data_Provider} 'no' &
	local INPUT_NAME=${1/Sample_/}
	local SPECIES=${2}
	local PROJECT_NAME=${3}
	local Data_Provider=${4}

}

RUN_SAM2FASTQ(){
	## Usage : RUN_SAM2FASTQ ${__INPUT_SAMPLE_List[i]}  ${FILE_TYPE}
	
	CHECK_arguments $# 2
	local INPUT_NAME=${1/Sample_/}
	local FILE_TYPE=${2}
	
	DIR_CHECK_CREATE ${__OUTPUT_PATH}/Raw_Fastq
	
	cd ${__INPUT_PATH}
	OUT_PATH=${__OUTPUT_PATH}/Raw_Fastq/${INPUT_NAME}
	echo "Enter ${__INPUT_PATH}, search ${FILE_TYPE}, convert to fastq.gz"
	
	case ${FILE_TYPE} in
	"cram")
	x=$(find -name "*${INPUT_NAME}*short*cram") ## *.short*cram is what we need.
	echo "samtools collate -@ 16 -u -O ${x} | samtools fastq -@ 16 -1 ${OUT_PATH}_R1.fastq.gz -2 ${OUT_PATH}_R2.fastq.gz"
	samtools sort -@ 4 -u -n ${x} | samtools fastq -@ 4 -1 ${OUT_PATH}_R1.fastq.gz -2 ${OUT_PATH}_R2.fastq.gz -0 /dev/null -s /dev/null -n 	
	;;
	*)
	echo "${FILE_TYPE} Go with default Setting."
	x=$(find -name "*${INPUT_NAME}*.${FILE_TYPE}")
	echo "samtools view -h -q 60 ${x} | samtools sort -@ 4 -n -u | samtools fastq > ${OUT_PATH}_R1.fastq.gz"
	samtools view -h -q 60 ${x} | samtools sort -@ 4 -n -u | samtools fastq > ${OUT_PATH}_R1.fastq.gz
	#exit
	;;
	esac
	
	}

RUN_BWA_mem(){
	#http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml
	### #RUN_BWA_mem ${__INPUT_SAMPLE_List[i]} ${SPECIES} "Pre_Tfh_Th1" ${Data_Provider} 'no' &
	local INPUT_NAME=${1/Sample_/}
	local SPECIES=${2}
	local PROJECT_NAME=${3}
	local Data_Provider=${4}
	local just_align_yesno=${5}  ## This option is limit bowtie2 with only basic functions.
	
	CHECK_arguments $# 5
	echo ""
	echo "[$(date "+%Y-%m-%d %H:%M")]------------------------RUN_BWA......."

	local Left_Trim=0
	local Right_Trim=0
	local Map_Quality=10   #A mapping quality of 10 or less indicates that there is at least a 1 in 10 chance that the read truly originated elsewhere.
	#Mapping quality: higher = more unique
	
	
	#### OUTPUT FORMAT
	local OUTPUT_BOWTIE2_FOLDER="${__OUTPUT_PATH}/BWA_Results/${SPECIES}/${INPUT_NAME}"
	DIR_CHECK_CREATE ${OUTPUT_BOWTIE2_FOLDER}
	
	case ${SPECIES} in
		"hg")
		echo "------------------------------Reference SPECIES is ${SPECIES}"
		local BOWTIEINDEXS="/ghds/shared/ref/genome.fa"
		;;
		"nonhg") 
		echo "------------------------------Reference SPECIES is ${SPECIES}"
		local BOWTIEINDEXS="/ghess/groups/algorithms/ref/non_human_contaminants/raw_genomes/Genomev3/All_16_genomes.fa.gz"
		;;
		"nonhg_test")
		echo "------------------------------Reference SPECIES is ${SPECIES}"
		local BOWTIEINDEXS="/ghess/groups/algorithms/ref/non_human_contaminants/raw_genomes/Genomev1_test/Gtest_hg_chicken_yeast_covid.fa.gz"
		;;
		*)
		echo "ERR: Did Not Find Any Matched Reference...... Exit"
		exit
		;;
	esac
########################################################################
	
	local OUTPUT_BOWTIE2="${OUTPUT_BOWTIE2_FOLDER}/${INPUT_NAME}.bam"
	cd ${OUTPUT_BOWTIE2_FOLDER}


	if [ -n "${__FASTQ_DIR_R1[*]}" -a -n "${__FASTQ_DIR_R2[*]}" ]
	then
		echo "--------------------------------------------Pair End Mode"
		#verbosity level: 1=error, 2=warning, 3=message, 4+=debugging [3]
		echo "bwa mem -p -t ${THREADS} -M ${BOWTIEINDEXS} -v 3 ${__FASTQ_DIR_R1[0]} ${__FASTQ_DIR_R2[0]} > $OUTPUT_BOWTIE2"
		bwa mem -p -t ${THREADS} -M ${BOWTIEINDEXS} -v 3 ${__FASTQ_DIR_R1[0]} ${__FASTQ_DIR_R2[0]} | grep -v "hg38" | samtools view -bS -q ${Map_Quality} > ${OUTPUT_BOWTIE2}
		#bwa mem -p -t ${THREADS} -M ${BOWTIEINDEXS} -v 3 ${__FASTQ_DIR_R1[0]} ${__FASTQ_DIR_R2[0]} | samtools view -bS -q ${Map_Quality} > ${OUTPUT_BOWTIE2}
		#echo "End of One bwa Mapping"
	else
		echo "------------------------------Single End Mode."
		echo "bwa mem -p -t ${THREADS} -M ${BOWTIEINDEXS} -v 3 ${__FASTQ_DIR_R1[0]} ${__FASTQ_DIR_R2[0]} > $OUTPUT_BOWTIE2"
		bwa mem -p -t ${THREADS} -M ${BOWTIEINDEXS} -v 3 ${__FASTQ_DIR_R1[0]} > ${OUTPUT_BOWTIE2} | grep -v "hg38" | samtools view -bS -q ${Map_Quality} > ${OUTPUT_BOWTIE2}
#		bwa mem -p -t ${THREADS} -M ${BOWTIEINDEXS} -v 3 ${__FASTQ_DIR_R1[0]} > ${OUTPUT_BOWTIE2} | samtools view -bS -q ${Map_Quality} > ${OUTPUT_BOWTIE2} 
		echo "End of One BWA Mapping"
	fi
	
########################################################################
### Then clear sam file.
	if [ -f ${OUTPUT_BOWTIE2_FOLDER}/${INPUT_NAME}_sorted.bam ];then
		echo "NULL: samtools view -@ ${THREADS} -h -b ${OUTPUT_BOWTIE2} > ${OUTPUT_BOWTIE2_FOLDER}/${INPUT_NAME}.bam"
		samtools sort -@ ${THREADS} ${OUTPUT_BOWTIE2} -o ${OUTPUT_BOWTIE2_FOLDER}/${INPUT_NAME}_sorted.bam
		samtools index -@ ${THREADS} -b ${OUTPUT_BOWTIE2_FOLDER}/${INPUT_NAME}_sorted.bam
		#samtools sort ${x}.sam | samtools view -h -q ${Map_Quality} -C - > ${x}.mapq_${Map_Quality}.cram
		#rm ${OUTPUT_BOWTIE2}
	fi
	
########################################################################
	local just_align_yesno=${5}
	case ${just_align_yesno} in
	"yes")
	echo "------------------------------Make Align Stop here, just need alignment!"
	echo ""
	return 0 ;;
	"no")
	echo "Continue!" ;;
	*)
	echo "ERR: Did Not Find Any Matched Reference...... Exit"
	exit;;
	esac
########################################################################	

	echo " "
	echo "One BWA is Completed!"
}

RUN_Count_Non_hg38(){
	
	local INPUT_NAME=${1/Sample_/}
	local DATA_TYPE=${2}
	
	TEST_GENOME=(
	#hg38 # human
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
	oreNil2 # Nile Tilapia fis
	)
	
	CHECK_arguments $# 2
	echo ""
	echo "[$(date "+%Y-%m-%d %H:%M")]------------------------RUN_BWA......."
	
	cd ${__INPUT_PATH}
	xx=$(find -name "*${INPUT_NAME}*.${DATA_TYPE}")

	
	#### OUTPUT FORMAT
	local OUTPUT_FOLDER="${__OUTPUT_PATH}/counting_results"
	DIR_CHECK_CREATE ${OUTPUT_FOLDER}
	
	EXCLUDED_GENOME="hg38"
	OUTPUT="${xx:-4:}.non${EXCLUDED_GENOME}.sam"
	echo "First output non ${EXCLUDED_GENOME}: "
	echo "	samtools view ${xx} | grep -v ${EXCLUDED_GENOME} > ${OUTPUT}"
	samtools view ${xx} | grep -v ${EXCLUDED_GENOME} > ${OUTPUT}
		
	for genome in ${TEST_GENOME[*]}
	do 
		echo "Count reads for ${genome}"
		PATH_COUNT="${OUTPUT_FOLDER}/${INPUT_NAME}_${genome}.stats.log"
		echo " " >> ${PATH_COUNT}
		echo "${genome}" > ${PATH_COUNT}
		grep "${genome}" ${OUTPUT} | wc -l >> ${PATH_COUNT} &
	done
	
	}
## END OF MODULES

######################################

########################################################################

######################################

##BASIC FUNCTIONS


########################################################################
########################################################################
RUN_AWK(){
	### Using this to generate (n)x(n+3) matrix
	head -n -1   #skip last line
	xx=$(find -name "*.matrix")
	Resolution=10000
	
	for x in ${xx[*]}; do echo ${x: 9:-7}; done
	
	for x in ${xx[*]}; do chr=${x: 9:-7} ; echo ${chr}; cat ${x} | awk -v chr="${chr}" \
	-v res=${Resolution} '{print chr"\t"(NR-1)*res"\t"(NR*res)"\t"$0}' | gzip > ${x: :-7}.TopDom.gz & done
	
	
	xx=$(find -name "*.domain")
	Output_Name=DKO_CD8_TADs
	for x in ${xx[*]}; do cat ${x} >> ${Output_Name}.bed ; done
	cat ${Output_Name}.bed | sort -k1,1 -k2,2n > ${Output_Name}_sort.bed
	
	python ~/cloud_research/PengGroup/XLi/Python_tools/Bed_Correction.py -i ${Output_Name}.bed -s ~/cloud_research/PengGroup/XLi/Annotation/UCSC/genome_sizes/mm9.chrom.sizes
	
	
	cat WT_CD8_TADs_res_10k_w5.boundary.bed | awk -v ext=50000 '{print $1"\t"$2-ext"\t"$3+ext"\t"$4}' > WT_CD8_TADs_res_10k_w5.boundary_ex50k.bed
	
	sed -i 's/original/new/g' file.txt
	
	
	## TopDom
	## calculate row sum
	for x in ${xx[*]}; do zcat ${x} | awk -v OFS="\t" '{if (NR>0) { sum=0; for (i=4; i<=NF; i++) {sum+=$i} print $1,$2,$3,sum}}' > ./chr_wide_interaction/${x:2:-3}_chr_wide.bed ; break; done
	## calculate column sum
	for x in ${xx[*]}; do cat ${x} | awk '{sum+=$4} END {print sum}'; done
	}

REMOVE_REDUNDANCY_PICARD(){
	## Remove Redundancy by Picard
	### for xx in $(find -name *Marked_dup_metrics.txt); do echo $xx; sed -n '7,8p' $xx | cut -f 3,9; done
	
	CHECK_arguments $# 1
	echo "[$(date "+%Y-%m-%d %H:%M")]--------Remove Redundancy by Picard"
	local INPUT_FILE_NAME=${1}
	
	echo "Entering Input Directory"
	cd ${__INPUT_PATH}
	echo "Searching File with keyword: $INPUT_FILE_NAME"
	local Mapping_File_Set="$( find -name "*${INPUT_FILE_NAME}*bam*" | sort -n | xargs)"
	
	for INPUT_FILE_Full in ${Mapping_File_Set[*]}
	do
		local INPUT_FILE=${INPUT_FILE_Full} #${INPUT_FILE_Full/.bam/}
		echo "${INPUT_FILE}"
		if [ ! -f ${INPUT_FILE}_Dup_Removed.bam ];then
			if [ ! -f ${INPUT_FILE}_sorted.bam ];then
			echo "samtools sort -l 1 -o ${INPUT_FILE}_sorted.bam ${INPUT_FILE_Full}"
			
			#samtools sort -n -l 1 -o ${INPUT_FILE}_sorted.bam ${INPUT_FILE_Full}  ## Sort By Name
			samtools sort -l 1 -o ${INPUT_FILE}_sorted.bam ${INPUT_FILE_Full}  ## Sort By leftmost coordinates
			
			echo "rm ${INPUT_FILE}.bam"
			rm ${INPUT_FILE}.bam
			
			fi
			echo "picard MarkDuplicates I=${INPUT_FILE}_sorted.bam O=${INPUT_FILE}_Dup_Removed.bam \
			M=${INPUT_FILE}_Marked_dup_metrics.txt REMOVE_DUPLICATES=true ASSUME_SORT_ORDER=queryname CREATE_INDEX=true"
			
			picard MarkDuplicates I=${INPUT_FILE}_sorted.bam O=${INPUT_FILE}_Dup_Removed.bam \
			M=${INPUT_FILE}_Marked_dup_metrics.txt REMOVE_DUPLICATES=true ASSUME_SORT_ORDER=coordinate #CREATE_INDEX=true
			
			## for shang.
			#java -jar /opt/tools/picard.jar MarkDuplicates I=${INPUT_FILE}_sorted.bam O=${INPUT_FILE}_Dup_Removed.bam \
			M=${INPUT_FILE}_Marked_dup_metrics.txt REMOVE_DUPLICATES=true ASSUME_SORT_ORDER=queryname CREATE_INDEX=true
			
			echo "rm ${INPUT_FILE}_sorted.bam"
			rm ${INPUT_FILE}_sorted.bam
		fi
	done
	echo "[$(date "+%Y-%m-%d %H:%M")]Remove Redundancy-------Comepleted!"
	}

FUNC_TEST(){
	local AAA=$1
	local BBB=$2
	CHECK_arguments $# 2
	echo "function AAA is $AAA"
	read -p "Input a number from keyboard." Read_key
	#echo "Your input is: ${Read_key}"
	printf "Your input is: %s ${Read_key} \n"
} 

FUNC_BED_Sort(){
	CHECK_arguments $# 2
	Input_NAME=${1}
	File_Type=${2}
	
	if [ ! -f ${Input_NAME}_sorted.${File_Type} ];then
	echo "sort -k1,1 -k2,2n ${Input_NAME}.${File_Type} > ${Input_NAME}_sorted.${File_Type}"
	sort -k1,1 -k2,2n ${Input_NAME}.${File_Type} > ${Input_NAME}_sorted.${File_Type}
	
	echo "After sort, delete oringinal file"
	rm ${Input_NAME}.${File_Type}
	fi
	
	
	}

FUNC_CHOOSE_EMAIL_ALERT(){
	local default="[0 1 NO YES]"
	local answer=""
	
	read -p "Cancel Email Alert?" answer #$0 > $1 
	#### read -s (silent input)
	printf "%b" "\n"
	local iteration_num=0
	
	while [[ ${iteration_num} -lt 3 ]]
	do
		local refer=$(grep -io $answer <<< ${default}) ###-o only match part -i ignore-case
		if [ -z ${refer} ];then
		echo "Unexpected Answer ${answer}"
		read -p "Try Again. (Yes or No)  " answer
		iteration_num=$(expr ${iteration_num} + 1)
		elif [[ $(grep $refer <<< "1YES") = "1YES" ]];then
		echo "No Email Alert Confirmed."
		return 1 
		break
		else
		echo "No Alert Confirmed."
		return 0
		break
		fi
	done
}

EMAIL_ME(){
	CHECK_arguments $# 2
	echo "Start at ${1} " | mail -s "Project: + ${2} Finished" lux@gwu.edu
	}

CHECK_arguments(){
#### Usage: CHECK_arguments $# <NUM_arguments>
#### $# gives the number of command-line arguments.
#### <NUM_arguments> is the right number of arguments.
	if [ "$1" -lt $2 ];then 
	echo "error: too few arguments, you provided $1 arguments, $2 is required."
	exit 1
	fi
	} 

DIR_CHECK_CREATE(){
### Saving DIR Check and Create
#### Usage: DIR_CHECK_CREATE $@
	local Dirs=$@
	for solo_dir in ${Dirs[*]}
	do
		if [ ! -d $solo_dir ];then
			echo "Dir check and create is $solo_dir"
			mkdir -p $solo_dir
		else
			echo "$solo_dir Exists."
		fi
	done
	}

FUNC_BACKUP_FOLDER (){
### Saving DIR Check and Create
	echo "Dir Under backup are: $@"
	local $BP_DIR=back_up
	DIR_CHECK_CREATE ${BP_DIR}
	
	for filename in $@
	do
		cp ${filename} ${BP_DIR}/${filename}_bp
	done
	
	echo "Backup Finished."
	}

FUN_GZIP(){
####	run gzip for all files under input DIR
####	Usage: 
########################################################################
### gzip
	cd ${__INPUT_PATH}
########################################################################	
    echo "Convert all matched*.fastq to fastq.gz"
	local DIRLIST_R="$( find -name "*.fastq"| xargs)"

	for FILE_DIR in ${DIRLIST_R}
	do
	echo "gzip ${__INPUT_PATH}/${FILE_DIR: 2}"
	gzip ${__INPUT_PATH}/${FILE_DIR: 2}
	done
	
	
	#To create a tar.gz archive from a given folder you can use the following command
	tar -zcvf tar-archive-name.tar.gz source-folder-name

	#This will compress the contents of source-folder-name to a tar.gz archive named tar-archive-name.tar.gz

	#To extract a tar.gz compressed archive you can use the following command
	tar -zxvf tar-archive-name.tar.gz

	#This will extract the archive to the folder tar-archive-name.

	#To Preserve permissions
	tar -pcvzf tar-archive-name.tar.gz source-folder-name

	#Switch the ‘c’ flag to an ‘x’ to extract (uncompress).
	tar -pxvzf tar-archive-name.tar.gz
	
	
	}

FUNC_CLEAN(){
####Usage: RUN_CLEAN $Directory $File type.
	CHECK_arguments $# 2
	local Dir=$1
	local File_type=$2
	if [[ -n ${Dir} && -n ${File_type} ]]; then
	cd ${Dir}
		if (( ! $? )); then rm *${File_type}; fi
	else echo "ERR: Empty. Exit"
	fi
	}

FUNC_Check_on_Bed (){
	####FUNC_Check_on_Bed $Filename 
	#### Make Sure Bed format has 4 columns, if not, add one more columns with row number.
	CHECK_arguments $# 1
	local File_Path=${1}
	local Num_Rows=$(head -n1 ${File_Path} | sed 's/\t/\n/g' | wc -l)
	if [ ${Num_Rows} -lt 4 ]
	then
		echo "Input Bed File does not have a naming columns, automatically assign by row number"
		awk -i inplace -v OFS="\t" '{print $1,$2,$3,"id_"NR}' ${File_Path}
	fi
}

FUNC_CUT_Rows (){
	####FUNC_CUT_Rows $Filename $start $end
	#### Normally sam file format, '1,24d' is removing all header.
	CHECK_arguments $# 3
	local File_type='sam'
	local File_Path=${__INPUT_PATH}/${1}.${File_type}
	local start=${2}
	local end=${3}
	sed -n '${start},${end}d' ${File_Path} > ${__INPUT_PATH}/${1}_Row_${start}_${end}.${File_type}
	echo ""
}

FUNC_Max(){
## Usage: Larger_value = $(RUN_Max $num_a $num_b)
	CHECK_arguments $# 2
	if [ $1 -gt $2 ]
	then
		echo $1
	else
		echo $2
	fi
	}
##END OF BASIC FUNCTIONS
########################################################################
########################################################################

IDR_of_All (){
	xx=$(find -name "RPKM*.rpkm")
	for x in ${xx[*]}; do  paste 36818_Union_DNase_Peaks_14_Reps.bedpe $x | awk -v OFS="\t" '{print $1,$2,$3,$4,$5,".",0,0,0,int(($3-$2)/2)}' > ${x::-5}.bed; done
	
	
	
	xx=$(find -name "RPKM*.rpkm")
	local k=0
	for x in ${xx[*]}
	do 
	List_For_IDR[k]=${x}
	k=$(expr $k + 1)
	done
	
	for (( i = 0; i <= $(expr ${#List_For_IDR[*]} - 1); i++ ))
	do 
		for (( j = i; j <= $(expr ${#List_For_IDR[*]} - 1); j++ ))
			do 
				echo "$i and $j"
				idr 
			done
	done
	#for (( i = 0; i <= $(expr ${#List_For_IDR[*]} - 1); i++ )); do for (( j = i; j <= $(expr ${#List_For_IDR[*]} - 1); j++ )); do echo " " >> output.summary;echo "${List_For_IDR[i]} and ${List_For_IDR[j]}" >> output.summary; nohup idr --samples ${List_For_IDR[i]} ${List_For_IDR[j]} --rank score --input-file-type bed >> output.summary ; break;done;break; done
	}

# HELP INFORMATION
######################################
#${INPUT_FILE::-4}
##local INPUT_LABEL=${INPUT_NAME: 7:4}
##Skip out of Sample_ (7), and forward with 4 more digits.
########################################################################
#AWK
#  cat *.bed | sort -k1,1 -k2,2n | awk '{if($4=="domain") print $0}' > DKO_CD8_TAD_Domain.bed
#https://www.gnu.org/software/gawk/manual/gawk.html#Quoting
#In general, you can stop the shell from interpreting a metacharacter by escaping it with a backslash (\)
######################################
# echo "[$(date "+%Y-%m-%d %H:%M")]  <YOUR CONTENT>"

#Sed
### sed -i $'1i #chr\tstart\tend\tgene_id\tNum' 

## Some Out Dated Functions

#[1] https://stackoverflow.com/questions/10909685/run-parallel-multiple-commands-at-once-in-the-same-terminal
#[2]
#[3] 
