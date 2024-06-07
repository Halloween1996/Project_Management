@chcp 65001
@echo off
@Title %date%
set logging_Location=%cd%
set Final_Location=%cd%
for /f "usebackq delims=" %%c in ("%~dp0\project_variable.ini") do set %%c
set session_num=0
echo Hello, Here is version 1.2 and today is %date%.
echo log Directory: %logging_Location%\move_History.txt
if "%1"=="" goto open
Set "Init_Path=True"
set "File_Path=%~1"
:execution
for /f "usebackq delims=" %%i in ('%File_Path%') do set File_Name=%%~ni&&set File_Extension=%%~xi
for /f "usebackq tokens=1,2 delims=-" %%a in ("%File_Name%") do set profile_Name=%%a&&set sub_year=%%b
call :WhichOne "%Final_location%\*%profile_Name%*",Portfolio_Folder
call :WhichOne "%Final_location%\%Portfolio_Folder%\*%sub_year%*",subject
Set "Dafile=%Final_location%\%Portfolio_Folder%\%subject%"
Move "%File_Path%" "%Dafile%"&&echo %date% %time% - %File_Name%%File_Extension% has move toward %Dafile% >>%logging_Location%\move_History.txt
if "%Init_Path%"=="True" exit
:open
Set "Portfolio_Folder="
Set "subject="
set /a session_num+=1
echo.
echo ----------[Session %session_num%] ---------- Time: %time%
set /p profile_Name= Enter a Path to MOVE or a Keyword to OPEN folder        
if "%profile_Name%"==";" CMD
if "%profile_Name:~-1%"=="*" goto Global_Search_Mode
if exist "%profile_Name%" (
    set "File_Path=%profile_Name%"
    echo I think it is a path. moving file is executing.
    goto execution
)
for /f "usebackq tokens=1,2 delims=-" %%w in ('%profile_Name%') do set profile_Name=%%w&&set sub_year=%%x
call :WhichOne "%Final_location%\*%profile_Name%*",Portfolio_Folder
if "%Portfolio_Folder%"=="" goto open
echo ---
echo.
call :WhichOne "%Final_location%\%Portfolio_Folder%\*%sub_year%*",subject
Set "Project=%Final_location%\%Portfolio_Folder%\%subject%"
Set "Profile=%Project%\Project.md"
Type "%Profile%"
echo.
Echo Don't type anything, Just Press "Enter" key to open target folder;
Echo Enter "ref5" refreshing contexts; Enter "wq" goes back to main menu.
Echo Enter whatever you want to leave a comments:
:Leave_a_Comments
Set "comments="
Set /p comments=
if "%comments%"=="wq" (
	goto open
)
if "%comments%"=="" (
	Start "" "%Project%"
	goto Leave_a_Comments
)
if "%comments%"=="ref5" (
	cls
	Type "%Profile%"
	goto Leave_a_Comments
)
Echo %date% %Time% - %comments%>>"%Profile%"
goto Leave_a_Comments

:Global_Search_Mode
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