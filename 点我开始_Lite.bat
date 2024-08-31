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
Echo Tips: you may type nothing and just press Enter.
Set /p Project_Location=
if "%Project_Location%"=="" Set "Project_Location=%parent%"
if not exist %Project_Location% Set "Project_Location=%parent%"
Set "Profile_Folder_Name=Project_Notes"
Set "Achived_Repository_Name=Achived_Repository"
Set "Projects_Link_File=Projects_Link.md"
md "%Project_Location%\%Profile_Folder_Name%"
md "%Project_Location%\%Achived_Repository_Name%"
md "%Project_Location%\%Profile_Folder_Name%\Diary_logs"
echo All set!
Echo Projects_Link.md is a record file for linking a profile with those Projects, which is not under Project repository.
Echo Moving_History.md is a default logging file. In Case pushing a File toward project via script but no profile is linked with the Project Folder.
Echo --------------------
Setlocal Enabledelayedexpansion
echo $Project_Location="!Project_Location!">%cd%\Project_variable.ini
echo $Profile_Location="!Project_Location!\!Profile_Folder_Name!">>%cd%\Project_variable.ini
echo $Diary_Location="!Project_Location!\!Profile_Folder_Name!\Diary_logs">>%cd%\Project_variable.ini
echo $Achived_Repository="!Project_Location!\!Achived_Repository_Name!">>%cd%\Project_variable.ini
echo $Projects_Link_File="!Project_Location!\!Profile_Folder_Name!\Projects_Link.md">>%cd%\Project_variable.ini
echo $Push_Pull_Logging="!Project_Location!\!Profile_Folder_Name!\Moving_History.md">>%cd%\Project_variable.ini
echo $Quick_Luanching_Dictionary="!Project_Location!\!Profile_Folder_Name!\Website.md">>%cd%\Project_variable.ini
echo .lnk >>%cd%\Sort_bank.ini
echo .png .jpg .jpeg .heif^|Picture>>%cd%\Sort_bank.ini
echo .pdf .csv .md ^|Documents>>%cd%\Sort_bank.ini
echo.>>"!Project_Location!\!Profile_Folder_Name!\Projects_Link.md"
echo.>>"!Project_Location!\!Profile_Folder_Name!\Moving_History.md"
echo.>>"!Project_Location!\!Profile_Folder_Name!\Website.md"
Set "Searchable_Folder_Location_Count=1"
Echo $Folder_Location_!Searchable_Folder_Location_Count!="%USERPROFILE%\Downloads"
Echo Now, you are Setting up Searchable Folder Location, you may Set up mutilple Searchable Folder Location by just adding out the number in the Variable Name. 
echo when you are finish, don't type anything, just press the Enter.
:Searchable
Set /a Searchable_Folder_Location_Count+=1
Set /p Folder_Location=Folder_Location_!Searchable_Folder_Location_Count!:
If Not "!Folder_Location!"=="" (
    Echo $Folder_Location_!Searchable_Folder_Location_Count!="!Folder_Location!">>"!Project_Location!\!Profile_Folder_Name!\Searching_Variable_List.md"
    Set "Folder_Location="
) else (
    Echo All Done.
    Pause
    Exit
)
Goto Searchable