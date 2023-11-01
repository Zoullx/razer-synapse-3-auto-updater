; #NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #NoTrayIcon
#Warn ; Enable warnings to assist with detecting common errors.

#include <FindText>

SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, 1 ; A windows's title must start with the specified WinTitle to be a match.
SetControlDelay 0
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

winTitle = ahk_exe RazerInstaller.exe

; Splash screen
; Wait until the Razer Synapse Installer is found
WinWait, %winTitle%
FindText().BindWindow(WinExist(winTitle)) ; Bind FindText to Razer Synapse Installer

installText:="|<>*112$46.G0ATV213APByA8AAtgFUsUknak66W33/NkMG8AAbUlVAUkmCV6Dm338v4MVcAAVblW6yzU"

; Select software to install
; Only Razer Synapse by default
If (FindText("wait", -1,,,,,,, installText)) {
    Sleep, 5000
    ControlSend,, {Enter} ; Install
}

skipText:="|<>*148$25.lnVVk9YU3YaHYy79m73YlsVm1CGNDb9YbsAsHw"

; Razer Cortex promotion
If (FindText("wait", -1,,,,,,, skipText)) {
    Sleep, 5000
    ControlSend,, {Esc} ; Skip and Continue
}

cancelText:="|<>*152$45.kySxss5w3nXY31jbQQQb9xtzVVZzDjDtAYjsBtzAaZzDjj84kb9xwmQb4vDjkHkskM44"

; Installation
If (FindText("wait", -1,,,,,,, cancelText)) {
    Sleep, 5000
}

getStartedText:="|<>*106$77.C7rs6DkVtzTC2q830H633QskP76E21W4748V0XC0U4308+8F212M1w83UEYPW7m4lm0E0kVAy4849kY0U0V7t48E8GV810l28OAEUFUwT20w4EI8VywA"

; Congratulations, Get Started screen
If (FindText("wait", -1,,,,,,, getStartedText)) {
    Sleep, 5000
    ControlSend,, {Tab}
    ControlSend,, {Tab}
    ControlSend,, {Space} ; Stop Razer Synapse from starting on finish
    ControlSend,, {Tab}
    ControlSend,, {Enter} ; Get Started
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

FindText().BindWindow(0) ; Unbind FindText to Razer Synapse Installer

ExitApp, 0