WORK_PATH="/ghess/groups/algorithms/projects/Study_Fragment_Size/Sample"
cd ${WORK_PATH}

xx=(
A034884001
A034608701
A033165801
A034462101
A033918601
A034337201
A034931601
A035291401
A033376101
A033657201
A034793101
A034377101
A035149201
A033880001
A033920601
A034580801
A035051101
A034441701
)

for x in ${xx[*]}
do
    SH_PATH=$(find -wholename "*${x}*.molecule_table.sh")
    NAME=${SH_PATH:5:-18}
    echo "${NAME}"
    echo "Running ${x}" 
    OUTPATH=${WORK_PATH}/${SH_PATH:2}
    echo "qsub -V -q dev.q -j y -b y -cwd -o ${OUTPATH}.log -N ${NAME} -l mem_free=8G,h_vmem=8G -pe parallel 8 sh ${OUTPATH}" 
    #qsub -V -q dev.q -j y -b y -cwd -o ${OUTPATH}.log -N ${NAME} -l mem_free=8G,h_vmem=8G -pe parallel 8 sh ${OUTPATH} & pid=$!
    #PID_LIST+=" $pid";
    #break
done

#echo "wait ${PID_LIST}....................................."
#wait ${PID_LIST}
#echo "Start at ${Start_Date} " | mail -s "Project: + ${Process_NAME} Completed!" xili@guardanthealth.com