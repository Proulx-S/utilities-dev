#!/bin/bash -ex


fsID=senjutiKundu
subj=03sk
SUBJECTS_DIR=/mnt/hgfs/Work/freesurfer
funcDir=/mnt/hgfs/Work/projects/160424_HRdecoding/C_processing/$subj/run1a_preprocessing
regDir=/mnt/hgfs/Work/projects/160424_HRdecoding/C_processing/$subj/run1b_registration
workDir=/mnt/hgfs/Work/projects/160424_HRdecoding/C_processing/$subj/run1c_masking
mkdir -p $workDir
cd $workDir

rm -rf $SUBJECTS_DIR/$fsID/anatVis

### Anatomical-retinotopy based
cd $SUBJECTS_DIR
printf "******************************\n******************************\n******************************\nDoing ret registration\n******************************\n******************************\n******************************\n"
./anatRet2subj_reg.sh $fsID 2>&1 | tee $workDir/anatRet2subj_reg.log
printf "******************************\n******************************\n******************************\nDoing ret images\n******************************\n******************************\n******************************\n"
./anatRet2subj_ret.sh $fsID $funcDir/trun000_preprocessed_mean.nii.gz $regDir/func2anatBBreg.dat 2>&1 | tee $workDir/anatRet2subj_dat.log

printf "******************************\n******************************\n******************************\nDoing ret eccMasks\n******************************\n******************************\n******************************\n"
./anatRet2subj_eccMask.sh $fsID 0.75 7 2>&1 | tee $workDir/anatRet2subj_eccMask.log
printf "******************************\n******************************\n******************************\nDoing ret areasMask\n******************************\n******************************\n******************************\n"
./anatRet2subj_areasMask.sh $fsID 2>&1 | tee $workDir/anatRet2subj_areasMask.log
#fslview $regDir/funMean.nii.gz $fsID/anatVis/lh.ecc.nii.gz
#freeview $regDir/funMean.nii.gz $fsID/anatVis/lh.ecc.nii.gz

### Get what is needed
printf "******************************\n******************************\n******************************\nGathering final masks\n******************************\n******************************\n******************************\n"
cp $SUBJECTS_DIR/$fsID/anatVis/?h.ecc.nii.gz $SUBJECTS_DIR/$fsID/anatVis/?h.pol.nii.gz $SUBJECTS_DIR/$fsID/anatVis/eccMask_*To*.nii.gz $SUBJECTS_DIR/$fsID/anatVis/v?.nii.gz $workDir




