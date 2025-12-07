# 读取配置文件内容
Get-Content $PSScriptRoot\Unified_project_variable.ini|Invoke-Expression
# 读取WebSites.md文件内容
$WebSites_Content = Get-Content $Websites_List
$Folder_Locations = Get-Content $Searching_Folder_List
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
        $ddc = Get-ChildItem "$Folder_Location\*$param*"
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
    Write-Host "Following Folder(s) are in the searching list:"
    $Folder_Locations
    Write-Host "You may type Edit for Editing, Open for open Project Location, or just type s + keyword for search and open."
	$User_input = Read-Host "Command"
    if ($User_input -ieq "Edit") {
        Invoke-Item $Searching_Folder_List
        Invoke-Item $Websites_List
        Exit
    }
    if ($User_input -ieq "Open") {
        Invoke-Item $Project_Location
        Exit
    }
    if ($User_input.StartsWith('s ')) {
        $ToSearch = $User_input.substring(2)
        Write-Host "Searching $ToSearch by File..."
        Search-File $ToSearch
    }
}