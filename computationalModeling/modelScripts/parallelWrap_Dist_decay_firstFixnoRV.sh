
subjects=({1..50})

for subj in "${subjects[@]}" 
do
	echo "Subj ${subj}"
	
	qsub -v s=${subj},grp=1,cond=Dist submitJob_Dist_decay_firstFixnoRV.sh # Dataset 1
	qsub -v s=${subj},grp=2,cond=Dist submitJob_Dist_decay_firstFixnoRV.sh # Dataset 1

done

