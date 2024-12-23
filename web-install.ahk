#Warn ; Enable warnings to assist with detecting common errors.

#include <FindText>

SetTitleMatchMode 1 ; A windows's title must start with the specified WinTitle to be a match.
SetControlDelay 0
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.

winTitle := "ahk_exe RazerInstaller.exe"

; Select software to install
; Only Razer Synapse by default
installText := "|<>*108$45.Y0Mz2424lglUkUkbB247464tg0VcUkZgs49464ZUkVAUkYQ24TY64XgEW6UkYAw4ELrw"
If WinWait(winTitle) {
    WinActivate

    if (FindText(&outputX := "wait", &outputY := -1, 0, 0, 0, 0, 0, 0, installText)) {
        Sleep 5000
        Send "{Enter}" ; Install
    }
}

; Razer Cortex promotion
skipAndContinueText := "|<>*151$113.lrdVzrbgDwT7DE4bhv10aG0z7CEDkA2CU97Po0t9YtyCAbDCHYRtmCrdwy79ntQ9CSTb8PnYBjHsQCH7mMGQwzDGLb9/SUS8QUTYm4ttySYjCGKxDCGNDy0a9nnYtASQaBuSQaGTwtAH7n9mQwtCNYy3C4zvmQUTUsAttmQsM4"
If WinWait(winTitle) {
    WinActivate

    if (FindText(&outputX := "wait", &outputY := -1, 0, 0, 0, 0, 0, 0, skipAndContinueText)) {
        Sleep 5000
        Send "{Esc}" ; Skip and Continue
    }
}

; Congratulations, Get Started screen
getStartedText := "|<>*107$77.C7rs6DkVtzTC2q830H633QskP76E21W4748V0XC0U4308+8F212M1w83UEYPW7m4lm0E0kVAy4849kY0U0V7t48E8GV810l28OAEUFUwT20w4EI8VyyA"
If WinWait(winTitle) {
    WinActivate

    if (FindText(&outputX := "wait", &outputY := -1, 0, 0, 0, 0, 0, 0, getStartedText)) {
        Sleep 5000
        Send "{Tab}"
        Send "{Tab}"
        Send "{Space}" ; Stop Razer Synapse from starting on finish
        Send "{Tab}"
        Send "{Enter}" ; Get Started
    }
}

; Check to see if Razer Synapse installer window still exists
If WinWait(winTitle,, 5) {
    ; If it does, something went wrong, exit with a non 0 code to use in Powershell script
    WinClose
    ExitApp 1
}

ExitApp 0