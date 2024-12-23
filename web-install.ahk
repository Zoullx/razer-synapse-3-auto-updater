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

    ; installX := ""
    ; installY := ""

    ; While (installX = "") and (installY = "") {
    ;     If WinExist(winTitle) {
    ;         WinActivate
    ;         WinGetPos &posX, &posY, &installW, &installH
    ;         ImageSearch, installX, installY, 0, 0, %installW%, %installH%, assets\Install.png
    ;         Sleep 5000
    ;     }
    ; }

    ; Send "{Enter}"
}

; Razer Cortex promotion
skipAndContinueText := "|<>*151$113.lrdVzrbgDwT7DE4bhv10aG0z7CEDkA2CU97Po0t9YtyCAbDCHYRtmCrdwy79ntQ9CSTb8PnYBjHsQCH7mMGQwzDGLb9/SUS8QUTYm4ttySYjCGKxDCGNDy0a9nnYtASQaBuSQaGTwtAH7n9mQwtCNYy3C4zvmQUTUsAttmQsM4"
If WinWait(winTitle) {
    WinActivate

    if (FindText(&outputX := "wait", &outputY := -1, 0, 0, 0, 0, 0, 0, skipAndContinueText)) {
        Sleep 5000
        Send "{Esc}" ; Skip and Continue
    }

    ; skipAndContinueX := ""
    ; skipAndContinueY := ""

    ; While (skipAndContinueX = "") and (skipAndContinueY = "") {
    ;     If WinExist(winTitle) {
    ;         WinActivate
    ;         WinGetPos,,, skipAndContinueW, skipAndContinueH
    ;         ImageSearch, skipAndContinueX, skipAndContinueY, 0, 0, %skipAndContinueW%, %skipAndContinueH%, assets\SkipAndContinue.png
    ;         Sleep 5000
    ;     }
    ; }

    ; Send "{Esc}"
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

    ; getStartedX := ""
    ; getStartedY := ""

    ; While (getStartedX = "") and (getStartedY = "") {
    ;     If WinExist(winTitle) {
    ;         WinActivate
    ;         WinGetPos,,, getStartedW, getStartedH
    ;         ImageSearch, getStartedX, getStartedY, 0, 0, %getStartedW%, %getStartedH%, assets\GetStarted.png
    ;         Sleep 5000
    ;     }
    ; }

    ; Send "{Tab}"
    ; Send "{Tab}"
    ; Send "{Space}" ; Stop Razer Synapse from starting on finish
    ; Send "{Tab}"
    ; Send "{Enter}" ; Get Started
    ; Sleep 5000 ; Give enough time for window to fully close if everything is progressing properly before checking if the window it still open
}

; Check to see if Razer Synapse installer window still exists
If WinWait(winTitle,, 5) {
    ; If it does, something went wrong, exit with a non 0 code to use in Powershell script
    WinClose
    ExitApp 1
}

ExitApp 0