#!/bin/tcsh -ex
set dataDir1=/media/MVR_data2/sebastien/rawData/20160424_HR_decoding_SK/HR_decoding_SK_20160424_001_004plus__mag
set dataDir2=/media/MVR_data2/sebastien/rawData/20160424_HR_decoding_SK_2/HR_decoding_SK_2_20160424_001_004plus__mag

set workDir=/media/MVR_data2/sebastien/projects/160424_HRdecoding/C_processing/03sk/run1a_preprocessing
#set workDir=/mnt/hgfs/Work/projects/160424_HRdecoding/C_processing/03sk/run1a_preprocessing

mkdir -p $workDir
cd $workDir


### Slice timing correction
if (0) then
set session=1
## fun runs
foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
 3dTshift -overwrite -prefix $workDir/t$run.nii.gz -tpattern altplus $dataDir1/$run.nii
end
 ## Distortion references
3dTshift -overwrite -prefix $workDir/tref$session"01".nii.gz -tpattern altplus $dataDir1/ref$session"01".nii
3dTshift -overwrite -prefix $workDir/tref$session"02".nii.gz -tpattern altplus $dataDir1/ref$session"02".nii
endif

if (0) then
set session=2
## fun runs
foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
 3dTshift -overwrite -prefix $workDir/t$run.nii.gz -tpattern altplus $dataDir2/$run.nii
end
 ## Distortion references
3dTshift -overwrite -prefix $workDir/tref$session"01".nii.gz -tpattern altplus $dataDir2/ref$session"01".nii
3dTshift -overwrite -prefix $workDir/tref$session"02".nii.gz -tpattern altplus $dataDir2/ref$session"02".nii
endif


if (0) then
### Motion correction -- within-session
foreach session (1 2)
 ## fun runs
 3dvolreg -overwrite -prefix $workDir/tmp.nii.gz -base 0 $workDir/trun$session"01".nii.gz
 3dTstat -overwrite -prefix $workDir/mcTarget.nii.gz -mean $workDir/tmp.nii.gz
 foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
  3dvolreg -overwrite -prefix $workDir/t"$run"_mc.nii.gz -base $workDir/mcTarget.nii.gz -zpad 5 -twopass -1Dfile $workDir/t"$run"_mcParam.1D -1Dmatrix_save $workDir/t"$run"_mcParam t"$run".nii.gz
  3dTstat -overwrite -mean -prefix $workDir/t"$run"_mc_mean.nii.gz $workDir/t"$run"_mc.nii.gz
 end
 cat $workDir/trun"$session"??_mcParam.1D > tmp
 mv tmp trun"$session"00_mcParam.1D
 3dTcat -overwrite -prefix $workDir/trun$session"00_mc.nii.gz" $workDir/trun$session??_mc.nii.gz
 3dTcat -overwrite -prefix $workDir/trun$session"00_mc_means.nii.gz" $workDir/trun$session??_mc_mean.nii.gz
 3dTstat -overwrite -mean -prefix $workDir/trun$session"00_mc_means_mean.nii.gz" $workDir/trun$session"00_mc_means.nii.gz"
 ## Distortion references
 3dvolreg -overwrite -prefix $workDir/tref$session"01"_mc.nii.gz -base 0 -zpad 5 -twopass -1Dfile $workDir/tref$session"01"_mcParam.1D $workDir/tref$session"01".nii.gz
 3dTstat -overwrite -prefix $workDir/tref$session"01"_mc_mean.nii.gz -mean $workDir/tref$session"01"_mc.nii.gz
 3dvolreg -overwrite -prefix $workDir/tref$session"02"_mc.nii.gz -base 0 -zpad 5 -twopass -1Dfile $workDir/tref$session"02"_mcParam.1D $workDir/tref$session"02".nii.gz
 3dTstat -overwrite -prefix $workDir/tref$session"02"_mc_mean.nii.gz -mean $workDir/tref$session"02"_mc.nii.gz
end
endif


## Deformation correction ###Do that manually###
if (0) then
fslview $workDir/tref101_mc_mean.nii.gz
3dcalc -overwrite -prefix $workDir/tref101_mc_mean-maskInv.nii.gz -a $workDir/tref101_mc_mean-mask.nii.gz -expr '(a-1)*-1'

set session=1
# Register ref to runs
#fslview $workDir/trun"$session"01_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz $workDir/trun"$session"18_mc_mean.nii.gz $workDir/tref"$session"02_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean-maskInv.nii.gz
fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean-maskInv.nii.gz
3dcalc -overwrite -prefix $workDir/tref"$session"01_mc_mean-mask.nii.gz -a $workDir/tref"$session"01_mc_mean-maskInv.nii.gz -expr '(a-1)*-1'
mri_binarize --i $workDir/tref"$session"01_mc_mean-mask.nii.gz --o $workDir/tref"$session"01_mc_mean-mask2.nii.gz --erode 4 --min 0.5 --max 1.5
3dcalc -overwrite -prefix $workDir/tref"$session"01_mc_mean-mask2Inv.nii.gz -a $workDir/tref"$session"01_mc_mean-mask2.nii.gz -expr '(a-1)*-1'
fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean-mask2.nii.gz

3dAllineate -overwrite -warp shift_only -parfix 2 0 -cost ls -final wsinc5 -prefix $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz -1Dmatrix_save $workDir/tref"$session"01_mc_mean_mcToRunParam -weight $workDir/tref"$session"01_mc_mean-mask2.nii.gz -base $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz
fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz

# Compute warp
3dAllineate -overwrite -prefix $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz -1Dmatrix_apply $workDir/tref"$session"01_mc_mean_mcToRunParam.aff12.1D -master $workDir/tref"$session"01_mc_mean.nii.gz -interp NN $workDir/tref"$session"01_mc_mean-mask.nii.gz
3dcalc -overwrite -prefix $workDir/tref"$session"01_mc_mean_mcToRun-maskInv.nii.gz -a $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz -expr '(a-1)*-1'

fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz

3dQwarp -overwrite -prefix $workDir/trun"$session"00_mc_means_mean.nii.gz -base $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz -weight $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz -source $workDir/trun"$session"00_mc_means_mean.nii.gz -noZdis -noYdis -plusminus -superhard -minpatch 9 -nmi

fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/trun"$session"00_mc_means_mean_PLUS.nii.gz $workDir/trun"$session"00_mc_means_mean_MINUS.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun-maskInv.nii.gz



set session=2
3dvolreg -overwrite -prefix $workDir/tref101_mc_mean_mcToSession$session.nii.gz -base $workDir/tref$session"01"_mc_mean.nii.gz -zpad 5 -twopass -1Dmatrix_save $workDir/tref101_mc_mean_mcParamToSession$session $workDir/tref101_mc_mean.nii.gz
3dAllineate -overwrite -prefix $workDir/tref$session"01"_mc_mean-mask.nii.gz -1Dmatrix_apply $workDir/tref101_mc_mean_mcParamToSession$session.aff12.1D -master $workDir/tref$session"01"_mc_mean.nii.gz -interp NN $workDir/tref101_mc_mean-mask.nii.gz
3dcalc -overwrite -prefix $workDir/tref$session"01"_mc_mean-maskInv.nii.gz -a $workDir/tref$session"01"_mc_mean-mask.nii.gz -expr '(a-1)*-1'

# Register ref to runs
#fslview $workDir/trun"$session"01_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz $workDir/trun"$session"18_mc_mean.nii.gz $workDir/tref"$session"02_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean-maskInv.nii.gz
fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean-maskInv.nii.gz
3dcalc -overwrite -prefix $workDir/tref"$session"01_mc_mean-mask.nii.gz -a $workDir/tref"$session"01_mc_mean-maskInv.nii.gz -expr '(a-1)*-1'
mri_binarize --i $workDir/tref"$session"01_mc_mean-mask.nii.gz --o $workDir/tref"$session"01_mc_mean-mask2.nii.gz --erode 4 --min 0.5 --max 1.5
3dcalc -overwrite -prefix $workDir/tref"$session"01_mc_mean-mask2Inv.nii.gz -a $workDir/tref"$session"01_mc_mean-mask2.nii.gz -expr '(a-1)*-1'
fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz $workDir/tref"$session"01_mc_mean-mask2.nii.gz

3dAllineate -overwrite -warp shift_only -parfix 2 0 -cost ls -final wsinc5 -prefix $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz -1Dmatrix_save $workDir/tref"$session"01_mc_mean_mcToRunParam -weight $workDir/tref"$session"01_mc_mean-mask2.nii.gz -base $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz
fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz $workDir/tref"$session"01_mc_mean.nii.gz

# Compute warp
3dAllineate -overwrite -prefix $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz -1Dmatrix_apply $workDir/tref"$session"01_mc_mean_mcToRunParam.aff12.1D -master $workDir/tref"$session"01_mc_mean.nii.gz -interp NN $workDir/tref"$session"01_mc_mean-mask.nii.gz
3dcalc -overwrite -prefix $workDir/tref"$session"01_mc_mean_mcToRun-maskInv.nii.gz -a $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz -expr '(a-1)*-1'

fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz

3dQwarp -overwrite -prefix $workDir/trun"$session"00_mc_means_mean.nii.gz -base $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz -weight $workDir/tref"$session"01_mc_mean_mcToRun-mask.nii.gz -source $workDir/trun"$session"00_mc_means_mean.nii.gz -noZdis -noYdis -plusminus -superhard -minpatch 9 -nmi

fslview $workDir/trun"$session"00_mc_means_mean.nii.gz $workDir/trun"$session"00_mc_means_mean_PLUS.nii.gz $workDir/trun"$session"00_mc_means_mean_MINUS.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun.nii.gz $workDir/tref"$session"01_mc_mean_mcToRun-maskInv.nii.gz

endif





if (0) then
### Motion correction -- between-session
3dZeropad -overwrite -prefix $workDir/trun100_mc_means_mean_PLUS_zPad.nii.gz -AP 15 $workDir/trun100_mc_means_mean_PLUS.nii.gz
3dZeropad -overwrite -prefix $workDir/tref101_mc_mean_mcToRun-maskInv_zPad.nii.gz -AP 15 $workDir/tref101_mc_mean_mcToRun-maskInv.nii.gz

foreach session (1 2)
 3dvolreg -overwrite -prefix $workDir/trun"$session"00_mc_means_mean_PLUS_mcToSession1.nii.gz -base $workDir/trun100_mc_means_mean_PLUS.nii.gz -zpad 5 -twopass -1Dfile $workDir/trun"$session"00_mc_means_mean_PLUS_mcParamToSession1.1D -1Dmatrix_save $workDir/trun"$session"00_mc_means_mean_PLUS_mcParamToSession1 $workDir/trun"$session"00_mc_means_mean_PLUS.nii.gz
 3dAllineate -overwrite -prefix $workDir/trun"$session"00_mc_means_mean_PLUS_mcToSession1_zPad.nii.gz -1Dmatrix_apply $workDir/trun"$session"00_mc_means_mean_PLUS_mcParamToSession1.aff12.1D -master $workDir/trun100_mc_means_mean_PLUS_zPad.nii.gz -interp quintic $workDir/trun"$session"00_mc_means_mean_PLUS.nii.gz
end

3dTcat -overwrite -prefix $workDir/trun000_mc_means_mean_PLUS_mcToSession1.nii.gz $workDir/trun[^0]00_mc_means_mean_PLUS_mcToSession1.nii.gz
3dTcat -overwrite -prefix $workDir/trun000_mc_means_mean_PLUS_mcToSession1_zPad.nii.gz $workDir/trun[^0]00_mc_means_mean_PLUS_mcToSession1_zPad.nii.gz

endif

if (0) then
fslview $workDir/trun000_mc_means_mean_PLUS_mcToSession1_zPad.nii.gz $workDir/tref101_mc_mean_mcToRun-maskInv_zPad.nii.gz
endif



### Aply warp
if (0) then
set session=1
foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
 3dNwarpApply -overwrite -prefix $workDir/t"$run"_preprocessed.nii.gz -nwarp $workDir/trun"$session"00_mc_means_mean_PLUS_mcParamToSession1.aff12.1D' '$workDir/trun"$session"00_mc_means_mean_PLUS_WARP.nii.gz' '$workDir/t"$run"_mcParam.aff12.1D -master $workDir/trun100_mc_means_mean_PLUS_mcToSession1.nii.gz -source $workDir/t"$run".nii.gz
 3dTstat -overwrite -prefix $workDir/t"$run"_preprocessed_mean.nii.gz -mean $workDir/t"$run"_preprocessed.nii.gz
end
3dTcat -overwrite -prefix $workDir/trun"$session"00_preprocessed_means.nii.gz $workDir/trun"$session"??_preprocessed_mean.nii.gz
3dTstat -overwrite -prefix $workDir/trun"$session"00_preprocessed_means_mean.nii.gz -mean $workDir/trun"$session"00_preprocessed_means.nii.gz
endif

if (0) then
set session=2
foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
 3dNwarpApply -overwrite -prefix $workDir/t"$run"_preprocessed.nii.gz -nwarp $workDir/trun"$session"00_mc_means_mean_PLUS_mcParamToSession1.aff12.1D' '$workDir/trun"$session"00_mc_means_mean_PLUS_WARP.nii.gz' '$workDir/t"$run"_mcParam.aff12.1D -master $workDir/trun100_mc_means_mean_PLUS_mcToSession1.nii.gz -source $workDir/t"$run".nii.gz
 3dTstat -overwrite -prefix $workDir/t"$run"_preprocessed_mean.nii.gz -mean $workDir/t"$run"_preprocessed.nii.gz
end
3dTcat -overwrite -prefix $workDir/trun"$session"00_preprocessed_means.nii.gz $workDir/trun"$session"??_preprocessed_mean.nii.gz
3dTstat -overwrite -prefix $workDir/trun"$session"00_preprocessed_means_mean.nii.gz -mean $workDir/trun"$session"00_preprocessed_means.nii.gz


3dTcat -overwrite -prefix $workDir/trun000_preprocessed_sessionMeans.nii.gz $workDir/trun[^0]00_preprocessed_means_mean.nii.gz
3dTcat -overwrite -prefix $workDir/trun000_preprocessed_means.nii.gz $workDir/trun[^0]00_preprocessed_means.nii.gz
3dTstat -overwrite -prefix $workDir/trun000_preprocessed_mean.nii.gz -mean $workDir/trun000_preprocessed_means.nii.gz
endif




if (0) then
### Detrend and regress out counfounds
set session=1
foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
	foreach col (0 1 2 3 4 5)
		1deval -a $workDir/t"$run"_mcParam.1D'['$col']' -expr 'a^2' > tmp$col.1D 
	end
	1dcat tmp0.1D tmp1.1D tmp2.1D tmp3.1D tmp4.1D tmp5.1D > $workDir/t"$run"_mcParam_squared.1D
	rm tmp0.1D tmp1.1D tmp2.1D tmp3.1D tmp4.1D tmp5.1D

	python /usr/local/bin/afni/1d_tool.py -overwrite -infile $workDir/t"$run"_mcParam.1D -set_nruns 1 -derivative -write $workDir/t"$run"_mcParam_derivative.1D

	1dcat $workDir/t"$run"_mcParam.1D $workDir/t"$run"_mcParam_squared.1D $workDir/t"$run"_mcParam_derivative.1D > $workDir/t"$run"_mcParam_all.1D

	3dDetrend -overwrite -prefix $workDir/t"$run"_preprocessed_detrend.nii.gz -vector $workDir/t"$run"_mcParam_all.1D -polort 1 $workDir/t"$run"_preprocessed.nii.gz
end

set session=2
foreach run (run$session"01" run$session"02" run$session"03" run$session"04" run$session"05" run$session"06" run$session"07" run$session"08" run$session"09" run$session"10" run$session"11" run$session"12" run$session"13" run$session"14" run$session"15" run$session"16" run$session"17" run$session"18")
	foreach col (0 1 2 3 4 5)
		1deval -a $workDir/t"$run"_mcParam.1D'['$col']' -expr 'a^2' > tmp$col.1D 
	end
	1dcat tmp0.1D tmp1.1D tmp2.1D tmp3.1D tmp4.1D tmp5.1D > $workDir/t"$run"_mcParam_squared.1D
	rm tmp0.1D tmp1.1D tmp2.1D tmp3.1D tmp4.1D tmp5.1D

	python /usr/local/bin/afni/1d_tool.py -overwrite -infile $workDir/t"$run"_mcParam.1D -set_nruns 1 -derivative -write $workDir/t"$run"_mcParam_derivative.1D

	1dcat $workDir/t"$run"_mcParam.1D $workDir/t"$run"_mcParam_squared.1D $workDir/t"$run"_mcParam_derivative.1D > $workDir/t"$run"_mcParam_all.1D

	3dDetrend -overwrite -prefix $workDir/t"$run"_preprocessed_detrend.nii.gz -vector $workDir/t"$run"_mcParam_all.1D -polort 1 $workDir/t"$run"_preprocessed.nii.gz
end

endif




