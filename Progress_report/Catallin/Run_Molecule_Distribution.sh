WORK_PATH="/ghess/groups/algorithms/projects/Study_Fragment_Size/Sample/Testing_Sample/molecule_counts"
cd ${WORK_PATH}

xx=$(find -name "*.molecule_table.sh")
for x in ${xx[*]}
do
    NAME=${x:2:-18}
    echo "${NAME}"
    echo "Running ${x}" 
    OUTPATH=${WORK_PATH}/${x:2}
    echo "qsub -V -q dev.q -j y -b y -cwd -o ${OUTPATH}.log -N ${NAME} -l mem_free=8G,h_vmem=8G -pe parallel 8 sh ${OUTPATH}" 
    qsub -V -q dev.q -j y -b y -cwd -o ${OUTPATH}.log -N ${NAME} -l mem_free=8G,h_vmem=8G -pe parallel 8 sh ${OUTPATH} & pid=$!
    PID_LIST+=" $pid";
    #break
done

echo "wait ${PID_LIST}....................................."
wait ${PID_LIST}
echo "Start at ${Start_Date} " | mail -s "Project: + ${Process_NAME} Completed!" xili@guardanthealth.com
