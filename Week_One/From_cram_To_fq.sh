xx=$(find -name "*.short*cram")
for x in ${xx[*]};
do 
    echo ${x:2:-18}
    samtools collate -@ 16 -u -O ${x} | samtools fastq -@ 16 -1 ${x:2:-18}_R1.fastq -2 ${x:2:-18}_R2.fastq -0 /dev/null -s /dev/null -n &
done 