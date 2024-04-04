if (-not $Push_Pull_Logging) {Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression}
$Nowtime = get-date -format "yyyy-MM-dd dddd HH:mm:ss tt"
If ($purl -eq $null) {
    $purl = "NotAPath"
}
IF (Test-Path -path $purl) {
    $Toward_Path=$Purl
    $Push_Pull_Logging=$dafile
    Write-host " Current Project is $dafile_Name"
    Write-host "The Project URL is $purl, it is set to be Default path Now"
} else {
    $Toward_Path="$($Env:Userprofile)\Downloads\Arrangement\"
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
Function choose-Folder($Param) {
    Do
    {
        If ($Param -eq $null) {
            Write-host "No Project Folder has been found."
            Exit
        }
        IF ($Param.Count -eq 1) {
            Set-Variable -Name MyChoose -Scope global -Value $Param
            Break
        }
    	for($i=0;$i -lt $Param.Count; $i++) {
    	    $number= 1 + $i
		    Set-Variable -Name path$number -Value $Param[$i]
            $ThisFolder=((Get-Variable path$number -ValueOnly)-split '\\')[-1]
    		Write-host "Id $number :"$ThisFolder
    	}
        $chosen = read-host "You chose"
        # [bool](Get-Variable path$chosen -Scope 'Local')
        if ([bool](Get-Variable path$chosen -Scope 'Local' -ErrorAction 'Ignore')) {
            $chosen = $chosen - 1
            Set-Variable -Name MyChoose -Scope global -Value $Param[$chosen]
            Write-Host "I got it."
            Break
        } else {
            $Param=(Get-ChildItem -path "$Project_Location\*$chosen*")
            Write-Host "Redirect Keyword to $chosen"
            Continue
        }
    } until ((Test-path "$MyChoose") -eq $true)
}
# Initialized
if ($args[-1] -eq ":") {
    Set-Variable -Name Keyword -scope Script -Value $args[-2]
    $Log=1
} else {
    Set-Variable -Name Keyword -scope Script -Value $args[-1]
}
# if the last arg is not a path, search related folder as keyword. otherwise, send file to default folder.
$IsPathNot = Test-Path -path $Keyword
Write-Host "If Last Args is a Path, Move to defalut folder. $IsPathNot"
if (-Not $IsPathNot) {
    # Write-Host The keyword is $Keyword
    $Search_Project=(Get-ChildItem -path "$Project_Location" -Directory | Select-String "$Keyword" -List)
    choose-Folder($Search_Project)
    $Toward_Path=$MyChoose
    if (Test-Path "$Toward_Path\.Project_InFo.txt") {
        $Local:Push_Pull_Logging=Get-Content -Path "$Toward_Path\.Project_InFo.txt" -TotalCount 1
        Write-host "I Found .Project_Info.txt, record the event toward $Push_pull_Logging"
    } else {
        if ($log -eq 1) {
		    Write-Host "Please select a profile to log this push Event"
		    $Search_Project=(Get-ChildItem -path "$Profile_Location" -File)
            choose-Folder($Search_Project)
		    $Local:Push_Pull_Logging=$MyChoose
        } else {
            $Search_file=(Get-ChildItem -path "$Profile_Location" -Name "*$keyword*" -File)
            if ($Search_file.Count -eq 1) {
                $Local:Push_Pull_Logging="$Profile_Location\$Search_file"
            }
            if ($Search_file.Count -gt 1) {
                Write-Host $Search_file.Count "Profile(s) Related with the keyword: $keyword"
                choose-Folder($Search_file)
                $Local:Push_Pull_Logging=$MyChoose
            }
        }
	}
}
Write-Host "This Event would Log to $Push_Pull_Logging,"
# Write-Host "This\Those file(s) will sent to $Toward_Path"
$Toward_Path_Name=($Toward_Path -split '\\')[-1]
# Excution
Foreach($Line in $args) {
    if (Test-Path $Line) {
        $Object_Path=Resolve-Path $Line
        $Toward_Object_Name=($Object_Path -split '\\')[-1]
        $File_Size = Format-FileSize((Get-Item $Object_Path).Length)
        Move-Item -Path $Object_Path -Destination $Toward_Path
        Add-Content -LiteralPath "$Push_Pull_Logging" -value "- $Nowtime : **$Toward_Object_Name `($File_Size`)** Move toward [$Toward_Path_Name]($Toward_Path)"
        Write-Host "$Toward_Object_Name ($File_Size) --> $Toward_Path_Name"
    }
}