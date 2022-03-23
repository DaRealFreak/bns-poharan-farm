#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

/*
This class is primarily used for specific keys or optional settings like speedhack, cross server etc
*/
class Configuration 
{
    ; which stage to farm
    PoharanStage()
    {
        return 5
    }

    InviteDuo()
    {
        send /invite "Lunar Tempest"
    }

    ToggleMapTransparency()
    {
        send n
    }

    ; whatever we want to do if health is critical (f.e. hmb/drinking potions)
    CriticalHpAction()
    {
        Configuration.UseHealthPotion()
    }

    UseHealthPotion()
    {
        send 5
    }

    GetIntoCombat()
    {
        ; tab spin as destroyer, use a short cooldown skill which doesn't move your character
        send {tab}
    }

    ; the amount of pixels you have to move before reaching a full 360° turn ingame
    CameraFullTurn()
    {
        return 3174
    }

    ; hotkey where the field repair hammers are placed
    UseRepairTools()
    {
        send 7
    }

    ; after how many runs should we repair our weapon
    UseRepairToolsAfterRunCount()
    {
        return 30
    }

    ToggleAutoCombat()
    {
        send {ShiftDown}{f4 down}
        sleep 250
        send {ShiftUp}{f4 up}
    }

    ; enable speed hack (sanic or normal ce speedhack)
    EnableLobbySpeedhack()
    {
        send {Numpad7}
    }

    ; disable movement speed hack (sanic or normal ce speedhack)
    DisableLobbySpeedhack()
    {
        send {Numpad3}
    }

    EnableAnimationSpeedhack()
    {
        send {Numpad6}
    }

    DisableAnimationSpeedhack()
    {
        send {Numpad3}
    }

    EnableAnimationSpeedHackWarlock()
    {
        send {F21}
    }

    DisableAnimationSpeedHackWarlock()
    {
        send {Numpad3}
    }

    ; configured speed value
    MovementSpeedhackValue()
    {
        return 8
    }

    ; shortcut for shadowplay clip in case we want to debug how we got stuck or got to this point
    ClipShadowPlay()
    {
        send {alt down}{f10 down}
        sleep 1000
        send {alt up}{f10 up}
    }

    UseTalisman()
    {
        send r
    }

    UseRevive()
    {
        send 4
    }

    UseBlockSkill()
    {
        send 1
    }

    EnableClipBossOne()
    {
        ; x -> 11551
        ; y -> -35812
        ; z -> -736
        send {Numpad8}
    }

    EnableClipBossTwo()
    {
        ; x -> 7865
        ; y -> -26527
        ; z -> -338
        send {Numpad9}
    }

    DisableClipping()
    {
        send {Numpad4}
    }
}