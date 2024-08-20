Function Format-FileSize() {
Param ([int]$size)
    If ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0) {[string]::Format("{0:0.00} B", $size)}
    Else {""}
}
Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression
$Nowtime = get-date -format "dddd yyyy-MM-dd HH:mm:ss tt"
$Sort_Folder=$pwd
$Just_Extension=$False
if ($Args) {
    if ($Args -eq "type") {
        Write-Host "Sort all file By their Extension Only?"
        Pause
        $Just_Extension=$true
    }
    if (Test-Path $Args) {
        $Sort_Folder=(Resolve-Path $Args)
    }
}
Write-Host "Loading $Sort_Folder"
if (Test-Path "$Sort_Folder\Sort.txt") {
    $Sort_Bank=Get-Content -Path "$Sort_Folder\Sort.txt"
    $Exclude_List=(Get-Content -LiteralPath "$Sort_Folder\Sort.txt" -head 1)
} else {
    $Sort_Bank=Get-Content -Path "$Profile_Location\Sort_Rules_Bank.md"
    $Exclude_List=(Get-Content -LiteralPath "$Profile_Location\Sort_Rules_Bank.md" -head 1)
}
# Excluding_Item
$Excuse_Item="Sort.txt Sort_Rules_Bank.md"
Foreach ($Search_Keyword in $Exclude_List.split(' ')) {
    $Search_Item=Get-ChildItem -path "$Sort_Folder" -file -Name| Select-String "$Search_Keyword"
    $Excuse_Item="$Search_Item $Excuse_Item"
}
Write-Host "Exclude file:$Excuse_Item"
# Write-Host "Initialize Finish. Configuation: $Sort_Bank"
if ($Just_Extension -eq $False) {
    Write-Host "---------> Arrangement by Keyword..."
    Foreach ($Line in $Sort_Bank) {
        $Keywords,$Path = $Line.split('|')
        if ($null -eq $path) {
            Continue
        }
        Foreach ($Search_Keyword in $Keywords.split(' ')) {
            $TheResults=Get-ChildItem -path "$Sort_Folder" -file| Where-Object{$_.Name -match $Search_Keyword}
            if ($TheResults) {
                if ($False -eq (Test-path $Path)) {mkdir $path}
                $path = (Resolve-path $path)
                ForEach ($Result in $TheResults) {
                    $File_Name = Split-Path $Result -leaf
                    Write-Host "File name is : $File_Name"
                    if ($null -eq ($Excuse_Item|Select-String "$File_Name")) {
                        $Arrange_Number++
                        $File_Size = Format-FileSize((Get-Item $Result).Length)
                        $File_Name_Link = $File_Name -replace ' ','%20'
                        Move-Item -LiteralPath "$Result" -Destination "$path"
                        Write-Host "[$Arrange_Number]  $File_Name --> $path"
                        Add-Content -LiteralPath "$Push_Pull_Logging" -value "**$Nowtime** : -$Arrange_Number- [$File_Name ($File_Size)]($path\$File_Name_Link)  just Moved."
                    }
                }
            }
        }
    }
}
Write-Host "---------> Arrange by FIle Extension..."
[int]$Arrange_Number=0
Get-ChildItem -path "$pwd" -file| ForEach-Object {
    $Get_Remain_File_Name=$_.Name
    $Get_Remain_File_Extension=$_.Extension
    Write-Host "Name is $Get_Remain_File_Name , and the ext is $Get_Remain_File_Extension"
    if ($null -eq ($Excuse_Item|Select-String "$Get_Remain_File_Name")) {
        $Arrange_Number++
        $Arrangement_Folder_Name = ($Get_Remain_File_Extension.split('.'))[-1]
        if ($False -eq (Test-Path "$pwd\$Arrangement_Folder_Name")) {mkdir "$pwd\$Arrangement_Folder_Name"}
        move-Item -LiteralPath $_ -Destination "$pwd\$Arrangement_Folder_Name"
        $File_Size = Format-FileSize(($_.Length))
        Write-Host "[$Arrange_Number]  $_.Name move to $Arrangement_Folder_Name"
        Add-Content -LiteralPath "$Push_Pull_Logging" -value "**$Nowtime** : -$Arrange_Number- $Get_Remain_File_Name($File_Size) has move toward Arrangement Folder: $Arrangement_Folder_Name"
    }
}
Write-Host "                      ---> Arrangement, Done. <---"~