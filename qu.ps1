Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
$ThisFolder = Split-Path -Path "$pwd" -Leaf
Function Search-Result() {
    IF ($SearchFile.Count -gt 1) {
    	for($i=0;$i -lt $SearchFile.Count; $i++) {
    		$number= 1 + $i
    		Set-Variable -Name path$number -Value $SearchFile[$i]
    		Write-host "No.$number "$SearchFile[$i]
    	}
    	$chosen = read-host "You chose No."
        if ($chosen -eq "0") {
            $new_project = read-host "What is the New Project Name"
            if ($new_project.Length -lt 2) {
                Set-Variable -Name $new_project -Scope Local -Value "$ThisFolder"
                Write-Host "Too short, reset the name as: $$new_project"
            }
            Add-Content -LiteralPath "$progress\$new_project.md" -Value "Project_URL := $pwd"
		    $Nowtime = get-date -format "dddd yyyy-MM-dd hh:mm:ss tt"
		    Add-Content -LiteralPath "$progress\$new_project.md" -Value "This File Created at $Nowtime"
            Add-Content -LiteralPath "$progress\Projects_Links.md" -value "$Nowtime := $pwd := $new_project.md"
            exit
        }
    	$chosen = $chosen - 1
    	Set-Variable -Name dafile -Scope global -Value $SearchFile[$chosen]
    } else {
    	Set-Variable -Name dafile -Scope global -Value $SearchFile
    }
}
Function Set-URL() {
    $Local:Project_URL=Get-Content -Path "$dafile" -TotalCount 1
    $separator = " := "
    $Project_URL = $Project_URL -Split $separator
    $global:purl = $Project_URL[-1]
    Write-host "The Project URL is $purl."
}
Function New-Project() {
    $newpj = read-host "What is the New Project Name"
    if ($newpj.Length -lt 2) {
        Set-Variable -Name newpj -Scope Local -Value "$ThisFolder"
        Write-Host "Too short, reset the name as: $newpj"
    }
    Add-Content -LiteralPath "$Profile_Location\$newpj.md" -Value "Project_URL := $pwd"
    $Nowtime = get-date -format "dddd yyyy-MM-dd hh:mm:ss tt"
    Add-Content -LiteralPath "$Profile_Location\$newpj.md" -Value "This File Created at $Nowtime"
    Add-Content -LiteralPath "$Profile_Location\Projects_Links.md" -value "$pwd := $newpj.md"
    exit
}
# Initialized
if ($Args -eq "+") {
    $Week_Of_The_Year = get-date -UFormat %V
    $Today_Notes = get-date -format "yyyy-MM-dd ddd"
    Write-host "Today is $Today_Notes $($Week_Of_The_Year)周, the notes existense is:"
    Test-Path "$Diary_Location\$Today_Notes $($Week_Of_The_Year)周.md"
    $global:dafile = "$Diary_Location\$Today_Notes $($Week_Of_The_Year)周.md"
    $global:dafile_Name="$Today_Notes $($Week_Of_The_Year)周.md"
    Write-host 'Anyway, <Dafile> Variable has set.'
    Exit
}
if ($Args[-2] -eq "diary") {
    $Today_Notes=$args[-1]
    $SearchFile=(Get-ChildItem -Path "$Diary_Location\*$Today_Notes*.md" -recurse).FullName
    Search-Result($SearchFile)
    Write-Host "The diary file is $dafile"
    Exit
}
if ($args -eq "newpj") {
    New-Project
}
# Logic 1:Search markdown File under profile folder
if ($Args) {
    $SearchFile=(Get-ChildItem -Path "$Profile_Location\*$args*.md" -recurse).FullName
    $Search_String=$args
    Search-Result("$SearchFile")
    if (!$SearchFile) {
        Write-Host No Profile Name Contain that string: $args
    } else {
        $global:dafile_Name = (Get-Item $dafile).BaseName
        $host.UI.RawUI.WindowTitle="$dafile_Name"
        Write-Host "Dafile Set as $dafile_Name"
        Exit
    }
        # Logic 3: Search string in Project_Links.md
        $SearchFile=(Select-String -SimpleMatch -LiteralPath "$Projects_Link_File" -Pattern "$Search_String ").line
} else {
    $SearchFile=(Select-String -SimpleMatch -LiteralPath "$Projects_Link_File" -Pattern "$Pwd ").line
}
# Logic 2: current directory exist pjInFo.txt or not
If (Test-Path "$pwd\.profileInfo.txt") {
    $global:dafile=(Get-Content -Path "$pwd\.profileInfo.txt" -TotalCount 1)
    $global:dafile_Name=($dafile -split '\\')[-1]
    Exit
}
Write-Host "------------------------------"
if ($null -eq $SearchFile) {
	Write-Host $pwd
    Write-Host "According to Projects_Links.md, current directory has not linking with any project profile. Please chose one profile to link with:"
    $SearchFile = (Get-ChildItem $Profile_Location\* -name)
    Search-Result($SearchFile)
    Add-Content -LiteralPath "$Projects_Link_File" -value "$Nowtime := $pwd := $dafile"
} else {
    Search-Result($SearchFile)
    $separator = " := "
    $Temp = $dafile -Split $separator
    $global:purl = $Temp[1]
    $global:dafile_Name = $Temp[2]
    $global:dafile = "$Profile_Location\$($Temp[2])"
    $host.UI.RawUI.WindowTitle="$dafile_Name"
    Write-Host "According to projects_link.md, profile set as $dafile_Name"
    Write-Host "The profile address is $dafile"
    Write-Host "The project folder is $purl"
}