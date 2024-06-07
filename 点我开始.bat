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
Set "Project_Location=%parent%\Projects"
Set "Profile_Folder_Name=Project_Notes"
Set "Projects_Link_File=Projects_Link.md"
Echo Okay, First of all, give me a existing path set as a project repository, Which is a folder that mainly Storage Project Folder:
Set /p User_Project_Location=
Echo What is the name of the folder where Storage Profiles:
Set /p User_Profile_Folder_Name=
Echo 5th, What is the Name of Achived Repository?
Set /p Achived_Repository_Name=
If exist %User_Project_Location% Set "Project_Location=%User_Project_Location%"
If "%User_Profile_Folder_Name%"=="" Set "Profile_Folder_Name=%User_Profile_Folder_Name%"
If "%Achived_Repository_Name%"=="" Set "Achived_Repository_Name=Achived_Repository"
echo All set!
Echo Projects_Link.md is a record file for linking a profile with those Projects, which is not under Project repository.
Echo Moving_History.md is a default logging file. In Case pushing a File toward project via script but no profile is linked with the Project Folder.
Echo --------------------
Setlocal Enabledelayedexpansion
echo Some path that you provide is not exist. two solutions:
Echo Solution #1: I Create the folder as you told me.
echo $Project_Location="!User_Project_Location!"
echo $Profile_Location="!User_Project_Location!\!User_Profile_Folder_Name!"
echo $Achived_Repository="!User_Project_Location!\!Achived_Repository_Name!"
echo $Projects_Link_File="!User_Project_Location!\!User_Profile_Folder_Name!\Projects_Link.md"
echo $Push_Pull_Logging="!User_Project_Location!\!User_Profile_Folder_Name!\Moving_History.md"
echo $Diary_Location="!User_Project_Location!\Diary_logs"
Echo --------------------
Echo Solution #2: I modify your input for those folder is not exist.
echo $Project_Location="!Project_Location!"
echo $Profile_Location="!Project_Location!\!Profile_Folder_Name!"
echo $Achived_Repository="!Project_Location!\!Achived_Repository_Name!"
echo $Projects_Link_File="!Project_Location!\!Profile_Folder_Name!\Projects_Link.md"
echo $Push_Pull_Logging="!Project_Location!\!Profile_Folder_Name!\Moving_History.md"
echo $Diary_Location="!Project_Location!\Diary_logs"
Echo --------------------
echo Enter "0" to start over again. 
Set /p User_Choose=I Choose solution #:
Set OffSet_Line=0
If "%User_Choose%"=="2" Set OffSet_Line=9
If "%User_Choose%"=="0" Goto new
Set Write_Numb=6
Set OffSet=0
For /f "delims= skip=32" %%i in (%~0) do (
    Set /a OffSet_Line-=1
    If !OffSet_Line! leq 0 (
        Set /a Write_Numb-=1
        If !Write_Numb! geq 0 (
            %%i
        )
    )
)>>%cd%\Project_variable.ini
pause
echo Now is the configuation for s.ps1.
Set /p Quick_Luanching_Dictionary=The path which save website.md:
If "!Quick_Luanching_Dictionary!"=="" Set "Quick_Luanching_Dictionary=!Project_Location!\!Profile_Folder_Name!"
Echo $Quick_Luanching_Dictionary="!Quick_Luanching_Dictionary!\Website.md"
Set "Searchable_Folder_Location_Count=0"
Echo Setting up Searchable Folder Location, you may Set up mutilple Searchable Folder Location by just adding out the number in the Variable Name. 
echo Now, You have to tell me which folder is searchable. when you are finish, don't type anything, just press the Enter.
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