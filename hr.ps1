$Today_date = (get-date -format "yyyy-MM-dd dddd")
$Today_Month = (get-date -format "yyyy-MM")
if (-Not $Profile_Location) {
	Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
}
$WebSites_Content = Get-Content "$Quick_Luanching_Dictionary"
$Folder_Locations = Get-Content "$Profile_Location\Searching_Variable_List1.md"
$Project_History="$Profile_Location\Project_Loading_History.md"
$Today_Note = "$Diary_Location\$Today_Month.md"
$pj = $Project_Location
# Write-Host ----------------------------- Finish Variable Initialization ----------------------------
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
	$n = 0
	$Candidates = @()

	# 搜索WebSites.md文件内容
	$WebSites_Content | ForEach-Object {
		if ($_ -match $param) {
			$url = [regex]::Match($_, '\((.*?)\)').Groups[1].Value
			if ($url) {
				$Candidates += [PSCustomObject]@{ Index = ++$n; Path = $url; Display = $url }
				Write-Host "[$n] $url"
			}
		}
	}

    # 搜索文件夹中的文件
    foreach ($Folder_Location in $Folder_Locations) {
        $ddc = Get-ChildItem "$Folder_Location\*$param*" -File
        foreach ($file in $ddc) {
            $Candidates += [PSCustomObject]@{ Index = ++$n; Path = $file.FullName; Display = "$($file.Name)" }
            Write-Host "[$n] $Folder_Location\$($file.Name)"
        }
    }
	# 确定结果
	if ($n -eq 0) {
		Write-Host "No Result Found"
		Return
	}
	if ($n -eq 1) {
		Start-Process $Candidates[0].Path
	} else {
		$chose = Read-Host "What is your choice? (Enter 0 to cancel)"
		if ($chose -eq 0) {
			Write-Host "Operation cancelled."
			Return
		}
		Start-Process $Candidates[$chose - 1].Path
	}
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
	if ($pj -ne $Project_Location) {Write-Host "Located Folder: $pj"}
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
		$pj=$Project_Location
		$daProfile="$Today_Note"
		Clear-Variable -Name daProfile_Name
		Continue
	}
	if ($User_input -eq "cl") {
		Read-Historical
		Continue
	}
	if ($User_input.StartsWith('cl ')) {
		Read-Historical
		$Num=$User_input.substring(3)
		$fullparts = Get-Variable -Name "cl$Num" -ValueOnly
		$fullparts = $fullparts.Split('=')
		$pj = $fullparts[1]
		Write-Host "-----------------------------"
		Write-Host "Project has change to: $pj"
		continue
	}
	if ($User_input -eq "ls") {
		Get-ChildItem -Path $pj
		Continue
	}
	if ($User_input.StartsWith('ls ')) {
		$ToSearch = $User_input.substring(3)
		Get-ChildItem -Path $pj\*$ToSearch*
		Continue
	}
	if ($User_input -eq "s") {
		Start-Process $pj
		Continue
	}
	if ($User_input.StartsWith('s ')) {
		$ToSearch = $User_input.substring(2)
		$SearchFile=(Get-ChildItem -Path "$pj\*$ToSearch*").FullName
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
			If ($pj -eq $Project_Location) {
				$pj = $PWD
				Write-Host "Project set as $pj"
			}
			Write-Host "Profile set as $daProfile"
			Write-Host "For Switch back, Set daProfile as dirprofile."
			readla(8)
			Continue
		}
		If ($pj -ne $Project_Location) {
			$SearchFile=(Get-ChildItem -Path "$pj\*$ToSearch*" -Directory).FullName
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
			$pj=$daFile
			Write-Host "Now The Project is $pj"
			Add-Content -LiteralPath "$Project_History" -value "$NowDateTime=$pj"
			readla(8)
		} else {
			Get-ChildItem -Path $pj
		}
		Continue
	}
	if ($User_input.StartsWith('"')) {
		$User_input = $User_input.Replace("`"","")
    }
	if (Test-Path -LiteralPath $User_input -PathType Container) {
		$pj=$User_input
		Write-host "Now, The Project is $pj"
		Add-Content -LiteralPath "$Project_History" -value "$NowDateTime=$pj"
		Continue
	}
	if (Test-Path -LiteralPath $User_input -PathType Leaf) {
		$Toward_Object_Name=($User_Input -split '\\')[-1]
		$File_Size = Format-FileSize((Get-Item $User_Input).Length)
		Move-Item -LiteralPath $User_Input -Destination $pj
		Add-Content -LiteralPath "$daProFile" -value "$Nowtime`: **[$Toward_Object_Name]($User_Input) `($File_Size`)**  has moved to $pj"
		Add-Content -LiteralPath "$Today_Note" -value "$Nowtime`: **[$Toward_Object_Name]($User_Input) `($File_Size`)**  has moved to $pj"
		Continue
	}
    if ($User_input -match "^\d+$") {
        readla ($User_input)
		Continue
    }
    If ($pj -ne $Project_Location) {
		Add-Content -LiteralPath "$daProFile" -value "$Today_date $Nowtime`: $User_input"
	}
	Add-Content -LiteralPath "$Today_Note" -value "$Today_date $Nowtime`: $User_input"
} until ($User_input -eq "wq")