#!/bin/bash -e

subjFS=senjutiKundu
subj=03sk
SUBJECTS_DIR=/mnt/hgfs/Work/freesurfer
dataDir=/mnt/hgfs/Work/projects/160424_HRdecoding/C_processing/$subj/run1a_preprocessing
workDir=/mnt/hgfs/Work/projects/160424_HRdecoding/C_processing/$subj/run1b_registration
mkdir -p $workDir
cd $workDir


if [ 1 == 1 ]
then
### Manual registration
echo ------------------
echo ------------------
echo DO MANUAL REGISTRATION
echo ------------------
echo ------------------
tkregister2 --s $subjFS --mov $dataDir/trun000_preprocessed_mean.nii.gz --surf orig --reg $workDir/func2anatMan.dat
#tkregister2 --s $subjFS --mov $dataDir/trun000_preprocessed_mean.nii.gz --surf orig --reg $workDir/func2anatMan.dat --regheader
fi


if [ 1 == 1 ]
then
### Register anat to functional
bbregister --s $subjFS --mov $dataDir/trun000_preprocessed_mean.nii.gz --reg $workDir/func2anatBBreg.dat --lta $workDir/func2anatBBreg.lta --init-reg $workDir/func2anatMan.dat --t2 --epi-mask --label $SUBJECTS_DIR/$subjFS/label/lh.V1.label --label $SUBJECTS_DIR/$subjFS/label/rh.V1.label --label $SUBJECTS_DIR/$subjFS/label/lh.V2.label --label $SUBJECTS_DIR/$subjFS/label/rh.V2.label --o $workDir/funMean_BBreg2anat.nii.gz
fi


if [ 1 == 1 ]
then


echo ------------------
echo ------------------
echo CONFIRM BB REGISTRATION
echo ------------------
echo ------------------

tkregister2 --mov $dataDir/trun000_preprocessed_mean.nii.gz --reg $workDir/func2anatBBreg.dat --surf
#freeview $SUBJECTS_DIR/$subjFS/mri/brain.mgz $workDir/funMean_BBreg2anat.nii.gz --cubic
#fslview $workDir/funMean_BBreg2anat.nii.gz
fi


#Still needed?
if [ 0 == 1 ]
then
### Register functional to anat -- must have run anat to functional before
## Move T1 in func space using previous registration step
mri_convert $SUBJECTS_DIR/$subjFS/mri/brain.mgz $workDir/brain.nii.gz
mri_convert -rt cubic --apply_inverse_transform $workDir/func2anatBBreg.lta --like $workDir/brain.nii.gz $workDir/brain.nii.gz $workDir/brain_regToFunc.nii.gz
#freeview $workDir/brain.nii.gz $workDir/brain_regToFunc.nii.gz $workDir/funMean.nii.gz
## Then register it back to anat space with afni tools to get the tranform in afni freaking format
3dAllineate -overwrite -prefix $workDir/brain_regToFunc_backToAnat.nii.gz -cost ls -warp shift_rotate -base $workDir/brain.nii.gz -source $workDir/brain_regToFunc.nii.gz -1Dparam_save $workDir/brain_regToFunc_backToAnat.1D -1Dmatrix_save $workDir/brain_regToFunc_backToAnat
freeview $workDir/brain_regToFunc_backToAnat.nii.gz $workDir/brain.nii.gz

fi
