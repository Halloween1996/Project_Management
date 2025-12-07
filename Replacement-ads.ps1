param (
    [string]$filePath,
    [switch]$paperfill
)

# 读取文件内容
$content = Get-Content -Path $filePath -Raw
if ($paperfill) {
    Write-Host "got it, taxpayer has something must be file by paper."
}
# 提取所有以 $ 开头的变量
$variables = [regex]::Matches($content, "\$\w+").Value | Sort-Object -Unique

# 创建一个哈希表来存储变量和值
$replacements = @{}

foreach ($variable in $variables) {
    $variableName = $variable.TrimStart('$')
    
    # 根据变量名进行自动计算或让用户输入
    switch ($variableName) {
        "Last_Month" {
            $Last_Month = (Get-Date).AddMonths(-1).ToString("MMMM")
            $replacements[$variable] = $Last_Month
        }
        "Month_In_Number" {
            $replacements[$variable] = (Get-Date).AddMonths(-1).ToString("%M")
        }
        "Today" {
            $replacements[$variable] = Get-Date -Format "MM-dd-yyyy (dddd)"
        }
        "Due_Date" {
            If ($null -eq $dueDateInput) {
                $dueDateInput = Read-Host "Enter the due date in MM-dd-yyyy format"
                $dueDate = [datetime]::ParseExact($dueDateInput, "MM-dd-yyyy", $null)
            }
            $formattedDueDate = $dueDate.ToString("MM-dd-yyyy (dddd)")
            $replacements[$variable] = $formattedDueDate
        }
        "Due_Days_Left" {
            If ($null -eq $dueDateInput) {
                $dueDateInput = Read-Host "Enter the due date in MM-d-yyyy format"
                $dueDate = [datetime]::ParseExact($dueDateInput, "MM-d-yyyy", $null)
            }
            $today = Get-Date
            $replacements[$variable] = ($dueDate - $today).Days+1
        }
        "Wanted_Date" {
            If ($null -eq $dueDateInput) {
                $dueDateInput = Read-Host "Enter the due date in MM-dd-yyyy format"
            }
            $Wanted_Date_Input = Read-Host "How many days before the due day"
            $Wanted_Date = ($dueDate).AddDays(-$Wanted_Date_Input).ToString("MM-dd-yyyy (dddd)")
            $replacements[$variable] = $Wanted_Date
        }
        default { 
            $replacements[$variable] = Read-Host "Enter the value for $variableName"
        }
    }
}

# 替换内容中的变量
foreach ($variable in $replacements.Keys) {
    $content = $content -replace [regex]::Escape($variable), $replacements[$variable]
}

# 输出替换后的内容并保持原格式
Write-host "---------------------------------------------------------"
if ($paperfill) { 
    $content | Out-String | Write-Host
} else {
    $lines = $content -split "`n" 
    $content = $lines | Where-Object { $_ -notmatch "^\*" } | Write-Host 
}