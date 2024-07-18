@echo off
@Title %date%
set logging_Location=
set Source_Location=
set Final_Location=
for /f "usebackq delims=" %%c in ("%~dp0\project_variable.ini") do set %%c
set session_num=0
echo Hello, Here is version 1.1 and today is %date%.
echo log Directory: %logging_Location%
if "%1"=="" goto open
Set "Init_Path=True"
set "File_Path=%~1"
:execution
Set Skip_This_File=False
Set "sub_year="
for /f "usebackq delims=" %%i in ('%File_Path%') do set File_Name=%%~ni&&set File_Extension=%%~xi
for /f "usebackq tokens=1,2 delims=-" %%a in ('%File_Name%') do (
    set "profile_Name=%%a"
    if "%%b"=="" Set Skip_This_File=True
    Set "sub_year=%%~b"
)
if %sub_year% leq 15 Set Skip_This_File=True
if %sub_year% geq 35 Set Skip_This_File=True
if "%Skip_This_File%"=="True" (
     echo It is not fit with standard, please rename [%sub_year%] and try again.
     pause
     goto open
)
if not exist "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%" (
    md "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%"
    echo %date%, %Time%,New Directory,%profile_Name%-%sub_year% >>%logging_Location%\move_History.csv
)
echo %Final_location%\%profile_Name%\%profile_Name%-%sub_year%\%File_Name%%File_Extension%
if not exist "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%\%File_Name%%File_Extension%" (
    move %File_Path% "%Final_location%\%profile_Name%\%profile_Name%-%sub_year%"
    echo %date%, %Time%,%File_Name%,%Final_location%\%profile_Name%\%profile_Name%-%sub_year% >>%logging_Location%\move_History.csv
) else (
    echo %Final_location%\%profile_Name%\%profile_Name%-%sub_year%\%File_Name%%File_Extension% is exist, please rename and try again.
    ren "%File_Path%" "%File_Name%_%date:~-4%%date:~0,3%%File_Extension%"
    pause
)
if "%Init_Path%"=="True" exit
:open
Set "Portfolio_Folder="
Set "subject="
Set "Source_Location_Numba="
set /a session_num+=1
echo.
echo ----------[Session %session_num%] ---------- Time: %time%
set /p profile_Name= Enter a Path to MOVE or a Keyword to OPEN folder        
if "%profile_Name%"==";" CMD
if exist "%profile_Name%" (
    set "File_Path=%profile_Name%"
    echo I think it is a path. moving file is executing.
    goto execution
)
if "%profile_Name:~-1%"=="*" goto Global_Mode
for /f "usebackq tokens=1,2 delims=-" %%w in ('%profile_Name%') do set profile_Name=%%w&&set sub_year=%%x
for %%y in (%Source_Location%\%profile_Name%*) do set /a Source_Location_Numba+=1&echo       %%~ny
if not "%Source_Location_Numba%"=="" (
    echo    I found %Source_Location_Numba% file^(s^) match the keyword under the Source Folder.
    echo ---
)
call :WhichOne "%Final_location%\*%profile_Name%*",Portfolio_Folder
if "%Portfolio_Folder%"=="" goto open
echo ---
echo.
call :WhichOne "%Final_location%\%Portfolio_Folder%\*%sub_year%",subject
start "" "%Final_location%\%Portfolio_Folder%\%subject%"
goto open
:Global_Mode
for /f "delims=" %%u in ('dir /od /s/b %Final_Location%\%profile_Name%') do echo %%~tu    %%~pnxu
goto open
:WhichOne
set "IsthisOne="
Set "userchoice="
Set "decision="
Set "addition="
Setlocal EnableDelayedExpansion
:WhichChoose
set "result_Count=0"
for /f "delims=" %%z in ('dir /od/b "%~1!addition!"') do (
    set /a result_Count+=1
    set "IsthisOne!Result_Count!=%%~nz"
    echo       No.!Result_Count! %%~nz
)
If %result_Count% equ 0 echo No Result at all&goto :eof
set decision=%IsthisOne1%
If %result_Count% geq 2 (
    echo I found %result_Count% Results, which one?
    echo If you enter 0; result set to be empty; if you enter ";", this session will end.
    Set /p userchoice=I choose No.
    if defined IsThisOne!userchoice! call set "decision=%%IsThisOne!userchoice!%%"
    if "!userchoice!"=="0" set "decision="& goto ChooseIsEnd
    if "!userchoice!"==";" echo Okay. This session is complete. &goto open
    if not defined IsthisOne!userchoice! (
        Set "addition=!userchoice!"
        goto WhichChoose
    )
    echo you choice !decision!
)
:ChooseIsEnd
endlocal & set "%~2=%decision%" 2> nul
goto :eof