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
Sleep, 25000

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
Sleep, 240000

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
}

Exit