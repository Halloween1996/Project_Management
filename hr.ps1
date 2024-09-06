$Today_date = (get-date -format "yyyy-MM-dd dddd")
$Today_Month = (get-date -format "yyyy-MM")
if (-Not $Profile_Location) {
	Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
	Get-Content $Profile_Location\Searching_Variable_List.md|Invoke-Expression
}
$Project_History="$Profile_Location\Project_Loading_History.md"
$Today_Note = "$Diary_Location\$Today_Month.md"
$Project = $Project_Location
# Write-Host ---------------------------------------------------------------- Finish Variable setting
$daProfile = "$Today_Note"
if (!(Test-Path $daProfile)) {New-item $daProfile -type file}
Function Search-Result() {
    IF ($SearchFile.Count -gt 1) {
    	for($i=0;$i -lt $SearchFile.Count; $i++) {
    		$number= 1 + $i
    		Set-Variable -Name path$number -Value $SearchFile[$i]
    		Write-host "No.$number "$SearchFile[$i]
    	}
    	$chosen = read-host "You chose No."
        if ($chosen -eq 0) {
            Write-Host "Operation cancelled."
            return
        }
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
function Read-Historical {
    $lines = Get-Content -Path "$Project_History" -Tail 10
    for ($i = 0; $i -lt $lines.Length; $i++) {
        Set-Variable -Name "cl$($i + 1)" -Value $lines[$i] -Scope Global
		Write-Host $($i+1) $lines[$i]
    }
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
# Write-Host "1. Type Any Number to Review how many last messages that you have leaved to the profile. "
# Write-Host "2. Type Anything to Leave your message to the profile."
# Write-Host "3. If you want to search specific keyword from the Profile, Begin with Question Mark(?)"
# Write-Host "4. But, If your input begin with a colon(:), your message would EXECUTED as a command rather than been recorded"
# Write-Host "5. cls, ls, s are the special manipulating commands. Don't Type them alone."
Write-Host "Hi, Today is $Today_date"
Write-Host --------------------------------------------------------------------------------
readla (30)
Do
{
	$Nowtime = get-date -format "hh:mm:ss tt"
	if ($Project -ne $Project_Location) {Write-Host $Project}
	if ($daProfile -ne "$Today_Note") {$daProfile_Name=($daProfile -split '\\')[-2]}
	Write-Host "                         [$Nowtime]   $daProfile_Name`n"
	$User_input=Read-Host
	$NowDateTime = get-date -format "yyyyMMdd_HH:mm:ss"
	if ($User_input -eq "") {
		Clear-Host
		readla (30)
		Continue
	}
	if ($User_input -eq "cls") {
		$Project=$Project_Location
		$daProfile="$Today_Note"
		Clear-Variable -Name daProfile_Name
		Continue
	}
	if ($User_input -eq "cl") {
		Read-Historical
		Continue
	}
	if ($User_input.StartsWith('cl ')) {
		$Num=$User_input.substring(3)
		$fullparts = Get-Variable -Name "cl$Num" -ValueOnly
		$fullparts = $fullparts.Split('=')
		$Project = $fullparts[1]
		Write-Host "Project has change to: $project"
		continue
	}
	if ($User_input -eq "ls") {
		Get-ChildItem -Path $Project
		Continue
	}
	if ($User_input.StartsWith('ls ')) {
		$ToSearch = $User_input.substring(3)
		Get-ChildItem -Path $Project\*$ToSearch*
		Continue
	}
	if ($User_input -eq "s") {
		Start-Process $Project
		Continue
	}
	if ($User_input.StartsWith('s ')) {
		$ToSearch = $User_input.substring(2)
		$SearchFile=(Get-ChildItem -Path "$Project\*$ToSearch*").FullName
		if (!$null -eq $SearchFile) {
			Search-Result("$SearchFile")
			Start-Process $daFile
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
		$SearchFile|Write-Host
		Continue
	}
	if ($User_input.StartsWith('#')) {
		Add-Content -LiteralPath "$daProFile" -value "$User_input"
		Continue
	}
	if ($User_input.StartsWith('\')) {
		$ToSearch = $User_input.substring(1)
		if ($ToSearch.StartsWith('\')) {
			Set-Variable -Name dirprofile -Value $daProfile
			$Profile_Search=$ToSearch.substring(1)
			$SearchFile=(Get-ChildItem -Path "$Profile_Location\*$Profile_Search*" -Recurse).FullName
			Search-Result("$SearchFile")
			$daProfile="$dafile"
			Clear-Host
			If ($Project -eq $Project_Location) {
				$Project = $PWD
				Write-Host "Project set as $Project"
			}
			Write-Host "Profile set as $daProfile"
			Write-Host "For Switch back, Set daProfile as dirprofile."
			readla(8)
			Continue
		}
		If ($Project -ne $Project_Location) {
			$SearchFile=(Get-ChildItem -Path "$Project\*$ToSearch*" -Directory).FullName
			Add-Content -LiteralPath "$Today_Note" -value "located Profile from $daFile"
		} else {
			$SearchFile=(Get-ChildItem -Path "$Project_Location\*$ToSearch*" -Directory).FullName
		}
		Search-Result("$SearchFile")
		If (Test-Path "$dafile" -PathType Container) {
			$daProfile="$dafile\Folder_Profile.md"
			if (!(Test-Path $daProfile)) {
				Write-Host "$daProfile did not found. I Create one for you."
				New-item -Path "$dafile" -Name Folder_Profile.md
				(Get-ChildItem $daProfile).attributes="Hidden"
			}
			$Project=$daFile
			Write-Host "Now The Project is $Project"
			Add-Content -LiteralPath "$Project_History" -value "$NowDateTime=$Project"
			readla(8)
		} else {
			Get-ChildItem -Path $Project
		}
		Continue
	}
	if ($User_input.StartsWith('"')) {
		$User_input = $User_input.Replace("`"","")
    }
	if (Test-Path -LiteralPath $User_input -PathType Container) {
		$Project=$User_input
		Write-host "Now, The Project is $Project"
		Add-Content -LiteralPath "$Project_History" -value "$NowDateTime=$Project"
		Continue
	}
	if (Test-Path -LiteralPath $User_input -PathType Leaf) {
		$Toward_Object_Name=($User_Input -split '\\')[-1]
		$File_Size = Format-FileSize((Get-Item $User_Input).Length)
		Move-Item -LiteralPath $User_Input -Destination $Project
		Add-Content -LiteralPath "$daProFile" -value "$Nowtime`: **[$Toward_Object_Name]($User_Input) `($File_Size`)**  has moved to $Project"
		Add-Content -LiteralPath "$Today_Note" -value "$Nowtime`: **[$Toward_Object_Name]($User_Input) `($File_Size`)**  has moved to $Project"
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
} until ($User_input -eq "wq")