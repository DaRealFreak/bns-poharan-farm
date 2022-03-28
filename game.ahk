#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\lib\windows.ahk

class Game
{
    static startingWindowHwnd := 0x0

    __New() {
        this.SetStartingWindowHwnd()
    }

    ; set the current active window as starting window
    SetStartingWindowHwnd()
    {
        ; A = active window
        WinGet, winId ,, A
        this.startingWindowHwnd := winId
    }

    ; retrieve the window hwnd of the game when we started the script
    GetStartingWindowHwnd()
    {
        return this.startingWindowHwnd
    }

    ; get hwnds of twink account windows (excluded main window hwnd) to switch f.e. windows for escaping
    GetOtherWindowHwnds()
    {
        gameHwnds := []

        WinGet, winIds, List , Blade & Soul
        Loop, %winIds%
        {
            hwnd := winIds%A_Index%
            if (hwnd != this.startingWindowHwnd) {
                gameHwnds.Push(hwnd)
            }
        }

        return gameHwnds
    }

    ; get hwnds of twink account windows (excluded main window hwnd) to switch f.e. windows for escaping sorted by process creation time
    GetOtherWindowHwndsSorted()
    {
        processIds := []
        sortedHwnd := []
        list := ""

        for _, hwnd in Game.GetOtherWindowHwnds()
        {
            creationTime := GetHwndCreationTime(hwnd)
            list .= creationTime ","
            processIds[creationTime] := hwnd
        }

        list :=	Trim(list,",")
        Sort, list, N D`,

        out := []
        loop, parse, list, `,
            out.Push(A_LoopField)

        for _, creationTime in out
        {
            sortedHwnd.Push(processIds[creationTime])
        }

        return sortedHwnd
    }

    ; get all relevant window hwnds to send inputs to
    GetRelevantWindowHwnds()
    {
        gameHwnds := []
        gameHwnds.Push(Game.GetStartingWindowHwnd())

        if Configuration.UseMultiBoxing() {
            twinkWindowHwnds := Game.GetOtherWindowHwnds()

            for _, hwnd in twinkWindowHwnds
            {
                gameHwnds.Push(hwnd)
            }
        }

        return gameHwnds
    }

    ; send the key to all relevant windows
    SendInput(key)
    {
        hwndList := Game.GetOtherWindowHwnds()
        Send, %key%
        for _, hwnd in hwndList
        {
            ; control send is not working for down & up keys, but it sets the hwnd as "active" window internally, allowing for send to work
            ControlSend,, %key%, ahk_id %hwnd%
        }
    }

    SwitchToWindow(hwnd)
    {
		winId := 0
		while (winId != hwnd) {
			DllCall("SetForegroundWindow", "Ptr", hwnd)
			;WinActivate, ahk_id %hwnd%
			sleep 500
			WinGet, winId ,, A
		}
    }

    ; small test function to test swapping to twink windows before swapping back to main window
    TestWindowSwaps()
    {
        Game.SetStartingWindowHwnd()

        for index, hwnd in Game.GetOtherWindowHwndsSorted()
        {
            Game.SwitchToWindow(hwnd)
            MsgBox % "index: " . index . " hwnd: " . hwnd
        }

        startingWindowHwnd := Game.GetStartingWindowHwnd()
        WinActivate, ahk_id %startingWindowHwnd%
    }
}