param (
    [switch]$Front,
    [switch]$Back
)
$Time_Formating="yyyy-MM-dd_dddd"
$self_lastModified = (Get-Item $MyInvocation.MyCommand.Path).LastWriteTime.ToString("$Time_Formating")
# 获取文件列表
$files = Get-ChildItem -Path $args
$files
Write-Host "------------------"
Write-Host "默认的时间格式是:$Time_Formating"
Write-Host "以本脚本为例子, 时间格式会是" $self_lastModified
$Change_Time_Formating = Read-Host "如果满意, 直接按下Enter; 如果不满意, 输入想要的时间格式"
if ($Change_Time_Formating -ne "") {
	$Time_Formating = $Change_Time_Formating
	Write-Host "新的时间格式为:$Time_Formating"
	$self_lastModified = (Get-Item $MyInvocation.MyCommand.Path).LastWriteTime.ToString("$Time_Formating")
	Write-Host "以本脚本为例子, 用户设定的时间格式会是" $self_lastModified
}
Write-Host "在插入时间之前, 要不要统一加一些字符上去? 您可以选择按回车键跳过"
$Text_To_Insert = Read-Host 

foreach ($Path in $files) {
    # 获取文件信息
    $file = Get-Item -Path $Path
    
    # 获取文件的最后修改时间
    $lastModified = $file.LastWriteTime.ToString("$Time_Formating")
    
    # 获取文件名和扩展名
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $extension = $file.Extension
    
    # 构建新的文件名
    if ($Front) {
        $newName = "$Text_To_Insert-$lastModified-$fileName$extension"
    } elseif ($Back) {
        $newName = "$fileName-$Text_To_Insert-$lastModified$extension"
    } else {
        # 默认插入到文件名的前面
        $newName = "$Text_To_Insert-$lastModified-$fileName$extension"
    }
    
    # 重命名文件
    Rename-Item -Path $file.FullName -NewName $newName
}