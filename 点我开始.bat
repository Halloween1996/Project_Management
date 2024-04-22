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
Set "Projects_Link_File=%CD%\Projects_Link.md"
Echo Okay, Let's Set up:
Echo 1st, give me a folder path for Storage Profile:
Set /p User_Profile_Location=
If exist %User_Profile_Location% Set "Profile_Location=%User_Profile_Location%"
Echo 2nd, give me a folder path set as a project repository , Which is a folder that mainly Storage Project Folder:
Set /p User_Project_Location=
If exist %User_Project_Location% Set "Project_Location=%User_Project_Location%"
Echo 3rd, For those Projects which is not under Project repository, Provide me a Folder path to save those Project Folder path and related Profile Name Info.
Set /p User_Projects_Links_File= 
If exist %User_Projects_Link_File% Set "Projects_Link_File=%User_Projects_Links_File%"
Echo 4th, I need to set a Profile Name as a default logging file. In Case you push a File toward project via script but no profile is linked with the Project Folder.
Set /p Push_Pull_Logging=
If "%Push_Pull_Logging%"=="" Set "Push_Pull_Logging=Moving_History"
echo All set!
echo --------------
Setlocal Enabledelayedexpansion
echo Some path that you provide is not exist. two solutions:
Echo Solution #1: I Create the folder as you told me.
echo $Profile_Location="!User_Profile_Location!"
echo $Project_Location="!User_Project_Location!"
echo $Projects_Link_File="!User_Projects_Links_File!\Projects_Link.md"
echo $Push_Pull_Logging="!User_Profile_Location!!Push_Pull_Logging!.md"
Echo --------------------
Echo Solution #2: I modify your input for those folder is not exist.
echo $Profile_Location="!Profile_Location!"
echo $Project_Location="!Project_Location!"
echo $Projects_Link_File="!Projects_Link_File!"
echo $Push_Pull_Logging="!Profile_Location!!Push_Pull_Logging!.md"
Set /p User_Choose=I Choose solution #:
Set OffSet_Line=0
If "%User_CHoose%"=="2" Set OffSet_Line=7
Set Write_Numb=4
Set OffSet=0
For /f "delims= skip=34" %%i in (%~0) do (
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