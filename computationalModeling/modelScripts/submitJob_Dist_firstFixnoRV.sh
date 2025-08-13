#!/bin/sh
#$ -o /mnt/munin/Huettel/FoodPrime.01/Analysis/Matthew/errorLogs/errDist_firstFixnoRV
#$ -j y


cd /mnt/munin/Huettel/FoodPrime.01/Analysis/Matthew


sed "s/SUBJNO/${s}/g;s/GRP/${grp}/g" estparams_Dist_firstFixnoRV.m > subjScripts/Dist_${grp}_${s}_firstFixnoRV.m
/usr/local/packages/MATLAB/R2018a/bin/matlab -singleCompThread -nodisplay < subjScripts/Dist_${grp}_${s}_firstFixnoRV.m

