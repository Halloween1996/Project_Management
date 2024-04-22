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
$Exclude_List="ini"
$Nowtime = get-date -format "dddd yyyy-MM-dd HH:mm:ss tt"
$Sort_Folder=$pwd
$Just_Extension=$False
[int]$Arrange_Number=0
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
# Write-Host "$Sort_Folder"
if (Test-Path "$Sort_Folder\Sort_bank.ini") {
    $Sort_Bank=Get-Content -Path "$pwd\Sort_bank.ini"
} else {
    $Sort_Bank=Get-Content -Path "$PSScriptRoot\Sort_bank.ini"
}
Foreach ($Search_Keyword in $Exclude_List.split(' ')) {
    $Search_Item=Get-ChildItem -path "$Sort_Folder" -file -Name| Select-String "$Search_Keyword"
    $Excuse_Item="$Search_Item $Excuse_Item"
}
# Write-Host "Initialize Finish. Configuation: $Sort_Bank"
if ($Just_Extension -eq $False) {
    Write-Host "---------> Arrangement by Keyword..."
    Foreach ($Line in $Sort_Bank) {
        $path,$Keywords = $Line.split('|')
        Foreach ($Search_Keyword in $Keywords.split(' ')) {
            $TheResults=Get-ChildItem -path "$Sort_Folder" -file| Where{$_.Name -match $Search_Keyword}
            if ($TheResults) {
                $path = (Resolve-path $path)
                ForEach ($Result in $TheResults) {
                    $File_Name = (Get-Item $Result).Name
                    if (($Excuse_Item|Select-String "$File_Name") -eq $null) {
                        $Arrange_Number++
                        $File_Size = Format-FileSize((Get-Item $Result).Length)
                        $File_Name_Link = $File_Name -replace ' ','%20'
                        Move -Path "$Result" -Destination "$path"
                        Write-Host "[$Arrange_Number]  $File_Name --> $path"
                        Add-Content -LiteralPath "$Push_Pull_Logging" -value "**$Nowtime** : -$Arrange_Number- [$File_Name ($File_Size)]($path\$File_Name_Link)  just Moved."
                    }
                }
            }
        }
    }
}
# Write-Host "Done with Configuation File: $Sort_Bank, Sort by File Extension."
$Get_All_Extension=(Get-ChildItem -path "$pwd" -file).Extension
if ($Get_All_Extension -ne $null) {
    Write-Host "---------> Arrange by FIle Extension..."
    Foreach($Ext_File_Name in $Get_All_Extension) {
        $Folder_Name = ($Ext_File_Name.split('.'))[-1]
        if ((Test-Path "$pwd\Arrangement\$Folder_Name") -eq $False) {
            mkdir "$pwd\Arrangement\$Folder_Name"
        }
        Get-ChildItem -path "$pwd" -file| Where{$_.Extension -match $Ext_File_Name}|foreach {
            $File_Name=$_.Name
            if (($Excuse_Item|Select-String "$File_Name") -eq $null) {
                $Arrange_Number++
                move-Item -path $_ -Destination "$pwd\Arrangement\$Folder_Name"
                $File_Size = Format-FileSize(($_.Length))
                Write-Host "[$Arrange_Number]  $_.Name move to $Folder_Name"
                Add-Content -LiteralPath "$Push_Pull_Logging" -value "**$Nowtime** : -$Arrange_Number- $_.Name($File_Size) move toward $Folder_Name"
            }
        }
    }
}
Write-Host "                      ---> Arrangement, Done. <---"