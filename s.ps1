# 读取配置文件内容
Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
$WebSites_File = "$Quick_Luanching_Dictionary"
$Searching_Variable_List_File = "$Profile_Location\Searching_Variable_List.md"

# 读取WebSites.md文件内容
$WebSites_Content = Get-Content $WebSites_File

# 读取Searching_Variable_List.md文件内容
$Folder_Locations = Get-Content $Searching_Variable_List_File

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
            $shortPath = $file.FullName.Replace($Folder_Location, '').TrimStart('\')
            $Candidates += [PSCustomObject]@{ Index = ++$n; Path = $file.FullName; Display = "$shortPath - $($file.Name)" }
            Write-Host "[$n] $shortPath - $($file.Name)"
        }
    }

    # 确定结果
    if ($n -eq 0) {
        Write-Host "No Result Found"
        Exit
    }
    if ($n -eq 1) {
        Start-Process $Candidates[0].Path
    } else {
        $chose = Read-Host "What is your choice? (Enter 0 to cancel)"
        if ($chose -eq 0) {
            Write-Host "Operation cancelled."
            Exit
        }
        Start-Process $Candidates[$chose - 1].Path
    }
}

If ($args) {
	Search-File $args
} else {
	$User_input = Read-Host
    if ($User_input.StartsWith('s ')) {
        $ToSearch = $User_input.substring(2)
        Write-Host "Searching $ToSearch by File..."
        Search-File $ToSearch
    }
}