Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
$ThisFolder = Split-Path -Path "$pwd" -Leaf
Function choose-item() {
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
            Add-Content -LiteralPath "$progress\Projects_Links.md" -value "$pwd := $new_project.md"
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
If ($args) {
    if (Test-Path $args) {
        $Local:ThatFolder=Resolve-Path "$Args"
        $ThisFolder=(Split-Path -Path "$ThatFolder" -Leaf)
    }
    if ($args -eq "newpj") {
        New-Project
    }
}
# Logic 1:Search markdown File under profile folder
if ($Args) {
    $SearchFile=(Get-ChildItem -Path "$Profile_Location\*$args*.md" -recurse).FullName
    choose-item("$SearchFile")
    if ($SearchFile -eq $null) {
        Write-Host No Profile Name Contain that string: $args
    } else {
        $global:dafile_Name = (Get-Item $dafile).BaseName
        $host.UI.RawUI.WindowTitle="$dafile_Name"
        Write-Host "Dafile Set as $dafile_Name"
        Set-URL
        Exit
    }
}
# Logic 2: current directory exist Project_InFo.txt or not
If (Test-Path "$pwd\.Project_InFo.txt") {
    $global:dafile=(Get-Content -Path "$pwd\.Project_InFo.txt" -TotalCount 1)
    $global:dafile_Name=($dafile -split '\\')[-1]
    Exit
}
# Logic 3: Search string in Project_Links.md
$SearchFile=(Select-String -SimpleMatch -LiteralPath "$Projects_Links_File" -Pattern "$ThisFolder ").line
if ($SearchFile -eq $null) {
	Write-Host $pwd
    Write-Host "According to Projects_Links.md, current directory has not linking with any project profile. Please chose one profile to link with:"
    $SearchFile = (Get-ChildItem $Profile_Location\* -name)
    choose-item($SearchFile)
    Add-Content -LiteralPath "$Projects_Links_File" -value "$pwd := $dafile"
} else {
    choose-item($SearchFile)
    $separator = " := "
    $Temp = $dafile -Split $separator
    $Temp = $Temp[1]
    $global:dafile_Name = $Temp
    $global:dafile = "$Profile_Location\$Temp"
    $host.UI.RawUI.WindowTitle="$dafile_Name"
    Write-Host "According to projects_link.md, dafile set as $dafile_Name"
    Write-Host "the profile address is $dafile"
    Set-URL
}