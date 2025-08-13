
subjects=({1 50})

for subj in "${subjects[@]}" 
do
	echo "Subj ${subj}"
	
	qsub -v s=${subj},grp=1,cond=noDist submitJob_noDist.sh # Dataset 1
	qsub -v s=${subj},grp=2,cond=noDist submitJob_noDist.sh # Dataset 2

done

