if (-Not $Profile_Location) {Get-Content $PSScriptRoot\project_variable.ini|Invoke-Expression}
$Show_Dir = $False
if (-Not $dafile) {qu.ps1}
Function readla ($param) {
	[int]$n = 0
	foreach($line in Get-Content -LiteralPath "$dafile" -tail $param) {
		$n++
		Write-Host "`r"
		Write-Host "$n : "$line
	}
	Write-Host --------------------------------------------------------------------------------
}
if ($args) {
    If ($args -match "^\d+$") {
        $Number=$args[0]
        readla ($Number)
    } else {
        $Nowtime = get-date -format "yyyy-MM-dd dddd HH:mm:ss tt"
        Add-Content -LiteralPath "$dafile" -value "- $Nowtime $CurDir : $args"
    }
exit
}
Write-Host "1. Type Any Number to Review how many last messages that you have leaved to the profile. `n2. Type Anything to Leave your message to the profile.`n3. But, If your input begin with a colon(:), your message would EXECUTED as a command rather than been recorded`n4. If you want also attach Current Diretory Name, set Variable 'Show_Dir' to 1 (true) "
Write-Host --------------------------------------------------------------------------------
Write-Host "Last 8 messages:"
readla (8)
Get-Content -LiteralPath "$dafile" -head 2|Write-Host
Do
{
	if ($Show_Dir -eq $true) {
		$CurDir = Split-Path -Path $PWD -leaf
	}
	$Nowtime = get-date -format "yyyy-MM-dd dddd HH:mm:ss tt"
	Write-Host "                         [$Nowtime]`n"
	$User_input=Read-Host
	if ($User_input.StartsWith(':')) {
		$temp_command = $User_input.substring(1)
		Invoke-Expression $temp_command
		continue
	}
	if ($User_input.StartsWith('!')) {
		$Todo_Notes = $User_input.substring(1)
		Add-Content -LiteralPath "$dafile" -value "- [ ] $Todo_Notes ($Nowtime)"
		continue
	}
	if ($User_input.StartsWith('?')) {
		$Todone_Notes = $User_input.substring(1)
		$SearchFile=(Select-String -SimpleMatch -LiteralPath "$dafile" -Pattern "$ToDone_Notes").line
		continue
	}

    if ($User_input -match "^\d+$") {
        readla ($User_input)
		continue
    }
    Add-Content -LiteralPath "$dafile" -value "- $Nowtime $CurDir : $User_input"
} until ($User_input -eq "wq")
Write-Host "You're exit the appended edit mode now"