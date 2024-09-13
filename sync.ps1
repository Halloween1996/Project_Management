param (
    [string]$Source = "C:\q",
    [string]$Mirror = "C:\q\Dev"
)

# 定义默认值
$NotInclude_Keywords = @("Copy", "Bill", "Fantuan", "Gurnhub", "Template")
$Push_Pull_Logging = "C:\My\Project_Notes\Moving_History.md"
$Copy_Counting = 0  

# 检查是否存在配置文件
$configFile = ".\Copy_Config.ini"
if (Test-Path $configFile) {
    Write-Host "读取配置文件: $configFile"
    $config = Get-Content $configFile | ForEach-Object {
        $key, $value = $_ -split '='
        $key = $key.Trim()
        $value = $value.Trim().Trim('"')
        [PSCustomObject]@{ Key = $key; Value = $value }
    }

    # 赋值配置文件中的变量
    $Source = $config | Where-Object { $_.Key -eq 'source' } | Select-Object -ExpandProperty Value
    $Mirror = $config | Where-Object { $_.Key -eq 'mirror' } | Select-Object -ExpandProperty Value
    $NotInclude_Keywords = ($config | Where-Object { $_.Key -eq 'Exclude_Keywords' } | Select-Object -ExpandProperty Value).Split(',').Trim()
    $Push_Pull_Logging = $config | Where-Object { $_.Key -eq 'Push_Pull_Logging' } | Select-Object -ExpandProperty Value
}

Write-Host "I don't Copy File which File Name contains any of the following keywords: $($NotInclude_Keywords -join ', ')"
# 计算文件的哈希值
function Get-FileHashValue($filePath) {
    return Get-FileHash -Path $filePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
}

# 遍历源文件夹中的所有文件
Get-ChildItem -Path $Source -Recurse -File | ForEach-Object {
    # 构建目标文件路径
    $destinationPath = $_.FullName.Replace($Source, $Mirror)
    $destinationDir = Split-Path $destinationPath
    # 检查文件名是否包含任何不包含的关键词
    $excludeFile = $false
    foreach ($keyword in $NotInclude_Keywords) {
        if ($_.Name -match $keyword) {
            $excludeFile = $true
            break
        }
    }
    if (-not $excludeFile) {
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
                Copy-Item -Path $_.FullName -Destination $destinationPath -Confirm
                if ($?) {
                    $Copy_Counting += 1
                    Add-Content -path $Push_Pull_Logging -Value "File modify: $destinationPath"
                }
                Write-Host "$_.Name exists, but the Hash Value is different."
            }
        } else {
            # 目标文件不存在，直接复制
            Copy-Item -Path $_.FullName -Destination $destinationPath
            if ($?) {
                $Copy_Counting += 1
                Add-Content -path $Push_Pull_Logging -Value "File create: $destinationPath"
            }
            Write-Host "$destinationPath"
        }
    }
}

# 添加当前日期、时间和总复制数到日志文件
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -path $Push_Pull_Logging -Value "Date: $currentDateTime, Total Copy: $Copy_Counting"
Write-Host "Total Copy: $Copy_Counting"
