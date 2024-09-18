param (
    [string]$Source = "C:\My\Business",
    [string]$Mirror = "C:\testing",
	[string]$Push_Pull_Logs = "C:\testing\Moving_History.md",
    [int]$days_away=30
)
# 请确保变量$Mirror的路径与实际的文件路径每个字符都是一致的. 不要实际的文件大写路径是大写, 而这里写的路径是小写. 会导致脚本无法复制.

if (-Not $Profile_Location) {
	Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
}

# 定义默认值
$Include_Keywords = @("ST-1", "ST-4", "ST-14", "HR Tax", "Sale")
$Exclude_Keywords = @("Copy", "\Achieved", "Config")
$Copy_Counting = 0

# 检查是否存在配置文件
$configFile = ".\Copy_Config.txt"
if (Test-Path $configFile) {
    Write-Host "读取配置文件: $configFile"
    Get-Content $configFile | ForEach-Object {
        $line = $_.Trim()
        if ($line.StartsWith(";")) {
            $Exclude_Keywords += $line.Substring(1).Trim()
        } elseif ($line.StartsWith("$")) {
            Invoke-Expression $line
        } else {
            $Include_Keywords += $line
        }
    }
}

# 待调用函数 - 计算文件的哈希值
function Get-FileHashValue($filePath) {
    return Get-FileHash -Path $filePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
}

$Process = $mirror
Get-ChildItem "$mirror"
Write-Host "This script don't copy files modified which $days_away days away."
Do {
    $keywords = Read-Host "Please Enter the keywords"
    if ($keywords -eq ";;") {
        Set-Variable -Name "Target_Folder" -Value "$Process"
		break
    } elseif ($keywords -eq "..") {
        $Process = Split-Path -Path $Process -Parent
    } elseif ($keywords -eq "''") {
        $dateInput = Read-Host "giv me the date you would like to copy files (format: MMddyyyy)"
        $date = [datetime]::ParseExact($dateInput, "MMddyyyy", $null)
        $today = Get-Date
        $days_away = ($today - $date).Days
        Write-Host "Okay, this script will copy those files which modified with in $days_away days away."
    } else {
        $matchingFolders = Get-ChildItem -Path "$Process" | Where-Object { $_.Name -like "*$keywords*" -and $_.PSIsContainer }
        if ($matchingFolders.Count -eq 1) {
            $Process = $matchingFolders[0].FullName
        } elseif ($matchingFolders.Count -gt 1) {
            Write-Host "Multiple matching folders found:"
            for ($i = 0; $i -lt $matchingFolders.Count; $i++) {
                Write-Host "[$($i + 1)] $($matchingFolders[$i].FullName)"
            }
            $choice = Read-Host "Please enter the number of the folder you want to select"
            if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $matchingFolders.Count) {
                $Process = $matchingFolders[$choice - 1].FullName
            } else {
                Write-Host "Invalid choice. Please try again."
            }
        } else {
            Write-Host "No matching folder found."
        }
    }
    Get-ChildItem "$Process"
} until ($Target_Folder)

# 遍历源文件夹中的所有文件
$filesToProcess = Get-ChildItem -Path $Target_Folder -Recurse -File | Where-Object {
    $includeFile = $false
    foreach ($keyword in $Include_Keywords) {
        if ($_.Name -match [regex]::Escape($keyword)) {
            $includeFile = $true
            break
        }
    }
    $includeFile
}

# 从待处理列表中剔除包含Exclude关键词的文件
$filesToProcess = $filesToProcess | Where-Object {
    $excludeFile = $false
    foreach ($keyword in $Exclude_Keywords) {
        if ($_.FullName -match [regex]::Escape($keyword)) {
            $excludeFile = $true
            break
        }
    }
    -not $excludeFile
}
# 处理待处理列表中的文件
$filesToProcess | ForEach-Object {
    # 构建目标文件路径
    $destinationPath = $_.FullName.Replace($Mirror, $Source)
    $destinationDir = Split-Path $destinationPath
    # 如果文件最后修改时间是在xx天以内
    if ($_.LastWriteTime -gt (Get-Date).AddDays(-$days_away)) {
        # 创建目标文件夹（如果不存在）
        if (-not (Test-Path $destinationDir -PathType Container)) {
            New-Item -ItemType Directory -Path "$destinationDir"
        }
        # 检查目标文件是否存在
        if (Test-Path $destinationPath -PathType Leaf) {
            # 比较源文件和目标文件的哈希值
            $sourceHash = Get-FileHashValue $_.FullName
            $destinationHash = Get-FileHashValue $destinationPath
            if ($sourceHash -ne $destinationHash) {
                Write-Host "-----------------------------------------------------"
                Write-Host "The one in" $Source ", its last modified:" $($_.LastWriteTime)
                Write-Host "The one in" $Mirror ", its last modified:" $(Get-Item $destinationPath).LastWriteTime
                Write-Host $_.FullName
                Write-Host "This File exists in both folder, But the content may be vary. Copy to" $Source "or not?"
                Copy-Item -Path $_.FullName -Destination $destinationPath -Confirm
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $destinationPath
            if ($?) {
            $Copy_Counting += 1
            Add-Content -path $Push_Pull_Logs -Value "$Copy_Counting - File create: $destinationPath"
            }
            Write-Host "File create:" $destinationPath
        }
    }
}
# 添加当前日期、时间和总复制数到日志文件
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -path $Push_Pull_Logs -Value "Date: $currentDateTime, Total Copy: $Copy_Counting"
Write-Host "Total Copy: $Copy_Counting"