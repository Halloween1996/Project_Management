@echo off
set logging_Location=C:\Users\Maxel\SynologyDrive\Project_References\This-yeah\LT-DOC
set Final_Location=C:\Users\Maxel\SynologyDrive\Project_References\This-yeah\LT-DOC\Target
set session_num=0
if "%1"=="" goto open
Set "Init_Path=True"
set "File_Path=%~1"
:execution
Set Skip_This_File=False
for %%i in ("%File_Path%") do set File_Name=%%~ni
for /f "delims=- tokens=1,2*" %%a in ("%File_Name%") do (
	set "profile_Name=%%a"
	if "%%b"=="" Set Skip_This_File=True
	Set "sub_year=%%~b"
)
if %sub_year% leq 15 Set Skip_This_File=True
if %sub_year% geq 24 Set Skip_This_File=True
if "%Skip_This_File%"=="True" (
	 echo This file name is not fit with standard, please rename and try again.
	 pause
	 goto open
)
if not exist "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%" (
	md "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%"
	echo New Diretory: "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%" >>%logging_Location%\move_History.log
)
move %File_Path% "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%"
echo %date% %time% move %File_Name% to %Final_location%\%profile_Name%\%profile_Name%-%sub_year%>>%logging_Location%\move_History.log
if "%Init_Path%"=="True" exit
:open
Set "dc="
set /a session_num+=1
echo.
echo ----------[Session %session_num%] ----------
echo Hi, you may enter the File Path for moving
set /p profile_Name= Or enter the keyword for opening client folder:
if exist %profile_Name% (
	set File_Path=%profile_Name%
	echo I think it is a file path. moving file is excuting.
	goto :execution
)
call :WhichOne "%Final_location%\*%profile_Name%*",dc
if "%dc%"=="" goto open
echo                      [%dc%] has located. Listing all:
call :WhichOne "%Final_location%\%dc%",subject
start "" "%Final_location%\%dc%\%subject%"
goto open
:WhichOne
set "result_Count=0"
set "IsthisOne="
Setlocal EnableDelayedExpansion
for /f %%z in ('dir /ad /b "%~1"') do (
	set /a result_Count+=1
	set "IsthisOne!Result_Count!=%%~z"
	echo I found : [!Result_Count!] %%z
)
If %result_Count% equ 0 echo No Result at all&goto :eof
set decision=%IsthisOne1%
If %result_Count% geq 2 (
	echo I found %result_Count% Results, which one?
	echo By default, the first Result is selected; 
	echo if you enter 0; result set to be empty; 
	echo if you enter ":", this session will end.
	Set /p userchoice=I choose No.
	if defined IsThisOne!userchoice! call set "decision=%%IsThisOne!userchoice!%%"
	if "!userchoice!"=="0" set "decision="
	if "!userchoice!"==":" echo Okay. &goto open
	echo you choice !decision!
)
endlocal & set "%~2=%decision%"
goto :eof