#!/bin/bash
#set -e	#### Terminating the script if any command exited with a nonzero exit status
set -u	#### prevents the error by aborting the script if a variable’s value is unset
set -o pipefail 	#### check on the p398 of book Bioinformatics Data Skills.
### functions.sh contains all modules and functions necessary in this pipeline, has to be together with run_main.sh
source ./Functions_xl.sh
## USAGE:
#	nohup bash run_main.sh "Process_NAME" > out.log &
########################################################################
## 06/19/2021
## By Xiang Li,
## xili@GH
## Version.beta
########################################################################
  #  means NEED MODIFICATION. "VERY IMPORTANT INFORMATION"
  ## means Title_level 1.
 ### means Title_level 2.
#### means comment.
########################################################################
## Pickup a NAME for this one time pipeline.
Process_NAME="ID1" #${1}

echo "-----------------------------------------------------------------"

echo "Import functions.sh Completed!"
echo "Your Pipeline Named ${Process_NAME} start at `date`"
Start_Date=`date`
echo "-----------------------------------------------------------------"
#			NEED MODIFICATION FOR DIFFERENT PROJECT
########################################################################
## GLOBAL VARIABLES
########################################################################
### INPUT DIRECTORY
__HOME_PATH="/ghess/groups/algorithms/projects/non_human_contamination"

__INPUT_PATH=/ghess/groups/algorithms/projects/non_human_contamination/test_sample_cram/cram
### Output DIRECTORY
__OUTPUT_PATH=/ghess/groups/algorithms/projects/non_human_contamination/test_sample_cram/cram
__INPUT_SAMPLE_SET=(
A017383551 # No contamination sample
A017383552 # No contamination sample
A017383651 # No contamination sample
A031438301 # Salmon
#A017381551
#A017381552
#DL19032524
#A0260122S1
#DL19032527
#A0186048MMC-02
#A0261917HP4-05
#A0261917PRE-05
)
#### Saving DIR Check and Create
DIR_CHECK_CREATE ${__OUTPUT_PATH} ${__INPUT_PATH}
########################################################################
#### Function of Email Alert, yes or no?
#FUNC_CHOOSE_EMAIL_ALERT
#Alert_email=$?
##	MAIN BODY
########################################################################
main() {
echo "-----------------------------------------------------------------"
echo "$(date "+%Y-%m-%d %H:%M") Start Processing....."
##....................................................................##
### Key Parameters
SPECIES='nonhg'
Data_Provider='Ravi'
Project_Name='Non_human_DNA'
##....................................................................##
### Download Raw Data
#FUNC_Download "ftp://ftp.admerahealth.com/19092-06" "19092-06"

##....................................................................##
### PARALLEL OPERTATION
echo "Parallel Operation have started"
#conda activate py3_lx
for (( i = 0; i <= $(expr ${#__INPUT_SAMPLE_SET[*]} - 1); i++ ))  ### Loop Operation [Ref.1]
do
	#break
	RUN_SAM2FASTQ ${__INPUT_SAMPLE_SET[i]} 'cram'
	
	PRE_READS_DIR ${__INPUT_PATH} ${__INPUT_SAMPLE_SET[i]} 'fastq.gz' 'Pair'
	RUN_BWA_mem ${__INPUT_SAMPLE_SET[i]} ${SPECIES} ${Project_Name} ${Data_Provider} 'yes' & pid=$!
	
	#break
	#RUN_Count_Non_hg38 ${__INPUT_SAMPLE_SET[i]}  "sam" & pid=$!
	#PRE_READS_DIR ${__INPUT_SAMPLE_SET[i]} 'fq.gz' 'SRA'
	#RUN_Trim_Galore_QC & pid=$!
	#RUN_FAST_QC & pid=$!
	#RUN_BOWTIE2 ${__INPUT_SAMPLE_SET[i]} ${SPECIES} ${Project_Name} ${Data_Provider} 'no' & pid=$!
	#REMOVE_REDUNDANCY_PICARD ${__INPUT_SAMPLE_SET[i]} & pid=$!
	PID_LIST+=" $pid";
	#break
#### FOR a full cycle, it must be clear its READS_DIR in the end.
	#echo "Unset DIR sets."
	#unset ${__FASTQ_DIR_R1} ${__FASTQ_DIR_R2}
done

echo "wait ${PID_LIST}....................................."
wait ${PID_LIST}
echo "Parallel Operation have finished";

for (( i = 0; i <= $(expr ${#__INPUT_SAMPLE_SET[*]} - 1); i++ ))  ### Loop Operation [Ref.1]
do
	break
	PRE_READS_DIR ${__INPUT_PATH} ${__INPUT_SAMPLE_SET[i]} 'fq.gz' 'Pair'
	RUN_BOWTIE2 ${__INPUT_SAMPLE_SET[i]} ${SPECIES} ${Project_Name} ${Data_Provider} 'no' & pid=$!
	#RUN_MACS2 ${__INPUT_SAMPLE_SET[i]} 'Null' ${Project_Name} ${SPECIES} ${Data_Provider} 'bampe' & pid=$!
	PID_LIST+=" $pid";
done
echo "wait ${PID_LIST}....................................."
wait ${PID_LIST}
echo "Parallel Operation have finished";

##....................................................................##
### Single Operation
	#RUN_CELLRANGER ${__INPUT_SAMPLE_DIR_List[15]} "Hdac" "mm10"
#echo "Single Operation have finished";

##....................................................................##
	echo "End Date: `date`"
	#echo -e "\a FINISHED ALERT !"
	
	#if [ ${Alert_email} == 0 ];then
	#EMAIL_ME "${Start_Date}" ${Process_NAME}
	#fi
	
	echo "Start at ${Start_Date} " | mail -s "Project: + ${Process_NAME} Completed!" xili@guardanthealth.com
}
##### Following Line is very IMPORTANT 
main "$@"

#[1] https://stackoverflow.com/questions/10909685/run-parallel-multiple-commands-at-once-in-the-same-terminal
#[2]
#[3]
