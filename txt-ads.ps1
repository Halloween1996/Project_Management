param (
    [string]$filePath,
    [switch]$paperfill
)

if (!filePath) {
	$Filepath = Read-Host "file to load"
}
# 读取文件内容
$content = Get-Content -Path $filePath -Raw

# 提取所有以 $ 开头的变量
$variables = [regex]::Matches($content, "\$\w+").Value | Sort-Object -Unique

# 创建一个哈希表来存储变量和值
$replacements = @{}

foreach ($variable in $variables) {
    $variableName = $variable.TrimStart('$')
    
    # 根据变量名进行自动计算或让用户输入
    switch ($variableName) {
        "Month" {
            $lastMonth = (Get-Date).AddMonths(-1).ToString("MMMM")
            $replacements[$variable] = $lastMonth
        }
        "Due_Date" {
            $dueDateInput = Read-Host "Enter the due date in MM-dd-yyyy format"
            $dueDate = [datetime]::ParseExact($dueDateInput, "MM-dd-yyyy", $null)
            $formattedDueDate = $dueDate.ToString("MM-dd-yyyy (dddd)")
            $replacements[$variable] = $formattedDueDate
        }
        default {
            $replacements[$variable] = Read-Host "replace the value for $variableName"
        }
    }
}

# 替换内容中的变量
foreach ($variable in $replacements.Keys) {
    $content = $content -replace [regex]::Escape($variable), $replacements[$variable]
}

# 输出替换后的内容并保持原格式
Write-host "---------------------------------------------------------"
$content | Out-String | Write-Host
