param(
    [String]$textfile,
    [switch]$Debug
)

if ($Debug) {
    Write-Host "运行调试模式 (--debug)"
    
    # 加载配置文件
    if (-Not $Profile_Location) {
        Get-Content "$PSScriptRoot\project_variable.ini" | Invoke-Expression
    }

    # 提取当前会话中定义的所有变量
    $variables = Get-Variable | Select-Object Name, Value

    # 输出变量
    Write-Host "以下是脚本中使用到的变量及其值："
    foreach ($var in $variables) {
        Write-Host "Variable: $($var.Name) = $($var.Value)"
    }

    # 停止执行后续内容，或者根据需求继续执行
    return
}

# Initialization Variable.
if (-Not $Profile_Location) {
	Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
}

# 初始化变量
$Today_Month = (Get-Date -Format "yyyy")
$Today_Note = "$Diary_Location\$Today_Month.md"
$daProfile = $Today_Note
$Dir_Profile = $Today_Note
$pj = $Project_Location
$Global:daProfile = $null

if (Test-Path -Path .\.Folder_Profile.md -PathType Leaf) {
	$daProfile = ".\.Folder_Profile.md"
	Write-host "It is under the Project folder, so loading those notes from this folder."
}
if ($textfile) {
    if (Test-Path -Path $textfile -PathType Leaf) {
        $daProfile = "$textfile"
        Write-host "Loading $textfile"
    }
}

# 待调用函数
Function Read-LastLines {
    Param ($filePath, $lines = 20)
    [int]$n = 0
    foreach ($line in Get-Content -Path $filePath -Tail $lines) {
        $n++
        Write-Host ""
        Write-Host "$n : $line"
    }
    Write-Host "--------------------------------------------------------------------------------"
}
Function Search-Content {
    Param ($filePath, $pattern)
    Select-String -Path $filePath -Pattern $pattern
}
Function Search-Result {
    Param ($searchPath, $pattern = $null)
    if ($pattern) {
        $results = Get-ChildItem -Path $searchPath -Filter "*$pattern*"
    } else {
        $results = $searchPath
    }
    if ($results.Count -gt 1) {
        for ($i = 0; $i -lt $results.Count; $i++) {
            Write-Host "$($i + 1): $($results[$i].FullName)"
        }
        $chosen = Read-Host "You chose No. or enter keyword"
        if ($chosen -match "^\d+$") {
            if ($chosen -eq 0) {
                Write-Host "Operation cancelled."
                return $null
            }
            return $results[$chosen - 1].FullName
        } else {
            $filteredResults = $results | Where-Object { $_.FullName -like "*$chosen*" }
            if ($filteredResults.Count -eq 1) {
                return $filteredResults[0].FullName
            } elseif ($filteredResults.Count -gt 1) {
                for ($i = 0; $i -lt $filteredResults.Count; $i++) {
                    Write-Host "$($i + 1): $($filteredResults[$i].FullName)"
                }
                $chosen = Read-Host "You chose No."
                if ($chosen -eq 0) {
                    Write-Host "Operation cancelled."
                    return $null
                }
                return $filteredResults[$chosen - 1].FullName
            } else {
                Write-Host "No Matching File`(s`) or Folder`(s`) Found."
                return $null
            }
        }
    } elseif ($results.Count -eq 1) {
        return $results[0].FullName
    } else {
        Write-Host "No Matching File`(s`) or Folder`(s`) Found."
        return $null
    }
}
Function Format-FileSize() {
	Param ([int]$size)
		If ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
		ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
		ElseIf ($size -gt 0) {[string]::Format("{0:0.00} B", $size)}
		Else {""}
}
Function Switch-Keywords {
    Param ($Explain)
    $replacements = @{
        "ls" = "Get-ChildItem"
        "ii" = "start-Process"
        "cd" = "Set-Location"
        "cat" = "Get-Content"
        "cls" = "Clear-Host ; Set-variable -name pj -value $Project_Location"
    }

    foreach ($keyword in $replacements.Keys) {
        if ($Explain -match "^$keyword\b") {
            $Explain = $Explain -replace "^$keyword\b", $replacements[$keyword]
            $Has_Explain = $true
        }
    }
    Return @($Explain, $Has_Explain)
}

# Main Body Code
$today = Get-Date
$dayOfYear = $today.DayOfYear
$isLeapYear = [DateTime]::IsLeapYear($today.Year)
$totalDaysInYear = if ($isLeapYear) { 366 } else { 365 }
$remainingDays = $totalDaysInYear - $dayOfYear
$weekOfYear = [System.Globalization.CultureInfo]::CurrentCulture.Calendar.GetWeekOfYear($today, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Sunday)
$lastDayOfYear = Get-Date -Year $today.Year -Month 12 -Day 31
$totalWeeksInYear = [System.Globalization.CultureInfo]::CurrentCulture.Calendar.GetWeekOfYear($lastDayOfYear, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Sunday)
$Yearprogress = [math]::Round(($dayOfYear / $totalDaysInYear) * 100, 2)
$progressBarLength = 50
$YearprogressBar = "=" * [math]::Round(($dayOfYear / $totalDaysInYear) * $progressBarLength)
Read-LastLines -filePath $daProfile -lines 5
Write-Host "Hi, Today is" ($today.ToString("yyyy-MM-dd dddd")) ", the" $weekOfYear "th week out of" ($totalWeeksInYear) "weeks"
Write-Host "Today is the $dayOfYear th day(s) of the year; there are $remainingDays days left."
Write-Host "Year Progress: [$YearprogressBar$([string]::new(" ", $progressBarLength - $progressBar.Length))] $Yearprogress% complete"

Do {
    Write-Host ""
    $User_input = Read-Host "$(get-date -format "ddd h:mm tt")"
    $User_Submitted_Time = get-date -format "yyyy-MM-dd dddd HH:mm:ss"

    # 替换关键词
    $result = Switch-Keywords -Explain $User_input
    $expandedInput = $result[0]
    $Has_Explain = $result[1]

    # 如果进行了字符替换，调用Invoke-Expression并跳过剩余部分
    if ($Has_Explain) {
        Invoke-Expression $expandedInput
        $Has_Explain = $false
        Continue
    }

    # 特定动作
    if ($User_input -eq "") {
		Clear-Host
        $fileToRead = if ($daProfile) { $daProfile } else { $Today_Note }
        Write-host " $fileToRead has written:"
		Read-LastLines -filePath $fileToRead -lines 10
        $pj
        $daProfile
		Continue
	} elseif ($User_input -match "^\d+$") {
        $linesToRead = [int]$User_input
        $fileToRead = if ($daProfile) { $daProfile } else { $Today_Note }
        $fileToRead
        Read-LastLines -filePath $fileToRead -lines $linesToRead
        Continue
    } elseif ($User_input.StartsWith('?')) {
        $pattern = $User_input.Substring(1)
        $fileToSearch = if ($daProfile) { $daProfile } else { $Today_Note }
        Search-Content -filePath $fileToSearch -pattern $pattern
        Continue
    } elseif ($User_input.StartsWith('#')) {
        Add-Content -Path $Today_Note -Value $User_input
        if ($daProfile) {
            Add-Content -Path $daProfile -Value $User_input
        }
        Continue
    } elseif ($User_input.StartsWith(':')) {
        $command = $User_input.Substring(1)
        Invoke-Expression $command
        Continue
    } elseif ($User_input.StartsWith('\\')) {
        $Profile_pattern = $User_input.Substring(2)
        $newProfile = Search-Result -searchPath $Profile_Location -pattern $Profile_pattern
        if ($newProfile) {
            $Dir_Profile = $daProfile
            $daProfile = $newProfile
            Write-Host "Profile set as $daProfile"
            Read-LastLines -filePath $daProfile -lines 10
        }
        Continue
    } elseif ($User_input.StartsWith('\')) {
        $pattern = $User_input.Substring(1)
        $newPath = Search-Result -searchPath $pj -pattern $pattern
        if ($newPath) {
            $Global:pj = $newPath
            $pj = $newPath
            Set-Location -Path $newPath
            if ($newPath.StartsWith($Project_Location)) {
                $daProfile = "$Global:pj\.Folder_Profile.md"
                if (-not (Test-Path $daProfile)) {
                    New-Item -Path $daProfile -ItemType File
                    (Get-Item $daProfile).Attributes = "Hidden"
                }
            }
            Write-Host "Project set as $Global:pj"
            Write-Host "Profile set as $daProfile"
            Read-LastLines -filePath $daProfile -lines 10
        } else {
            Write-Host "----------------------------------------------"
            Write-Host "under $pj :"
            Write-Host "------------------------"
            Get-ChildItem $pj
        }
        Continue
    } elseif ($User_input.StartsWith('s ')) {
        $pattern = $User_input.Substring(2)
        $folders = Get-Content -Path $searching_Folder_List
        $matchingFiles = @()
        foreach ($folder in $folders) {
            $matchingFiles += Get-ChildItem -Path $folder -Filter "*$pattern*"
        }
        # Searching Website
        Get-Content $websites_List | ForEach-Object {
            if ($_ -match $pattern) {
                $n++
                Write-Host "$n $_"
            }
        }
        $newPath = Search-Result -searchPath $matchingFiles
        if ($newPath) {
            Start-Process $newPath
        }
        Continue
    } elseif ($User_input -eq ";;;") {
        if ("$daProfile" -ne "$Today_Note") {
            $holding_Profile=$daProfile
            $daProfile = $Today_Note
            Write-Host "Profile has to be Withdrawed."
        }
        Continue
    } elseif ($User_input -eq ";;") {
        if ($holding_Profile) {
            $daProfile = $holding_Profile
            Clear-Variable -Name holding_Profile
            Write-Host "Swap back to" $daProfile
            Continue
        }elseif ($daProfile -like "*\.Folder_Profile.md") {
            $daProfile = $Dir_Profile
        } else {
            $Dir_Profile = $daProfile
            $daProfile = "$pj\.Folder_Profile.md"
        }
        Write-Host "Now the Profile is $daProfile"
        Continue
    }

    # ----------------以下代码涉及文件移动的核心逻辑-----------------
    if ($User_input.StartsWith("@")) {
        $User_input = $User_input.Substring(1)
        $User_Input = $User_input.Trim('"')
        # 判断是否为文件路径
        if (Test-Path -LiteralPath $User_input -PathType Leaf) {
            $fileExtension = [System.IO.Path]::GetExtension($User_input)
            if ($fileExtension -eq ".txt" -or $fileExtension -eq ".md") {
                $daProfile = $User_Input
                Write-Host "Now the Profile is $daProfile"
                Continue
            }
        }
        # 判断是否为文件夹路径
        if (Test-Path -LiteralPath $User_input -PathType Container) {
            $Global:pj = Resolve-Path -Path $User_input
            $pj = Resolve-Path -Path $User_Input
            Write-Host "Now, The Project is $Global:pj"
            Set-Location -Path $Global:pj
            Get-ChildItem $pj
            Continue
        }
    }

    # 如果只输入路径, 那么首先处理双引号开头的输入, 再移动处理后的结果到Project之中.
    if ($User_input.StartsWith('"')) {
        $User_input = $User_input.Trim('"')
    }
    if (Test-Path -LiteralPath $User_input) {
        if ($Global:pj) {
            $fileName = [System.IO.Path]::GetFileName($User_input)
            $File_Size = Format-FileSize((Get-Item $User_Input).Length)
            Move-Item -LiteralPath $User_input -Destination $Global:pj
            Add-Content -Path $Today_Note -Value "$User_Submitted_Time : Moved file **$fileName `($File_Size`)** to $Global:pj"
            if ($daProfile) {
                Add-Content -Path $daProfile -Value "$User_Submitted_Time : Moved file **$fileName `($File_Size`)** to $Global:pj"
            }
        }
        Continue
    }

    # 记录用户输入
    Add-Content -Path $Today_Note -Value "$User_Submitted_Time : $User_input"
    if ($daProfile -ne $Today_Note) {
        Add-Content -Path $daProfile -Value "$User_Submitted_Time : $User_input"
    }
} Until ($User_input -eq "wq")