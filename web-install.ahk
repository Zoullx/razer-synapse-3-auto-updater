#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #NoTrayIcon
#Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, 1 ; A windows's title must start with the specified WinTitle to be a match.
SetControlDelay 0
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

winTitle = ahk_exe RazerInstaller.exe

; Splash screen
; Wait for it to go away
WinWait, %winTitle%,, 120
If WinExist(winTitle)
{
    Sleep, 25000
}

; Select software to install
; Only Razer Synapse by default
WinWait, %winTitle%,, 15
If WinExist(winTitle)
{
    WinActivate
    Send {Enter} ; Install
    Sleep, 4000 ; Wait for transition to finish
}

; Razer Cortex promotion
WinWait, %winTitle%,, 15
If WinExist(winTitle)
{
    WinActivate
    Send {Esc} ; Skip and Continue
    Sleep, 4000 ; Wait for next screen to fully load
}

; Installation
; Wait for it to finish
WinWait, %winTitle%,, 15
If WinExist(winTitle)
{
    Sleep, 260000
}

; Congratulations, Get Started screen
WinWait, %winTitle%,, 15
If WinExist(winTitle)
{
    WinActivate
    Send {Tab}
    Send {Tab}
    Send {Space} ; Stop Razer Synapse from starting on finish
    Send {Tab}
    Send {Enter} ; Get Started
    Sleep, 4000
}

; Check to see if Razer Synapse installer window still exists
WinWait, %winTitle%,, 15
If WinExist(winTitle)
{
    ; If it does, something went wrong, exit with a non 0 code to use in Powershell script
    WinClose
    ExitApp 1
}

ExitApp 0