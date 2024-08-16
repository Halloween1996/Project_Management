@echo off
set "Final_Location="
set "Source_Location="
if exist %1 set "Source_Location=%~1"
set n=0
cd /d %Source_Location%
setlocal enabledelayedexpansion
for /f %%i in ('dir /b !Source_Location!') do (
	Set Skip_This_File=False
	set /a n+=1
	echo [!n!] %%~ni
	for /f "delims=- tokens=1,2*" %%a in ("%%~ni") do (
		set "profile_Name=%%a"
		Set "sub_year=%%~b"
		if %%b leq 15 Set Skip_This_File=True
		if %%b geq 24 Set Skip_This_File=True
	)
	if "!Skip_This_File!"=="False" (
	if not exist "!Final_location!\!profile_Name!\!profile_Name!-!sub_year!" md "!Final_location!\!profile_Name!\!profile_Name!-!sub_year!" 
	move "%%~i" "!Final_location!\!profile_Name!\!profile_Name!-!sub_year!" 
) else (
	echo !sub_year!
	echo This file is not fit with standard, please rename it and try again.
	)
)
pause
