param (
    [string]$Source = "C:\My\Business",
    [string]$Mirror = "C:\testing",
	[string]$Push_Pull_Logs = "C:\testing\Moving_History.md",
    [int]$days_away=30
)

# "区域计划" 联动变量
if (-Not $Profile_Location) {
	Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
}

# 定义默认值
$Include_Keywords = @("ST-1", "ST-4", "ST-14", "HR Tax", "Sale")
$Exclude_Keywords = @("Copy", "\Achieved", "Config")
$Copy_Counting = 0
[int]$n = 0
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

Write-Host $Source "-- Copy File to -->" $mirror
Write-Host "Only Copy File which File Name contains any of the following include keywords: $($Include_Keywords -join ', ')"
Write-Host "Exclude File which File Name contains any of the following exclude keywords: $($Exclude_Keywords -join ', ')"
Pause

# 遍历源文件夹中的所有文件
$filesToProcess = Get-ChildItem -Path $Source -Recurse -File | Where-Object {
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
    $destinationPath = $_.FullName.Replace($Source, $Mirror)
    $destinationDir = Split-Path $destinationPath
    # 如果文件的修改时间在xx天以内
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
                # 复制文件到目标文件夹
                # 输出两个文件的最后修改时间
                Write-Host "-----------------------------------------------------"
                Write-Host "The one in" $Source ", its last modified:" $($_.LastWriteTime)
                Write-Host "The one in" $Mirror ", its last modified:" $(Get-Item $destinationPath).LastWriteTime
                Write-Host $_.FullName
                Write-Host "This File exists in both folder, But the content may be vary. Copy to" $Mirror "or not?"
                Copy-Item -Path $_.FullName -Destination $destinationPath -Confirm
                if ($?) {
                    $Copy_Counting += 1
                    Add-Content -path $Push_Pull_Logs -Value "$Copy_Counting - File modify: $destinationPath"
                }
            }
        } else {
            # 目标文件不存在，直接复制
            Copy-Item -Path $_.FullName -Destination $destinationPath
            if ($?) {
                $Copy_Counting += 1
                Add-Content -path $Push_Pull_Logs -Value "$Copy_Counting - File create: $destinationPath"
            }
            Write-Host "$destinationPath"
        }
    }
}

# 添加当前日期、时间和总复制数到日志文件
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -path $Push_Pull_Logs -Value "Date: $currentDateTime, Total Copy: $Copy_Counting"
Write-Host "Total Copy: $Copy_Counting"