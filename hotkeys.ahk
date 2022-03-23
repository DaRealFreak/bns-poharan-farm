#Persistent
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#MaxThreadsPerHotkey, 99

OnExit(ObjBindMethod(Poharan, "Exiting"))

#IfWinActive ahk_class UnrealWindow
F1::
    MouseGetPos, mouseX, mouseY
    color := Utility.GetColor(mouseX, mouseY, r, g, b)
    tooltip, Coordinate: %mouseX%`, %mouseY% `nHexColor: %color%`nR:%r% G:%g% B:%b%
    Clipboard := "Utility.GetColor(" mouseX "," mouseY ") == `""" color "`"""
    SetTimer, RemoveToolTip, -5000
    return

RemoveToolTip:
    tooltip
    return

#IfWinActive ahk_class UnrealWindow
F2::
    global log := new LogClass("poharan_multibox")
    log.initalizeNewLogFile(1)
    log.addLogEntry("$time: starting poharan farm")

    Game.SetStartingWindowHwid()

    Poharan.EnterLobby()

    loop {
        if (!Poharan.MoveClientsToDungeon()) {
            break
        }
        sleep 250
    }

    return
	
*NumpadDot::
    Utility.ReleaseAllKeys()
    Reload
    return

*NumPadEnter::
    Utility.ReleaseAllKeys()
    ExitApp