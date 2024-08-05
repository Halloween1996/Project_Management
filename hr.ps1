if (-Not $Profile_Location) {
	Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
	Get-Content $Profile_Location\Searching_Variable_List.md|Invoke-Expression
}
$Today_date = (get-date -format "yyyy-MM-dd dddd")
$Today_Note = "$PSScriptRoot\logs\$Today_date.md"
$daProfile = "$Today_Note"
$Project = $Project_Location
if (!(Test-Path “$daProfile”)) {ni $daProfile -type file}
Function Search-Result() {
    IF ($SearchFile.Count -gt 1) {
    	for($i=0;$i -lt $SearchFile.Count; $i++) {
    		$number= 1 + $i
    		Set-Variable -Name path$number -Value $SearchFile[$i]
    		Write-host "No.$number "$SearchFile[$i]
    	}
    	$chosen = read-host "You chose No."
    	$chosen = $chosen - 1
    	Set-Variable -Name dafile -Scope global -Value $SearchFile[$chosen]
    } else {
    	Set-Variable -Name dafile -Scope global -Value $SearchFile
    }
}
Function readla ($param) {
	[int]$n = 0
	foreach($line in Get-Content -LiteralPath "$daProfile" -tail $param) {
		$n++
		Write-Host "`r"
		Write-Host "$n : "$line
	}
	Write-Host --------------------------------------------------------------------------------
}
Function Format-FileSize() {
	Param ([int]$size)
		If ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
		ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
		ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
		ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
		ElseIf ($size -gt 0) {[string]::Format("{0:0.00} B", $size)}
		Else {""}
	}
Function Search-File ($param) {
	[int]$Searching_Location_Index_Num=1
	while (Get-Variable Folder_Location_$Searching_Location_Index_Num -erroraction 'silentlycontinue') {
		$Folder_Location = (Get-Variable Folder_Location_$Searching_Location_Index_Num -ValueOnly)
		$ddc = Get-ChildItem "$Folder_Location\*$param*" -Name
		foreach($line in $ddc) {
			$n++
			Set-Variable -Name abc_$n -Scope script -value "$Folder_Location\$line"
			Write-Host [$n] $line
		}
		$Searching_Location_Index_Num++
	}
	# Write-Host "Does not exist Search_Folder_Location_$Searching_Location_Index_Num++"
	# Determinate Result
	if ($n -eq 0) {
		Write-Host "No Result Found"
		Exit
	}
	if ($n -gt 1) {
		$chose = Read-Host "What is your chose?"
		$abc_1 = Get-Variable abc_$chose -ValueOnly
	}
	Start-Process "$abc_1"
}
if ($args) {
    If ($args -match "^\d+$") {
        $Number=$args[0]
        readla ($Number)
    } else {
        $Nowtime = get-date -format "yyyy-MM-dd dddd HH:mm:ss tt"
        Add-Content -LiteralPath "$Today_Note" -value "$Today_date $Nowtime`: $args"
    }
exit
}
Write-Host "1. Type Any Number to Review how many last messages that you have leaved to the profile. "
Write-Host "2. Type Anything to Leave your message to the profile."
Write-Host "3. If you want to search specific keyword from the Profile, Begin with Question Mark(?)"
Write-Host "4. But, If your input begin with a colon(:), your message would EXECUTED as a command rather than been recorded"
Write-Host "5. cls, ls, s are the special manipulating commands."
Write-Host --------------------------------------------------------------------------------
Write-Host "Last 10 messages:"
readla (10)
Do
{
	$Nowtime = get-date -format "hh:mm:ss tt"
	if ($Project -ne $Project_Location) {Write-Host $Project}
	Write-Host "                         [$Nowtime]`n"
	$User_input=Read-Host
		if ($User_input -eq "") {
		Clear-Host
		readla (12)
		Continue
	}
	if ($User_input -eq "cls") {
		$Project = $Project_Location
		$daProfile = "$Today_Note"
		Continue
	}
	if ($User_input -eq "ls") {
		Get-ChildItem -Path $Project
		Continue
	}
	if ($User_input -eq "s") {
		Invoke-Item $Project
		Continue
	}
	if ($User_input.StartsWith('s ')) {
		$ToSearch = $User_input.substring(2)
		$SearchFile=(Get-ChildItem -Path "$Project\*$ToSearch*").FullName
		if (!$null -eq $SearchFile) {
			Search-Result("$SearchFile")
			Invoke-Item $daFile
		} else {
			Write-Host "Searching $ToSearch by File..."
			Search-File ($ToSearch)
		}
		Continue
	}
	if ($User_input.StartsWith(':')) {
		$temp_command = $User_input.substring(1)
		Invoke-Expression $temp_command
		continue
	}
	if ($User_input.StartsWith('?')) {
		$Todone_Notes = $User_input.substring(1)
		$SearchFile=(Select-String -SimpleMatch -LiteralPath "$daProFile" -Pattern "$ToDone_Notes").line
		Write-host ----------------------------
		Write-Host $SearchFile
		Continue
	}
	if ($User_input.StartsWith('#')) {
		Add-Content -LiteralPath "$daProFile" -value "$User_input"
		Continue
	}
	if ($User_input.StartsWith('@')) {
		$ToSearch = $User_input.substring(1)
		$SearchFile=(Get-ChildItem -Path "$Project\*$ToSearch*" -Directory).FullName
		Search-Result("$SearchFile")
		$daProfile="$dafile\profile.md"
		$Project=$daFile
		Write-Host "Now The Project is $Project"
		Add-Content -LiteralPath "$Today_Note" -value "located Profile from $daFile"
		readla(8)
		Continue
	}
	if ($User_input.StartsWith('!')) {
		$ToSearch = $User_input.substring(1)
		$SearchFile=(Get-ChildItem -Path "$Project_Location\*$ToSearch*" -Directory).FullName
		Search-Result("$SearchFile")
		$daProfile="$dafile\profile.md"
		$Project=$daFile
		Clear-Host
		Write-Host "Now The Project is $Project"
		Add-Content -LiteralPath "$Today_Note" -value "located Profile from $daFile"
		readla(8)
		Continue
	}
	if (Test-Path -LiteralPath $User_input -PathType Container) {
		$Project=$User_input
		Write-host "Now, The Project is $Project"
		Add-Content -LiteralPath "$daProFile" -value "$Nowtime`: $Project has located"
		Add-Content -LiteralPath "$Today_Note" -value "$Nowtime`: $Project has located"
		Continue
	}
	if (Test-Path -LiteralPath $User_input -PathType Leaf) {
		$Toward_Object_Name=($User_Input -split '\\')[-1]
		$File_Size = Format-FileSize((Get-Item $User_Input).Length)
		Move-Item -LiteralPath $User_Input -Destination $Project
		Add-Content -LiteralPath "$daProFile" -value "$Nowtime`: **[$Toward_Object_Name]($User_Input) `($File_Size`)**  has movced"
		Add-Content -LiteralPath "$Today_Note" -value "$Nowtime`: **[$Toward_Object_Name]($User_Input) `($File_Size`)**  has movced"
		Continue
	}
    if ($User_input -match "^\d+$") {
        readla ($User_input)
		Continue
    }
    If ($Project -ne $Project_Location) {
		Add-Content -LiteralPath "$daProFile" -value "$Today_date $Nowtime`: $User_input"
	}
	Add-Content -LiteralPath "$Today_Note" -value "$Today_date $Nowtime`: $User_input"
} until ($User_input -eq "hr")
Write-Host "You're exit the appended edit mode now"