@Echo off
set current=%cd%
pushd ..
set parent=%cd%
popd
echo current directory is %current%
echo parent directory is %parent%
if exist Project_variable.ini (
	Start "" "%~dp0\Project_variable.ini"
	exit
)
:new
Echo give me a existing path set as a project repository, Which is a folder that mainly Storage Project:
Echo Tips: you may type nothing, just press Enter to finish the setup.
Set /p Project_Location=
if "%Project_Location%"=="" Set "Project_Location=%parent%"
if not exist %Project_Location% Set "Project_Location=%parent%"

Echo --------------------
setlocal
setx PATH "%PATH%;%cd%"
echo Current directory added to system PATH.
endlocal
Echo --------------------- Setting up Folder.
Set "Profile_Folder_Name=Project_Notes"
Set "Achived_Repository_Name=Achived_Repository"
if not exist %Profile_Folder_Name% (
	md "%Profile_Folder_Name%"
	md "%Profile_Folder_Name%\Diary_logs"
)
md "%Project_Location%\%Achived_Repository_Name%"
Echo --------------------- Setting up Project_variable.ini : The configuation file of hr.ps1 and others.
echo $Project_Location="%Project_Location%">%cd%\Project_variable.ini
echo $Profile_Location="%cd%\%Profile_Folder_Name%">>%cd%\Project_variable.ini
echo $Diary_Location="%cd%\%Profile_Folder_Name%\Diary_logs">>%cd%\Project_variable.ini
echo $Achived_Repository="%Project_Location%\%Achived_Repository_Name%">>%cd%\Project_variable.ini
echo $Push_Pull_Logs="%cd%\%Profile_Folder_Name%\Moving_History.md">>%cd%\Project_variable.ini
echo $Quick_Luanching_Dictionary="%cd%\%Profile_Folder_Name%\Website.md">>%cd%\Project_variable.ini
Echo --------------------- Setting up Sort_bank.ini : When you use a.ps1 and no sort.txt under the Current Directory, it will follow up this file.
echo .lnk >>%cd%\Sort_bank.ini
echo .png .jpg .jpeg .heif^|Picture>>%cd%\Sort_bank.ini
echo .pdf .csv .md ^|Documents>>%cd%\Sort_bank.ini
Echo -------------------- Creating a configuation files and a file moving report files under Project_Notes.
echo.>>"%cd%\%Profile_Folder_Name%\Moving_History.md"
echo.>>"%cd%\%Profile_Folder_Name%\Website.md"
Echo %USERPROFILE%\Downloads>>"!Project_Location!\!Profile_Folder_Name!\Searching_Variable_List.md"
echo All necessarily configuation are set!
Echo Now, you are Setting up Searchable Folder Location, you may Set up mutilple Searchable Folder Location by just adding out the number in the Variable Name. 
echo when you are finish, don't type anything, just press the Enter.
:Searchable
Set /a Searchable_Folder_Location_Count+=1
Set /p Folder_Location=Folder_Location_!Searchable_Folder_Location_Count!:
If Not "!Folder_Location!"=="" (
    Echo !Folder_Location!>>"!Project_Location!\!Profile_Folder_Name!\Searching_Variable_List.md"
    Set "Folder_Location="
) else (
    Echo All Done.
    Pause
    Exit
)
Goto Searchable