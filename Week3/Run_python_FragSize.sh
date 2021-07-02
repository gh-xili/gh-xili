WORK_PATH="/ghess/groups/algorithms/projects/Study_Fragment_Size/Sample/molecule_counts"
EXE_PATH="/ghess/groups/algorithms/projects/Study_Fragment_Size/version.beta/Generate_FragSize_Distribution.py"
cd ${WORK_PATH}

xx=$(find -name "*.molecule_table.tsv")


for x in ${xx[*]}
do
    echo "Running ${x}" 
    python ${EXE_PATH} --input ${x} & pid=$!
    PID_LIST+=" $pid";
    break

done

echo "wait ${PID_LIST}....................................."
wait ${PID_LIST}
echo "Start at ${Start_Date} " | mail -s "Project: + ${Process_NAME} Completed!" xili@guardanthealth.com
