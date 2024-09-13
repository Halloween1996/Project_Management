$Source = "C:\Testing"
$mirror = "C:\Special's Test"
$Process = $mirror
Get-ChildItem "$mirror"

Do {
    $keywords = Read-Host "Please Enter the keywords"
    if ($keywords -eq "jkl;'") {
        Set-Variable -Name "Target_Folder" -Value "$mirror"
		break
    } elseif ($keywords -eq "..") {
        $Process = Split-Path -Path $Process -Parent
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
Get-ChildItem -Path $Target_Folder -Recurse -File | ForEach-Object {
    # 构建目标文件路径
    $destinationPath = $_.FullName.Replace($Target_Folder, $Source)
    $destinationDir = Split-Path $destinationPath
    # 如果文件创建时间在32天以内
    if ($_.CreationTime -gt (Get-Date).AddDays(-32)) {
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
                $Copy_Counting += 1
                Write-Host "$_.Name exist, but the Hash Value is different."
                Copy-Item -Path $_.FullName -Destination $destinationPath -Confirm
            }
        } else {
            # 目标文件不存在，直接复制
            $Copy_Counting += 1
            Copy-Item -Path $_.FullName -Destination $destinationPath
            Write-Host "$destinationPath"
        }
    }
}
Write-Host "Total Copy: $Copy_Counting"