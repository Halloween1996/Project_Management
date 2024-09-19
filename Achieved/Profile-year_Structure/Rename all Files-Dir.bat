@ECHO OFF
set numba=0
cd %1
echo CURRENT DIRETORY: %CD%
for %%k in (%cd%) do set path_name=%%~nk
ECHO According to the name of the folder [%path_name%]...
for /f "delims=- tokens=1,2*" %%a in ("%path_name%") do (
	set "profile_Name=%%a"
	Set "year=%%~b"
)
echo the profile is : %profile_Name%
echo the year is 20%year%
Set /p agree=Enter to continue, any string to modify.
if NOT "%agree%"=="" (
	set /p profile_Name=Ok,so the Profile is:
	Set /p year=the year is:
)
echo on
setlocal EnableDelayedExpansion
for /f "delims=" %%i in ('dir /b %1') do (
	set /a numba+=1
	ren "%%i" "!profile_Name!-!year!-!numba!%%~xi"
)
pause
