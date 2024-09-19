@ECHO OFF
set agree=No
if "%~1"=="" goto jumphere
for %%k in (%cd%) do set path_name=%%~nk
for /f "delims=- tokens=1,2*" %%a in ("%path_name%") do (
	set "profile_Name=%%a"
	Set "year=%%~b"
)
echo the profile is : %profile_Name% and the tax year is 20%year%
set agree=Yes
Set /p agree=Enter to continue, any string to modify.
:jumphere
if NOT "%agree%"=="Yes" (
	set /p profile_Name=Ok,so the Profile name is:
	Set /p year=the year is 20
	echo ---
	echo.
)
Set /p numba=What number you would like to begin to?
if "%numba%"=="" set numba=1
echo CURRENT DIRETORY: %CD%
echo ---
echo.
:Renamewhat
echo Name allocation : %profile_Name%-%year%-%numba%
set /p selected_File=
for /f "delims=" %%i in ("%selected_File%") do ren "%%i" "%profile_Name%-%year%-%numba%-%%~nxi"
set /a numba+=1
echo.
Goto Renamewhat