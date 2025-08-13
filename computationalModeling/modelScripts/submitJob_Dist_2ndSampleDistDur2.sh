#!/bin/sh
#$ -o /mnt/munin/Huettel/FoodPrime.01/Analysis/Matthew/errorLogs/errDist_2ndSampleDistDur2
#$ -j y


cd /mnt/munin/Huettel/FoodPrime.01/Analysis/Matthew


sed "s/SUBJNO/${s}/g;s/GRP/${grp}/g" estparams_Dist_2ndSampleDistDur2.m > subjScripts/Dist_2ndSampleDistDur2_${grp}_${s}.m
/usr/local/packages/MATLAB/R2018a/bin/matlab -singleCompThread -nodisplay < subjScripts/Dist_2ndSampleDistDur2_${grp}_${s}.m

