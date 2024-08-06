@echo off
set /p version=Input version:
echo %version%

set scriptDir=%~dp0
@REM echo %scriptDir%
@REM python D:\private_gitlab_prj\zas_prj\timing_bin_add_version.py PCG1_TimingM_v%version%

xcopy %scriptDir%project_1\project_1.runs\impl_1\mfpga_top.bit %scriptDir%version_bin\timing_version\ 
xcopy %scriptDir%project_1\project_1.runs\impl_1\mfpga_top.ltx %scriptDir%version_bin\timing_version\
xcopy %scriptDir%project_1\project_1.runs\impl_1\mfpga_top.bin %scriptDir%version_bin\timing_version\

ren %scriptDir%version_bin\timing_version\mfpga_top.bit PCG_TimingM_v%version%.bit 
ren %scriptDir%version_bin\timing_version\mfpga_top.ltx PCG_TimingM_v%version%.ltx 
ren %scriptDir%version_bin\timing_version\mfpga_top.bin PCG_TimingM_v%version%.bin 

pause