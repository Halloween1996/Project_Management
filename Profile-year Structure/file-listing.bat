@echo off
set num=0
Set /p Child_Name=Please Enter child Name:
for /f "tokens=1,2,3* delims=," %%a in ("%Child_Name%") do (
	set child1=%%a
	set child2=%%b
	set child3=%%c
	set child4=%%d
)
setlocal EnableDelayedExpansion
echo OKay, then what do you want to put it on:
for /f "usebackq skip=39 tokens=* delims=" %%i in (%0) do (
	set /a num+=1
	set document!num!=%%~i
	echo No.!num! %%~i
)
set /p choice=I choice No.
echo ----
for %%u in (!choice!) do (
	echo Any Suffix to !document%%u!?
	Set /p Suffix%%~u=
	echo.
)
for /l %%o in (1 1 10) do echo.
echo ----------
echo EIC ADDTIONAL QUESTIONS
for %%v in (!choice!) do (
	for /l %%w in (1 1 4) do if defined child%%w (
	If "!Suffix%%~v!"=="" (
		echo !child%%w!,!document%%v!
	) else (
		echo !child%%w!,!document%%v!,!Suffix%%~v!
	)
)
echo.
)
echo Finish.
pause
exit
CERTIFICATE OF LIVE BIRTH
TUITION PAYMENT BILL
STUDENT GRADING REPORT
DAYCARE RECORD
ELECTRONIC BILL,COMED,CHICAGO IL
GAS BILL,PEOPLEGAS,CHICAGO IL