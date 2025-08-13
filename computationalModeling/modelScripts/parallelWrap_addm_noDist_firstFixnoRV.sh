#cond=def

subjects=({1..50})


outfile=`findexp FoodPrime.01`/Analysis/Matthew/error_firstFixnoRV.txt
dir=`findexp FoodPrime.01`/Analysis/Matthew/

for grp in 1 2
do
	echo  "Group ${grp}"
	for subj in "${subjects[@]}" 
	do
		echo "Subj ${subj}"

	# recovery
	#qsub -o $outfile -j y -v m=boost_addm,t=recov,s=${subj},d=${dir},e=1 submitjob.sh

	# data
	
		qsub -o $outfile -j y -v s=${subj},d=${dir},c=noDist,g=${grp},t=addm submitjob_addm_noDist_firstFixnoRV.sh
	done
done


