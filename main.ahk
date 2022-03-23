SetKeyDelay, -1, -1
SetWinDelay, -1

#Include %A_ScriptDir%\lib\utility.ahk
#Include %A_ScriptDir%\lib\log.ahk

#Include %A_ScriptDir%\camera.ahk
#Include %A_ScriptDir%\config.ahk
#Include %A_ScriptDir%\game.ahk
#Include %A_ScriptDir%\ui.ahk
#Include %A_ScriptDir%\sync.ahk
#Include %A_ScriptDir%\hotkeys.ahk

class Poharan
{
    static runCount := 0

    static successfulRuns := []
    static failedRuns := []

    static runStartTimeStamp := 0

    ; function we can call when we expect a loading screen and want to wait until the loading screen is over
    WaitLoadingScreen()
    {
        ; just sleep while we're in the loading screen
        while (UserInterface.IsInLoadingScreen()) {
            sleep 5
        }

        ; check any of the skills if they are visible
        while (!UserInterface.IsOutOfLoadingScreen()) {
            sleep 5
        }

        sleep 50
    }

    EnableAnimationSpeedHack()
    {
        loop, 15 {
            Configuration.EnableAnimationSpeedHack()
            sleep 50
        }
    }

    EnableAnimationSpeedHackWarlock()
    {
        loop, 15 {
            Configuration.EnableAnimationSpeedHackWarlock()
            sleep 50
        }
    }

    DisableAnimationSpeedHack()
    {
        loop, 15 {
            Configuration.DisableAnimationSpeedhack()
            sleep 50
        }
    }

    DisableAnimationSpeedHackWarlock()
    {
        loop, 15 {
            Configuration.DisableAnimationSpeedHackWarlock()
            sleep 50
        }
    }

    ; simply check for the buff food and use 
    CheckBuffFood()
    {
        log.addLogEntry("$time: checking buff food")

        ; check if buff food icon is visible
        if (!UserInterface.IsBuffFoodIconVisible()) {
            log.addLogEntry("$time: using buff food")

            Configuration.UseBuffFood()
            sleep 750
            send {w down}
            sleep 50
            send {w up}
            sleep 200
        }
    }

    ; function we use for checking if we should check potions
    CheckHealth()
    {
        if (UserInterface.IsHpBelowCritical()) {
            Configuration.UseHealthPotion()
        }
    }

    EnterLobby()
    {
        log.addLogEntry("$time: moving to dungeon")

        while (true) {
            Game.SwitchToWindow(Game.GetStartingWindowHwid())

            if (UserInterface.IsDuoReady()) {
                break
            }

            ; main invites leecher
            loop, 3 {
                UserInterface.ClickChat()
                sleep 150
            }

            ; clear possible leftovers in chat
            loop, 10 {
                send {BackSpace}
                sleep 2
            }

			sleep 50
            Configuration.InviteDuo()
			sleep 50
            send {Enter}
			sleep 50

            ; every leecher accepts
            for index, hwnd in Game.GetOtherWindowHwids()
            {
                Game.SwitchToWindow(hwnd)
                
                ; while we don't have a party member just normally loop
                if (!UserInterface.HasPartyMemberInLobby()) {
                    loop, 5 {
                        UserInterface.ClickReady()
                        send y
                        sleep 100
                    }

                    if (UserInterface.HasPartyMemberInLobby()) {
                        ; else ready up
                        while (!UserInterface.IsReady()) {
                            ; click ready
                            UserInterface.ClickReady()
                            sleep 1*1000
                        }
                    }
                } else {
                    ; safety activation if we skipped the initial one
                    while (!UserInterface.IsReady()) {
                        ; click ready
                        UserInterface.ClickReady()
                        sleep 250
                    }
                }
            }

            Game.SwitchToWindow(Game.GetStartingWindowHwid())

            ; break if duo is ready or sleep 3 seconds before next invite cycle
            lastInvite := 0
            while (!UserInterface.IsDuoReady()) {
                if (lastInvite + 3*1000 <= A_TickCount) {
                    break
                }
                sleep 25
            }
        }

        while (!UserInterface.IsInLoadingScreen()) {
            ; sometimes stage selection is out of focus, so we try to set it twice
            stage := Configuration.PoharanStage()
			UserInterface.EditStage()
			sleep 250
			send %stage%
			sleep 250

            UserInterface.ClickEnterDungeon()
            start := A_TickCount

            ; repeat loop every 3 seconds but break as soon as we see the loading screen
            while (start + 3*1000 >= A_TickCount) {
                if (UserInterface.IsInLoadingScreen()) {
                    break
                }
                sleep 25
            }
        }
    }

    ; functionality to move all clients into the dungeon
    MoveClientsToDungeon()
    {
        this.runStartTimeStamp := A_TickCount

        Game.SwitchToWindow(Game.GetStartingWindowHwid())
        Poharan.WaitLoadingScreen()

        log.addLogEntry("$time: moving warlock to dungeon")
        Poharan.EnterDungeon()

        log.addLogEntry("$time: moving clients to dungeon")
        ; every leecher moves to the dungeon as well after waiting for possible loading screens
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
            Poharan.WaitLoadingScreen()

            Poharan.EnterDungeon()
        }

        return Poharan.MoveToBoss1()
    }

    ; functionality to move a single client into the dungeon
    EnterDungeon()
    {
        send {w down}
        send {Shift}

        sleep 250

        start := A_TickCount
        while (!UserInterface.IsInLoadingScreen()) {
            if (mod(Round(A_TickCount / 1000), 3) == 0) {
                Random, rand, 1, 10
                if (rand >= 5) {
                    send {Space down}
                    sleep 200
                    send {Space up}
                }
                ; sleep 0.5 seconds so we don't run into the modulo check again in this cycle
                sleep 1000
            }

            sleep 25
        }
    }

    MoveToBoss1()
    {
        Game.SwitchToWindow(Game.GetStartingWindowHwid())
        Poharan.WaitLoadingScreen()

        log.addLogEntry("$time: making portal to Tae Jangum")
        Poharan.MakePortalBoss(1)

        log.addLogEntry("$time: moving clients to Tae Jangum")
        ; every leecher moves to the dungeon as well after waiting for possible loading screens
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
            Poharan.WaitLoadingScreen()

            Poharan.ClientMoveToBoss1()
        }

        return Poharan.FightBoss1()
    }

    MakePortalBoss(boss)
    {
        if (boss == 1) {
            loop, 5 {
                Configuration.EnableClipBossOne()
                sleep 25
            }
        } else {
            loop, 5 {
                Configuration.EnableClipBossTwo()
                sleep 25
            }
        }

        ; position update
        send {w down}
        sleep 250
        send {w up}
        sleep 250

        ; spawn thrall
        send {Tab}
        sleep 2*1000

        loop, 5 {
            Configuration.DisableClipping()
            sleep 25
        }

        ; position update
        send {w down}
        sleep 250
        send {w up}

        ; use block to get into combat to despawn thrall due to distance
        loop, 2 {
            sleep 250
            send {1}
        }
    }

    ClientMoveToBoss1()
    {
        Poharan.WaitLoadingScreen()
        ; fade in sometimes fucked it up, better sleep for a bit
        sleep 1*1000

        send {a down}
        sleep 0.4*1000
        send {a up}

        send {w down}
        sleep 3.5*1000
        send {w up}

        Poharan.EnableAnimationSpeedHack()

        if (!UserInterface.IsPortalIconVisible()) {
            log.addLogEntry("$time: failed to open portal to 1st boss, abandoning run")
            return Poharan.ExitDungeon()
        }

        while (UserInterface.IsPortalIconVisible()) {
            send f
            sleep 250
        }

        ; sleep windstride animation
        sleep 5*1000

        ; get into combat for accurate running distance
        loop, 5 {
            send {tab}
            sleep 100
        }

        send {w down}
        sleep 5*1000 / Configuration.MovementSpeedhackValue()
        send {w up}

        send {d down}
        sleep 9*1000 / Configuration.MovementSpeedhackValue()
        send {w down}
        sleep 5*1000 / Configuration.MovementSpeedhackValue()
        send {d up}
        send {w up}

        send {a down}
        send {s down}
        sleep 0.2*1000 / Configuration.MovementSpeedhackValue()
        send {a up}
        send {s up}

        ; lose aggro of mobs or let them run into range so we don't suicide by running into the fire
        sleep 4*1000
    }

    FightBoss1()
    {
        log.addLogEntry("$time: fighting boss Tae Jangum")

        ; every leecher moves to the dungeon as well after waiting for possible loading screens
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
            Configuration.ToggleAutoCombat()
        }

        while (!UserInterface.IsDynamicVisible()) {
            if (UserInterface.IsReviveVisible() || UserInterface.IsInLoadingScreen()) {
                log.addLogEntry("$time: died during Tae Jangum, abandoning run")
                return Poharan.ExitDungeon()
            }
            sleep 25
        }

        ; let everyone pick up the loot
        sleep 5*1000
        ; let everyone run back to the exit position
        sleep 6*1000 / Configuration.MovementSpeedhackValue()

        ; every leecher moves to the dungeon as well after waiting for possible loading screens
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
            Configuration.ToggleAutoCombat()
            sleep 250
            Camera.ResetCamera()
        }

        return Poharan.MoveToBoss2()
    }

    MoveToBoss2()
    {
        log.addLogEntry("$time: moving clients on bridge")

        ; every leecher moves to Poharan
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)

            send {s down}
            sleep 5*1000 / Configuration.MovementSpeedhackValue()
            send {s up}

            send {a down}
            sleep 4.2*1000 / Configuration.MovementSpeedhackValue()
            send {a up}

            send {w down}
            sleep 10*1000 / Configuration.MovementSpeedhackValue()
            send {w up}

            send {s down}
            sleep 3*1000 / Configuration.MovementSpeedhackValue()
            send {s up}

            send {d down}
            sleep 13*1000 / Configuration.MovementSpeedhackValue()
            send {d up}

            send {a down}
            sleep 0.4*1000 / Configuration.MovementSpeedhackValue()
            send {a up}

            send {w down}
            sleep 4*1000 / Configuration.MovementSpeedhackValue()
            send {w up}

            Configuration.ToggleAutoCombat()
        }

        log.addLogEntry("$time: moving warlock to Poharan")
        Game.SwitchToWindow(Game.GetStartingWindowHwid())
        Poharan.MakePortalBoss(2)

        ; get out of combat
        while (!UserInterface.IsOutOfCombat()) {
            sleep 25
        }

        send {w down}
        sleep 5.3*1000
        send {w up}

        send {a down}
        sleep 0.4*1000
        send {a up}

        if (!UserInterface.IsPortalIconVisible()) {
            log.addLogEntry("$time: failed to open portal to Poharan, abandoning run")
            return Poharan.ExitDungeon()
        }

        while (UserInterface.IsPortalIconVisible()) {
            send f
            sleep 250
        }

        log.addLogEntry("$time: moving clients further down the bridge")
        ; every leecher moves to Poharan
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)

            while (!UserInterface.IsOutOfCombat()) {
                if (UserInterface.IsReviveVisible()) {
                    log.addLogEntry("$time: died on bridge, abandoning run")
                    return Poharan.ExitDungeon()
                }
                sleep 25
            }

            Configuration.ToggleAutoCombat()
            sleep 250
            ; normally we're further down the bridge running back, so turning 150° to the left is nearly always faster
            Camera.Spin(-150)
            sleep 250
            Camera.ResetCamera(true)

            send {w down}
            sleep 15*1000 / Configuration.MovementSpeedhackValue()
            send {w up}

            Configuration.ToggleAutoCombat()

            ; sleep 3 seconds to get into combat if there are mobs left
            sleep 3*1000

            while (!UserInterface.IsOutOfCombat()) {
                sleep 25
            }

            Configuration.ToggleAutoCombat()
            sleep 250
            Camera.ResetCamera(true)
        }

        return Poharan.MoveToPoharan()
    }

    MoveToPoharan()
    {
        log.addLogEntry("$time: moving warlock into position for poharan")
        Game.SwitchToWindow(Game.GetStartingWindowHwid())
        Poharan.EnableAnimationSpeedHackWarlock()

        send {w down}
        send {d down}
        sleep 250
        send {Shift}
        sleep 30*1000 / Configuration.MovementSpeedhackValue()
        send {w up}
        send {d up}

        log.addLogEntry("$time: moving clients into position for poharan")
        ; every leecher moves into the same position as well
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)

            send {w down}
            send {d down}
            sleep 250
            send {Shift}
            sleep 40*1000 / Configuration.MovementSpeedhackValue()
            send {w up}
            send {d up}
        }

        return Poharan.FightPoharan()
    }

    FightPoharan()
    {
        log.addLogEntry("$time: starting autocombat for clients")
        ; every leecher moves into the same position as well
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)

            Configuration.ToggleAutoCombat()
        }

        log.addLogEntry("$time: starting autocombat for warlock")
        Game.SwitchToWindow(Game.GetStartingWindowHwid())
        Configuration.ToggleAutoCombat()

        /*
        log.addLogEntry("$time: switching to clients for better autocombat")
        ; every leecher moves into the same position as well
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
        }
        */

        while (!UserInterface.IsDynamicRewardVisible()) {
            if (UserInterface.IsReviveVisible()) {
                log.addLogEntry("$time: died while fighting poharan, abandoning run")
                return Poharan.ExitDungeon()
            }
            sleep 25
        }

        ; let everyone pick up the loot
        sleep 5*1000
        ; let everyone run back to the exit position
        sleep 6*1000 / Configuration.MovementSpeedhackValue()

        Poharan.DisableAnimationSpeedHackWarlock()
        Poharan.DisableAnimationSpeedHack()

        return Poharan.LeaveDungeon()
    }

    LeaveDungeon()
    {
        Game.SwitchToWindow(Game.GetStartingWindowHwid())

        sleep 250
        Poharan.DisableAnimationSpeedHackWarlock()
        sleep 250

        Poharan.LeaveDungeonClient(false)

        log.addLogEntry("$time: switching to clients for better autocombat")
        ; every leecher moves into the same position as well
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
            sleep 250
            Poharan.DisableAnimationSpeedHack()
            sleep 250
            Poharan.LeaveDungeonClient(true)
        }

        log.addLogEntry("$time: run took " Utility.RoundDecimal(((A_TickCount - this.runStartTimeStamp) / 1000)) " seconds")
        this.successfulRuns.Push(((A_TickCount - this.runStartTimeStamp) / 1000))
        this.runCount += 1

        Poharan.LogStatistics()

        return true
    }

    LeaveDungeonClient(client)
    {
        Configuration.ToggleAutoCombat()
        while (!UserInterface.IsOutOfCombat()) {
            sleep 25
        }

        if (!Camera.ResetCamera(client)) {
            log.addLogEntry("$time: unable to reset camera, returning to lobby")
            return Poharan.ExitDungeon()
        }
        
        sleep 250

        Camera.Spin(180)
        send {w down}
        sleep 3.6*1000
        send {w up}

        Camera.Spin(90)

        sleep 500

        if (!UserInterface.IsExitPortalVisible()) {
            log.addLogEntry("$time: most likely died in the boss fight, returning to lobby")
            return Poharan.ExitDungeon()
        }

        while (UserInterface.IsExitPortalVisible()) {
            send f
            sleep 250
            send y
            sleep 250
        }

        while (!UserInterface.IsInLoadingScreen()) {
            loop, 5 {
                send f
                send y
                sleep 350
            }
            send n
        }
    }

    CheckRepair()
    {
        ; repair weapon after the defined amount of runs
        if (mod(this.runCount, Configuration.UseRepairToolsAfterRunCount()) == 0 || this.runCount == 0) {
            Poharan.RepairWeapon()
        }
    }

    ExitOverLobby()
    {
        log.addLogEntry("$time: exiting over lobby")
        while (!UserInterface.IsInLoadingScreen()) {
            if (!Utility.GameActive()) {
                log.addLogEntry("$time: couldn't find game process, exiting")
                ExitApp
            }

            UserInterface.LeaveParty()
        }

        UserInterface.WaitLoadingScreen()

        return Poharan.ExitDungeon()
    }

    ExitDungeon()
    {
        ; now run in with main account
        Game.SwitchToWindow(Game.GetStartingWindowHwid())
        Poharan.ExitDungeonSingleClient()

        ; every client leaves as well
        for index, hwnd in Game.GetOtherWindowHwids()
        {
            Game.SwitchToWindow(hwnd)
            Poharan.ExitDungeonSingleClient()
        }

        log.addLogEntry("$time: failed run after " Utility.RoundDecimal(((A_TickCount - this.runStartTimeStamp) / 1000)) " seconds")
        this.failedRuns.Push(((A_TickCount - this.runStartTimeStamp) / 1000))
        this.runCount += 1

        Poharan.LogStatistics()

        Poharan.EnterLobby()

        return Poharan.MoveClientsToDungeon()
    }

    ExitDungeonSingleClient()
    {
        log.addLogEntry("$time: exiting dungeon")

        if (UserInterface.IsOutOfCombat()) {
            while (!UserInterface.IsInF8Lobby()) {
                ; walk a tiny bit to close possible confirmation windows
                send {w}
                sleep 250

                send {Esc}
                sleep 1*1000

                UserInterface.ClickExit()
                sleep 1000
                send y
                sleep 1000
                send y
                sleep 1000
                send n
                sleep 1000
                send y
                sleep 1000
            }

            return
        } else {
            while (!UserInterface.IsInLoadingScreen()) {
                UserInterface.ClickLeaveParty()
                sleep 25
                ; in case we're in the reward screen
                loop, 3 {
                    send f
                    sleep 75
                    send y
                    sleep 75
                }
                send n
            }

            while (!UserInterface.IsInF8Lobby()) {
                if (!Utility.GameActive()) {
                    log.addLogEntry("$time: couldn't find game process, exiting")
                    ExitApp
                }

                ; ahk will send Shift+v if we just try to send an upper case v lol
                send V
                sleep 25
            }
        }
    }

    LogStatistics()
    {
        failedRuns := this.failedRuns.Length()
        failedRate := (failedRuns / this.runCount)
        successRate := 1.0 - failedRate

        averageRunTime := 0
        for _, v in this.successfulRuns {
            averageRunTime += v
        }
        averageRunTime /= this.successfulRuns.Length()

        if (!averageRunTime) {
            averageRunTime := 0
        }

        averageFailRunTime := 0
        for _, v in this.failedRuns {
            averageFailRunTime += v
        }
        averageFailRunTime /= this.failedRuns.Length()

        if (!averageFailRunTime) {
            averageFailRunTime := 0
        }

        averageRunsHour := 3600 / (averageRunTime * successRate + averageFailRunTime * failedRate)
        expectedSuccessfulRunsPerHour := averageRunsHour * successRate

        log.addLogEntry("$time: runs done: " this.runCount " (died in " (failedRuns) " out of " this.runCount " runs (" Utility.RoundDecimal(failedRate * 100) "%), average run time: " Utility.RoundDecimal(averageRunTime) " seconds)")
    }

    ; repair the weapon
    RepairWeapon()
    {
        log.addLogEntry("$time: repairing weapon")

        start := A_TickCount
        while (A_TickCount < start + 5.5*1000) {
            Configuration.UseRepairTools()
            sleep 5
        }
    }

    Exiting()
    {
        Utility.ReleaseAllKeys()

        if (Configuration.ShutdownComputerAfterCrash()) {
            WinGet, currentProcess, ProcessName, A
            if (currentProcess != "BNSR.exe") {
                ; normal shutdown and force close applications
                Shutdown, 5
            }
        }
    }
}