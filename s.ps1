Get-Content $PSScriptRoot\Search_Dir.ini|Invoke-Expression
If (!$args) {
	Write-Host "Links:"
	type "$Quick_Luanching_Dictionary"
    Get-ChildItem "$Folder_Location_1"|Format-wide -autosize
	Get-ChildItem "$Project_Location"|Format-wide -autosize
    exit
}
If ($args -eq "s") {
	Start-Process "$My_Docs"
	Exit
}
If ($args -eq "dir") {
	Start-Process $Quick_Luanching_Dictionary
	Exit
}
# Write-Host "The first value is $($args[0]), and second value is $($args[1])"
# Search Project Folder only
if ($($args[0]) -eq "pj") {
	Set-Variable -Name PJFOL -Scope script -value 0
	$ddc = Get-ChildItem "$Project_Location\*$($args[1])*" -Name
	foreach($line in $ddc) {
		$PJFOL++
		Set-Variable -Name Project_$PJFOL -Scope script -value "$Project_Location\$line"
		Write-Host [$PJFOL] $line
	}
# Determinate Result
if ($PJFOL -eq 0) {
	Write-Host "No Result Found"
	Exit
}
if ($PJFOL -gt 1) {
    $chose = Read-Host "What is your chose?"
    $Project_1 = Get-Variable Project_$chose -ValueOnly
}
Start-Process "$Project_1"
Exit
}
# Get Websites Markdown File Contents.
Set-Variable -Name n -Scope script -value 0
$Link= Select-String -Pattern "$args" -path "$Quick_Luanching_Dictionary" -Raw
foreach($line in $Link) {
	$n++
	$Target=$line.split('](')
	$Target=$Target[1]
	$Target=$Target -replace '\)'
    Set-Variable -Name abc_$n -Scope script -value $Target
    Write-Host [$n] $Target
}
# Check Folder
Set-Variable -Name Search_Folder_Location -Scope script -value 0
Do
{
	$Search_Folder_Location++
	$Folder_Location = Get-Variable Folder_Location_$Search_Folder_Location -ValueOnly
	$ddc = Get-ChildItem "$Folder_Location\*$args*" -Name
	foreach($line in $ddc) {
		$n++
		Set-Variable -Name abc_$n -Scope script -value "$Folder_Location\$line"
		Write-Host [$n] $line
	}
} Until ($Search_Folder_Location -eq 1)
# Determinate Result
if ($n -eq 0) {
	Write-Host "No Result Found"
	Exit
}
if ($n -gt 1) {
    $chose = Read-Host "What is your chose?"
    $abc_1 = Get-Variable abc_$chose -ValueOnly
}
Start-Process "$abc_1"