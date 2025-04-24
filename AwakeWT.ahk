#Requires AutoHotkey v2.0
global xpos1 := 0, ypos1 := 0 ; 初始化全局变量 xpos1 和 ypos1
global xpos2 := 0, ypos2 := 0 ; 初始化全局变量 xpos2 和 ypos2
global xValue := 0, yValue := 0 ; 初始化全局变量 xValue 和 yValue
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