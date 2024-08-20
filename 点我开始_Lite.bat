@Echo off
set current=%cd%
pushd ..
set parent=%cd%
popd
echo current directory %current%
echo parent directory %parent%
cd %parent%
cls
echo Hi, If you are new, you may set up the variable your via this script,or press Enter all the way down.
echo if you are not, I only can do just open the existing configuation file for you.
echo existing configuation:
Set Num=0
for %%a in (%~dp0\*.ini) do set /a num+=1&&echo [%num%] %%~na
if %Num% equ 0 goto new
Set /p input=Okay, Tell me what file you want to open:
Echo you want to open:
for %%b in (%~dp0\*%input%*.ini) do Start "" "%%~b"
exit
:new
Set "Project_Location=%parent%\Projects_Repository"
Echo give me a existing path set as a project repository, Which is a folder that mainly Storage Project:
Set /p User_Project_Location=
Set "Profile_Folder_Name=Project_Notes"
Set "Achived_Repository_Name=Achived_Repository"
Set "Projects_Link_File=Projects_Link.md"
echo All set!
Echo Projects_Link.md is a record file for linking a profile with those Projects, which is not under Project repository.
Echo Moving_History.md is a default logging file. In Case pushing a File toward project via script but no profile is linked with the Project Folder.
Echo --------------------
Setlocal Enabledelayedexpansion
echo $Profile_Location="!Project_Location!\!Profile_Folder_Name!">>%cd%\Project_variable.ini
echo $Achived_Repository="!Project_Location!\!Achived_Repository_Name!">>%cd%\Project_variable.ini
echo $Diary_Location="!Project_Location!\Diary_logs">>%cd%\Project_variable.ini
echo $Projects_Link_File="!Project_Location!\!Profile_Folder_Name!\Projects_Link.md">>%cd%\Project_variable.ini
echo $Push_Pull_Logging="!Project_Location!\!Profile_Folder_Name!\Moving_History.md">>%cd%\Project_variable.ini
echo $Quick_Luanching_Dictionary=!Project_Location!\!Profile_Folder_Name!\Website.md>>%cd%\Project_variable.ini
echo .lnk >>%cd%\Sort_bank.ini
Set "Searchable_Folder_Location_Count=0"
Echo Now, you are Setting up Searchable Folder Location, you may Set up mutilple Searchable Folder Location by just adding out the number in the Variable Name. 
echo when you are finish, don't type anything, just press the Enter.
:Searchable
Set /a Searchable_Folder_Location_Count+=1
Set /p Folder_Location=Folder_Location_!Searchable_Folder_Location_Count!:
If Not "!Folder_Location!"=="" (
    Echo $Folder_Location_!Searchable_Folder_Location_Count!=!Folder_Location! >>!cd!\Searching_Variable_List.md
    Set "Folder_Location="
) else (
    Echo All Done. Please Move Searching_Variable_List.md to the folder where Storage Profiles.
    Pause
    Exit
)
Goto Searchable