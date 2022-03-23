#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

/*
This class is used for differences in the user interfaces.
If the resolution and ClientConfiguration.xml are not identical you'll always have to change these settings
*/
class UserInterface
{
    ClickExit()
    {
        MouseClick, left, 1770, 870
    }

    ; start holding mouse right side of the stage number and release it left of the stage number to edit
    EditStage()
    {
		; click on poharan dungeon to select it
		loop, 3 {
			MouseClick, Left, 1561, 666
			sleep 150
		}
		sleep 250

        MouseClick, Left, 1747, 478
        click down
        sleep 150
        MouseMove, 1710, 478
        click up
    }

    ClickReady()
    {
        MouseClick, left, 962, 1037
    }

    ClickChat()
    {
        MouseClick, left, 160, 883
    }

    ClickEnterDungeon()
    {
        MouseClick, left, 1026, 1037
    }

    IsDuoReady()
    {
        return Utility.GetColor(984,119) == "0x38D454"
    }

    HasPartyMemberInLobby()
    {
        return Utility.GetColor(965,120) == "0xD4B449"
    }

    ; I'm checking the c (white and grey) on the ready button (due to my character being too big lol), green checkmark works as well
    IsReady()
    {
        col := Utility.GetColor(940,1036)
        return col == "0xFFFFFF" || col == "0x898989"
    }

    IsPortalIconVisible()
    {
        return Utility.GetColor(1152,715) == "0xFEAA00"
    }

    IsHpBelowCritical()
    {
        return Utility.GetColor(987,843) != "0xDB2F0E"
    }

    ; quest icon for dynamic quest notifying us of the first boss kill
    IsDynamicVisible()
    {
        return Utility.GetColor(1590,718) == "0xE38658"
    }

    IsDynamicRewardVisible()
    {
        return Utility.GetColor(1628,685) == "0x463E2C"
    }

    ; some of the filled out bar in the loading screen on the bottom of the screen
    IsInLoadingScreen()
    {
        return Utility.GetColor(17,1063) == "0xFF7C00"
    }

    ; literally any UI element in lobby and ingame, just used for checking if we're out of the loading screen, I'm using here my unity bar and enter button
    IsOutOfLoadingScreen()
    {
        return Utility.GetColor(811,794) == "0xED5E11" || UserInterface.IsInF8Lobby()
    }

    IsInF8Lobby()
    {
        return Utility.GetColor(23,34) == "0xCECECF"
    }

    ; any pixel on the revive skil
    IsReviveVisible()
    {
        return Utility.GetColor(1034,899) == "0x645338"
    }

    ; sprint bar to check if we're out of combat
    IsOutOfCombat()
    {
        return Utility.GetColor(841,837) == "0xA0B930"
    }

    MoveMouseOverMap()
    {
        MouseMove, 1651, 251
    }

    ClickTrackingMap()
    {
        MouseClick, left, 1891, 51
    }

    IsMapOpaque()
    {
        return Utility.GetColor(1892,278) == "0x98896B"
    }

    MapFixpoint()
    {
        return Utility.GetColor(1512,169) == "0x6E7A60"
    }

    IsExitPortalVisible()
    {
        return Utility.GetColor(1148,724) == "0xFFE10A"
    }

    ClickLeaveParty()
    {
        send {AltDown}
        sleep 250
        MouseClick, left, 321, 78
        sleep 250
        send {AltUp}
        sleep 250
        send y
    }

}