; #NoTrayIcon
#Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode 1 ; A windows's title must start with the specified WinTitle to be a match.
SetControlDelay 0
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

winTitle := "ahk_exe RazerInstaller.exe"

; Select software to install
; Only Razer Synapse by default
WinWait, %winTitle%
If WinExist(winTitle) {
    WinActivate

    installX := ""
    installY := ""

    While (installX = "") and (installY = "") {
        If WinExist(winTitle) {
            WinActivate
            WinGetPos,,, installW, installH
            ImageSearch, installX, installY, 0, 0, %installW%, %installH%, assets\Install.png
            Sleep, 5000
        }
    }

    Send {Enter}
}

; Razer Cortex promotion
WinWait, %winTitle%
If WinExist(winTitle) {
    WinActivate

    skipAndContinueX := ""
    skipAndContinueY := ""

    While (skipAndContinueX = "") and (skipAndContinueY = "") {
        If WinExist(winTitle) {
            WinActivate
            WinGetPos,,, skipAndContinueW, skipAndContinueH
            ImageSearch, skipAndContinueX, skipAndContinueY, 0, 0, %skipAndContinueW%, %skipAndContinueH%, assets\SkipAndContinue.png
            Sleep, 5000
        }
    }

    Send {Esc}
}

; Congratulations, Get Started screen
WinWait, %winTitle%
If WinExist(winTitle) {
    WinActivate

    getStartedX := ""
    getStartedY := ""

    While (getStartedX = "") and (getStartedY = "") {
        If WinExist(winTitle) {
            WinActivate
            WinGetPos,,, getStartedW, getStartedH
            ImageSearch, getStartedX, getStartedY, 0, 0, %getStartedW%, %getStartedH%, assets\GetStarted.png
            Sleep, 5000
        }
    }

    Send {Tab}
    Send {Tab}
    Send {Space} ; Stop Razer Synapse from starting on finish
    Send {Tab}
    Send {Enter} ; Get Started
    Sleep, 5000 ; Give enough time for window to fully close if everything is progressing properly before checking if the window it still open
}

; Check to see if Razer Synapse installer window still exists
WinWait, %winTitle%,, 5
If WinExist(winTitle)
{
    ; If it does, something went wrong, exit with a non 0 code to use in Powershell script
    WinClose
    ExitApp, 1
}

ExitApp, 0