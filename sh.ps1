Function Format-FileSize() {
Param ([int]$size)
    If ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0) {[string]::Format("{0:0.00} B", $size)}
    Else {""}
}
Function Select-Result($Search_Item) {
    Do
    {
        # Write-host The Search_Location is "$Search_Location, and the Search_string is $Search_Item"
        If ($null -eq $Search_Item) {
            Write-host "No Project Folder has been found."
            Exit
        }
        IF ($Search_Item.Count -eq 1) {
            Set-Variable -Name MyChoose -Scope script -Value $Search_Item
            Break
        }
        for($i=0;$i -lt $Search_Item.Count; $i++) {
            $number= 1 + $i
            Set-Variable -Name path$number -Value $Search_Item[$i]
            $ThisFolder=((Get-Variable path$number -ValueOnly)-split '\\')[-1]
            Write-host "Index $number :"$ThisFolder
        }
        $chosen = read-host "You chose"
        # [bool](Get-Variable path$chosen -Scope 'Local')
        if ([bool](Get-Variable path$chosen -Scope 'Local' -ErrorAction 'Ignore')) {
            $chosen = $chosen - 1
            Set-Variable -Name MyChoose -Scope script -Value $Search_Item[$chosen]
            Write-Host "I got it."
            Break
        } else {
            $Search_Item=(Get-ChildItem -path "$Search_Location\*$chosen*")
            Write-Host "Redirect Keyword to $chosen"
            Write-Host "---------------------------"
            Continue
        }
    } until ((Test-path "$MyChoose") -eq $true)
}
Function Move-Excution ($Param) {
    Foreach($Line in $Param) {
        if (Test-Path $Line) {
            $Object_Path=Resolve-Path $Line
            $Toward_Object_Name=($Object_Path -split '\\')[-1]
            $File_Size = Format-FileSize((Get-Item $Object_Path).Length)
            Move-Item -LiteralPath $Object_Path -Destination $Toward_Path
            Add-Content -LiteralPath "$Push_Pull_Logging" -value "- $Nowtime := **$Toward_Object_Name `($File_Size`)** Move toward [$Toward_Path_Name]($Toward_Path)"
            Write-Host "$Toward_Object_Name ($File_Size) --> $Toward_Path_Name"
        }
    }
}
if (-not $Push_Pull_Logging) {Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression}
$Nowtime = get-date -format "yyyy-MM-dd dddd HH:mm:ss tt"
# Initialized
$Search_Location = $Project_Location
IF (Test-Path -path $args[-1] -ErrorAction SilentlyContinue) {
    $Search_Project=(Get-ChildItem -path "$Project_Location" -Directory)
    If ($purl) {
        $has_Set= Read-Host "Just Press the enter to Move toward $purl"
        If (!$has_Set) {
            $Push_Pull_Logging = $dafile
            $Toward_Path = $purl
            $purl_log = $true
            Write-Host "Move to $Toward_Path"
        } else {
            Select-Result($Search_Project)
            $Toward_Path = $MyChoose
        }
    }
} else {
    Set-Variable -Name Keyword -scope Script -Value $args[-1]
    # Write-Host "Okay, it is not a path. The keyword is $Keyword"
    IF ($args[-2] -eq "+") {
        $Search_Location = “$Achived_Repository”
        Write-Host "Search Location has Shifted."
    }
    $Search_Project=(Get-ChildItem -path "$Search_Location" -Directory | Select-String "$Keyword" -List)
    If ($null -eq $Search_Project) {
        $SearchFile=(Select-String -SimpleMatch -Path "$Projects_Link_File" -Pattern "$Keyword ").line
        $Search_Location = $Profile_Location
        Select-Result($SearchFile)
        $separator = " := "
        $Temp = $MyChoose -Split $separator
        $Local:Toward_Path=$Temp[1]
        $Keyword=$Temp[2]
        $global:dafile_Name = $Temp[2]
        $global:dafile = "$Profile_Location\$Keyword"
    } else {
        Select-Result($Search_Project)
        $Local:Toward_Path = $MyChoose
    }
    if (-Not $args[1]) {
        Invoke-Item $Toward_Path
        exit
    }
}
# Write-host "File will Send to toward $Toward_Path, Now Set up the logging file."
Clear-Variable MyChoose
Write-Host "---------------------------"
if (Test-Path "$Toward_Path\.Project_InFo.txt") {
    $Local:Push_Pull_Logging=Get-Content -Path "$Toward_Path\.Project_InFo.txt" -TotalCount 1
    Write-host "I Found .Project_Info.txt, record the event toward $Push_pull_Logging"
} elseif (!$purl_log) {
    $Search_Profile=(Get-ChildItem -path "$Profile_Location" -Name "*$keyword*" -File)
    if ($Search_Profile.Count -eq 1) {
        $Push_Pull_Logging="$Profile_Location\$Search_Profile"
    }
    if ($Search_Profile.Count -gt 1) {
        Write-Host $Search_Profile.Count "Profile(s) Related with the keyword: $keyword"
        $Search_Location = $Profile_Location
        Select-Result($Search_Profile)
        $Push_Pull_Logging="$MyChoose"
    }
    if ($args[-2] -eq ":") {
        $Search_Profile=(Get-ChildItem -path "$Profile_Location" -File)
        $Search_Location = $Profile_Location
        Select-Result($Search_Profile)
        $Push_Pull_Logging="$MyChoose"
    }
    Write-Host "This Event would Log to $Push_Pull_Logging,"
}
$Toward_Path_Name=($Toward_Path -split '\\')[-1]
    # Write-Host "This\Those file(s) will sent to $Toward_Path and would be log to $Push_Pull_Logging"
Move-Excution($args)