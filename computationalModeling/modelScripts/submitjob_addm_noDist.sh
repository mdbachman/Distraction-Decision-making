#!/bin/sh

sedir=$(echo $d | sed 's_/_\\/_g')

cd $d

sed "s/SUBJNO/${s}/g;s/DIR/${sedir}/g;s/COND/${c}/g;s/GRP/${g}/g;s/TYPE/${t}/g" estparams_addm_noDist.m > indiv/estparams_addm_noDist_${g}_s${s}.m
/usr/local/packages/MATLAB/R2018a/bin/matlab -singleCompThread -nodisplay < indiv/estparams_addm_noDist_${g}_s${s}.m

