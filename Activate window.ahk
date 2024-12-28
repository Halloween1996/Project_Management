global targetWindow := ""

#+q:: 
if (targetWindow = "") {
    ; 获取当前活动窗口的ID
    targetWindow := WinExist("A")
    MsgBox, tracking current Activate windows
} else {
    ; 清除变量
    Winshow, ahk_id %targetWindow%
    targetWindow := ""
    MsgBox, untracking any the windows
}
return

; 呼唤窗口
#q:: 
if (targetWindow != "") {
    ; 获取当前活动窗口的ID
    currentWindow := WinExist("A")
    if (currentWindow != targetWindow) {
        WinShow, ahk_id %targetWindow%
        WinActivate, ahk_id %targetWindow%
    } else {
        ; 隐藏目标窗口
        WinHide, ahk_id %targetWindow%
    }
}
return