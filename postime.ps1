ForEach ($tst in $args) {
    if (Test-Path $tst) {
        Write-Host "The File path is $tst"
       Get-ChildItem -File $tst | rename-item -newname { $_.Basename+"-"+($_.CreationTime.toString("yyyy_MM_dd_dddd-HH_mm_tt"))+$_.Extension}
    } else {
        Get-ChildItem -File "*$tst*" | rename-item -newname { $_.Basename+"-"+($_.CreationTime.toString("yyyy_MM_dd_dddd-HH_mm_tt"))+$_.Extension}
    }
}