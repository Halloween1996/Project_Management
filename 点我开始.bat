@Echo off
echo Hi, If you are new, you may set up the variable your via this script,or press Enter all the way down.
echo if you are not, I only can do just open the existing configuation file for you.
echo existing configuation:
Set Num=0
if %Num% equ 0 goto new
for %%a in (%cd%/*.ini) do set /a num+=1&&echo [%num%] %%~na
Set /p input=Okay, Tell me what file you want to open:
Echo you want to open:
for %%b in (%cd%/*%input%*.ini) do Start "" "%%~b"
exit
:new
Set "Profile_Location=%CD%\Profile"
Set "Project_Location=%CD%\Project"
Set "Projects_Link_File=Projects_Link.md"
Echo Okay, Let's Set up:
Echo give me a existing folder path for Storage Profile:
Set /p User_Profile_Location=
Echo give me a existing folder path set as a project repository, Which is a folder that mainly Storage Project Folder:
Set /p User_Project_Location=
Echo 5th, What is the Name of Achived Repository?
Set /p Achived_Repository_Name=
If exist %User_Profile_Location% Set "Profile_Location=%User_Profile_Location%"
If exist %User_Project_Location% Set "Project_Location=%User_Project_Location%"
If "%Achived_Repository_Name%"=="" Set "Achived_Repository_Name=Achived_Repository"
echo All set!
Echo Projects_Link.md is a record file for linking a profile with those Projects, which is not under Project repository.
Echo Moving_History.md is a default logging file. In Case pushing a File toward project via script but no profile is linked with the Project Folder.
Echo --------------------
Setlocal Enabledelayedexpansion
echo Some path that you provide is not exist. two solutions:
Echo Solution #1: I Create the folder as you told me.
echo $Profile_Location="!User_Profile_Location!"
echo $Project_Location="!User_Project_Location!"
echo $Achived_Repository="!User_Project_Location!\!Achived_Repository_Name!"
echo $Projects_Link_File="!User_Projects_Links_File!\Projects_Link.md"
echo $Push_Pull_Logging="!User_Profile_Location!\Moving_History.md"
echo $Diary_Location="!User_Project_Location!\Diary_logs"
Echo --------------------
Echo Solution #2: I modify your input for those folder is not exist.
echo $Profile_Location="!Profile_Location!"
echo $Project_Location="!Project_Location!"
echo $Achived_Repository="!Project_Location!\!Achived_Repository_Name!"
echo $Projects_Link_File="!Profile_Location!\Projects_Link.md"
echo $Push_Pull_Logging="!Profile_Location!\Moving_History.md"
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
)
pause
echo Now is the configuation for s.ps1.
Echo Just like push got has a file that contain linking information; this also do. But it is for the Website.
Set /p Quick_Luanching_Dictionary=The path which save website.md:
If "!Quick_Luanching_Dictionary!"=="" Set "Quick_Luanching_Dictionary=%Profile_Location%"
Echo $Quick_Luanching_Dictionary="!Quick_Luanching_Dictionary!\Website.md"
Echo How about Set up a project Folder as your File Base?
Set /p My_Docs=
Echo $My_Docs="!My_Docs!"
Set "Searchable_Folder_Location_Count=0"
Echo Finally, Setting up Searchable Folder Location, you may Set up mutilple Searchable Folder Location by just adding out the number in the Variable Name. 
echo Now, You have to tell me which folder is searchable. when you are finish, don't type anything, just press the Enter.
:Searchable
Set /a Searchable_Folder_Location_Count+=1
Set /p Folder_Location=Folder_Location_!Searchable_Folder_Location_Count!:
If Not "!Folder_Location!"=="" (
    Echo $Folder_Location_!Searchable_Folder_Location_Count!=!Folder_Location!
    Set "Folder_Location="
) else (
    Echo All Done.
    Pause
    Exit
)
Goto Searchable