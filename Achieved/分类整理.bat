@echo off
set ddc=Events
for %%d in (%ddc% "%~n0") do set %%~d=1685key
cd "%UserProfile%\downloads"
if not "%1"=="" cd "%~1"
setlocal enabledelayedexpansion
If exist "%cd%\type.txt" goto extension
:databank
for /f "skip=27 tokens=1,* delims= " %%f in (C:\Events\Development\Arrange.bat) do (
  for %%p in (%%g) do (
    for %%e in ("%cd%\*%%~p") do (
      if not defined %%~ne (
	    echo %%~nxe
        if not exist "%%f" md "%%f"
        move "%%~nxe" "%%f"&&echo **%%~nxe** to *%%f*>>C:\Events\Development\MoveHistory.md)
    )
  )
)
:extension
for %%z in ("%cd%\*") do if not defined %%~nz (
	set abcd=%%~xz
	if not exist "Arrangement\!abcd:~1!" md "Arrangement\!abcd:~1!"
	echo %%~nxz
	move "%%z" "%cd%\Arrangement\!abcd:~1!"&&echo **%%~z** to *categories-!abcd!*>>C:\Events\Development\MoveHistory.md)
IF not "%ERRORLEVEL%"=="0" pause
rd %1
NotePadPlusPlus.lnk C:\Events\Development\MoveHistory.md
exit
:databank
C:\ReaIta\Scripts .bat .vbs
C:\Events\Courses .docx .doc .rtf .ppt .pptx .pdf .mp4 .mkv .xlsx
C:\Users\Maxel\Downloads\Arrangement\Compressed .7z .zip .rar
C:\Users\Maxel\Downloads\Arrangement\Programs .exe
C:\15th\Icons .ico .icon
\\Halloween\photo\Illustration\pixiv _p*
\\halloween\photo\Illustration .jpg .png .jpeg
\\Halloween\music\Internet .mp3 .wav .ape .wma .flac .m4a .lrc