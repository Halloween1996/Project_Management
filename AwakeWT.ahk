#Requires AutoHotkey v2.0
CoordMode "Mouse", "Screen"

~*RButton:: {
    MouseGetPos &startX, &startY  ; 记录按住右键时的初始坐标
    while GetKeyState("RButton", "P") {  ; 按住右键时监测鼠标移动
        Sleep 100
        MouseGetPos &currentX, &currentY
        moveX := currentX - startX
        moveY := currentY - startY

        if (startY <= 50) {
            if (moveY > 80) {  ; 向下滑动超过 x 像素 → 打开开始菜单
                Send("{LWin}")  
                break
            } else if (moveY > 50) {  ; 向下滑动超过 x 像素 → 任务切换
                Send("#{Tab}")
                break
            } else if (moveX > 100) {  ; 向右拖动超过 x 像素 → Alt + Tab
                Send("!{Tab}")  
                break
            } else if (moveX < -100) {  ; 向左拖动超过 x 像素 → Alt + Shift + Tab
                Send("!+{Tab}")  
                break
            }
        }
    }
}

+Space::
{
    activePID := WinGetPID("A") ; 获取当前窗口的进程 ID
    activeProcess := ProcessGetName(activePID) ; 获取当前窗口的进程名称

    if (activeProcess = "WindowsTerminal.exe") ; 检查当前窗口是否为 Windows Terminal 的进程
    {
        WinMinimize("A") ; 如果是 Windows Terminal，则隐藏窗口
    }
    else
    {
        if !WinExist("ahk_class CASCADIA_HOSTING_WINDOW_CLASS") ; 检查 Windows Terminal 是否已打开
        {
            Run("wt.exe") ; 如果未打开，则启动 Windows Terminal
            Sleep(1000) ; 等待窗口加载完成
        }
        WinShow("ahk_class CASCADIA_HOSTING_WINDOW_CLASS") ; 确保窗口可见
        WinActivate("ahk_class CASCADIA_HOSTING_WINDOW_CLASS") ; 激活 Windows Terminal
    }
    return
}
CapsLock::return

#HotIf GetKeyState("RButton", "P")
WheelUp:: Send('{Volume_Up 2}')
WheelDown:: Send('{Volume_Down 2}')
XButton2::Send('{Lwin}')
#HotIf GetKeyState("CapsLock", "P")
{
    q::Send("{Click}")
    t::Send("{RButton}")
    w::Send("{Up}")
    s::Send("{Down}")
    a::Send("{Left}")
    d::Send("{Right}")
    f::Send("{Right}")
    g::Send("{Enter}")
    e::Send("{PgUp}")
    r::Send("{PgDn}")
    1::Send("{F11}")
    2::Send("{F2}")
    3::Send("{F3}")
    4::Send("{F4}")
    5::Send("{F5}")
    6::Send("{F6}")
    7::Send("{F7}")
    8::Send("{F8}")
    9::Send("{F9}")
    0::Send("{F10}")
}
#HotIf
