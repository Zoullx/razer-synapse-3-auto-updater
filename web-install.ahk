; #NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
#Warn ; Enable warnings to assist with detecting common errors.

#include <FindText>

SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, 1 ; A windows's title must start with the specified WinTitle to be a match.
SetControlDelay 0
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

winTitle = ahk_exe RazerInstaller.exe

; Splash screen
; Wait until the Razer Installer is found
; Activate to make sure that it's on top when the actual installer opens
WinWait, %winTitle%
If WinExist(winTitle) {
    ; Maybe spread this throughout the script
    ; It seemed to work without doing that, but it might become an issue if something else happens during install
    WinActivate
}

installText:="|<>*112$46.G0ATV213APByA8AAtgFUsUknak66W33/NkMG8AAbUlVAUkmCV6Dm338v4MVcAAVblW6yzU"
winX = 0
winY = 0
winW = 0
winH = 0

; Select software to install
; Only Razer Synapse by default
If (FindText("wait", -1,,,,,,, installText)) {
    WinGetPos, winX, winY, winW, winH, winTitle
    Sleep, 5000
    Send {Enter} ; Install
}

skipText:="|<>*148$25.lnVVk9YU3YaHYy79m73YlsVm1CGNDb9YbsAsHw"

; Razer Cortex promotion
If (FindText("wait", -1, winX, winY, winX+winW, winY+winH,,, skipText)) {
    Sleep, 5000
    Send {Esc} ; Skip and Continue
}

cancelText:="|<>*152$45.kySxss5w3nXY31jbQQQb9xtzVVZzDjDtAYjsBtzAaZzDjj84kb9xwmQb4vDjkHkskM44"

; Installation
If (FindText("wait", -1, winX, winY, winX+winW, winY+winH,,, cancelText)) {
    Sleep, 5000
}

getStartedText:="|<>*106$77.C7rs6DkVtzTC2q830H633QskP76E21W4748V0XC0U4308+8F212M1w83UEYPW7m4lm0E0kVAy4849kY0U0V7t48E8GV810l28OAEUFUwT20w4EI8VywA"

; Congratulations, Get Started screen
If (FindText("wait", -1, winX, winY, winX+winW, winY+winH,,, getStartedText)) {
    Sleep, 5000
    Send {Tab}
    Send {Tab}
    Send {Space} ; Stop Razer Synapse from starting on finish
    Send {Tab}
    Send {Enter} ; Get Started
    Sleep, 5000 ; Give enough time for window to fully close if everything is progressing properly before checking if the window it still open
}

; Check to see if Razer Synapse installer window still exists
WinWait, %winTitle%,, 15
If WinExist(winTitle)
{
    ; If it does, something went wrong, exit with a non 0 code to use in Powershell script
    WinClose
    ExitApp, 1
}

ExitApp, 0