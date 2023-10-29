#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
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

installText:="|<>*98$90.sM0kDsTzkC0M0A0sQ0kTwTzkC0M0A0sS0kkC0k0S0M0A0sS0lk60k0P0M0A0sT0lk60k0P0M0A0sPUkk00k0nUM0A0sNUks00k0lUM0A0sNkkT00k0lUM0A0sMskDs0k1UkM0A0sMMk1w0k1UkM0A0sMQk0C0k3UkM0A0sMCk060k3zsM0A0sM7lU60k3zsM0A0sM7lk60k70QM0A0sM3kkC0k60AM0A0sM1kzw0kC0ATyDzsM1kDs0kA0CTyDzU"
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

skipText:="|<>*160$49.k3tz7703k0wz3XU0EyCT3lly0z7D3sszUTnb3wQTkDznXyCDsVztXz77wE7w3zXXyC0y0zlk0DkD0Dss0Dz3X3wQ0zzlnlyCDzDwtwT77zXyQy7XXzkyCTVllzw0DDssszz0DbyAQTz"

; Razer Cortex promotion
If (FindText("wait", -1, winX, winY, winX+winW, winY+winH,,, skipText)) {
    Sleep, 5000
    Send {Esc} ; Skip and Continue
}

cancelText:="|<>*161$89.w1zszlzXw1y037zU1zlzVz7k1w06Dy7lz1z1yD7ltzwTwTXy3y3wQTlnzsztzXwbw3sszXbzlzXzDl7s7lnzbDzXz7zzbDl7XbzyTz7yDzyCDX76Dzw0CDwTzwQT6CATzs0QTszztwyCAMzzlzszlzzU0wS8tzzbzlzXzD01sw1lzbDzXzbyA01lw3XyCTz7z7sszXXw77wQzyDz7lnzb7sD7ltzwTy077z6DsT07k0M0D0SDyATsz0TU0k0E"

; Installation
If (FindText("wait", -1, winX, winY, winX+winW, winY+winH,,, cancelText)) {
    Sleep, 5000
}

getStartedText:="|<>*100$154.3y1zwzzU1z3zy1k3zVzzDzXz0Azw7znzy0DyDzs70DzbzwzyDz0nUsQ00Q01kQ1k0S0s60s3U0kC3Q1Vk01k060k703M3UQ3UC030MBU7700700s30Q0BUC0kC0s0A0kq00Q00Q01U01k1r0s30s3U0k33s01k01k0700706A3UQ3UC030ADU07zU700DU0Q0MkC1UC0zwA0sy3sTy0Q00Dk1k31Uzy0s3zkk3XsTlk01k00DU70A63zU3UC030CDU7700700070Q1kQC60C0s0A0kq0QQ00Q000A1k7zksQ0s3U0k33M1lk01k0A0k70Tz3Uk3UC030Q1k7700700s30Q3UCC3UC0s0A1U3UQQ00Q01UQ1kA0Ms60s3U0kC07zVzw1k07zU70k1nUQ3UDzXzkADw7zk7007w0Q703C0sC0zyDw0s"

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