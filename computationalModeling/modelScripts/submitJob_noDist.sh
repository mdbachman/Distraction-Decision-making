#!/bin/sh
#$ -o /mnt/munin/Huettel/FoodPrime.01/Analysis/Matthew/errorLogs/errNoDist
#$ -j y


cd /mnt/munin/Huettel/FoodPrime.01/Analysis/Matthew


sed "s/SUBJNO/${s}/g;s/GRP/${grp}/g" estparams_noDist.m > subjScripts/noDist_${grp}_${s}.m
/usr/local/packages/MATLAB/R2018a/bin/matlab -singleCompThread -nodisplay < subjScripts/noDist_${grp}_${s}.m

