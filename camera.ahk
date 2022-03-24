#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

class Camera
{
    Spin(degrees)
    {
        pxls := Configuration.CameraFullTurn() / 360 * degrees
        ; you have to experiment a little with your settings here due to your DPI, ingame sensitivity etc
        DllCall("mouse_event", "UInt", 0x0001, "UInt", pxls, "UInt", 0)
    }

    SpinPxls(pxls)
    {
        ; you have to experiment a little with your settings here due to your DPI, ingame sensitivity etc
        DllCall("mouse_event", "UInt", 0x0001, "UInt", pxls, "UInt", 0)
    }

    GetFullTurn()
    {
        Camera.ResetCamera(true)
        total := 150
        Camera.SpinPxls(-150)
        sleep 150
        while (!UserInterface.MapFixpoint()) {
            Camera.SpinPxls(-1)
            total += 1
        }

        ToolTip % "the required amount for a full turn was: " total
        Clipboard := total
        Pause
    }

    ResetCamera(trackingActivated := false)
    {
        ; make sure map is not transparent
        while (!UserInterface.IsMapOpaque()) {
            Configuration.ToggleMapTransparency()
            sleep 500
        }

        send {AltDown}
        sleep 250

        if (!trackingActivated) {
            UserInterface.ClickTrackingMap()
            sleep 350
        }

        UserInterface.MoveMouseOverMap()
        sleep 50

        ; zoom out completely
        loop, 7 {
            MouseClick, WheelUp
            sleep 75
        }

        send {AltUp}

        total := 0
        while (!UserInterface.MapFixpoint()) {            
            if (total > Configuration.CameraFullTurn()) {
                return false
            }

            Camera.SpinPxls(-2)
            total += 2
        }

        log.addLogEntry("$time: had to spin camera by " total " pixels (" Utility.RoundDecimal(total / Configuration.CameraFullTurn()) ")")

        return true
    }
}