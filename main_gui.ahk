; =========================
; MAIN GUI (RESTORED to original compact size)
; =========================
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFFFFF

Gui, Add, Text, x10 y5 w220 h20 cBlue BackgroundTrans, Fishing Macro v1.6 by fearless9453
Gui, Add, Text, x10 y30 w50 h20, Status:
Gui, Add, Text, x65 y30 w120 h20 vStatusText BackgroundTrans, Off
Gui, Add, Text, x10 y55 w260 h20 vCurrentStatusText BackgroundTrans, %CurrentStatus%

Gui, Add, Checkbox, x10 y80 w150 h20 vDebugCheckbox gToggleDebug BackgroundTrans, Debug Mode
Gui, Add, Text, x170 y80 w120 h20 vAlignText BackgroundTrans, Autoalign F3 (Off)

Gui, Add, Button, x10 y110 w70 h25 gShowBarRect, Bar
Gui, Add, Button, x90 y110 w70 h25 gShowMovementRect, Move
Gui, Add, Button, x170 y110 w70 h25 gShowGreenRect, Green

Gui, Add, Button, x10 y145 w80 h25 gStartMacro, Start (F5)
Gui, Add, Button, x100 y145 w80 h25 gStopMacro, Stop (F6)
Gui, Add, Button, x190 y145 w80 h25 gOpenEditGui, Edit
Gui, Add, Button, x280 y10 w80 h25 gCloseApp, Close

Gui, Show, x20 y20 w370 h200, Fishing Macro v1.6 by fearless9453

; Drag function
OnMessage(0x0201, "WM_LBUTTONDOWN")

return ; end Auto-Execute

; =========================
; CALLBACKS / LABELS
; =========================
WM_LBUTTONDOWN() {
    WinGet, winID, ID, A
    if (winID != WinExist("Fishing Macro v1.6 by fearless9453"))
        return
    PostMessage, 0xA1, 2,,, Fishing Macro v1.6 by fearless9453
}

CloseApp:
    ExitApp
return

; =========================
; GUI Helpers (overlays etc.)
; =========================
ToggleDebug:
    Gui, Submit, NoHide
    DebugMode := DebugCheckbox
    if (DebugMode)
        ShowNotification("Debug Mode: On")
    else
        ShowNotification("Debug Mode: Off")
return

ShowBarRect:
    BarRectShow := !BarRectShow
    if (BarRectShow)
        ShowRectangle("BarOverlay", BarRectX, BarRectY, BarRectW, BarRectH, "Red")
    else
        Gui, BarOverlay:Destroy
return

ShowMovementRect:
    MovementRectShow := !MovementRectShow
    if (MovementRectShow)
        ShowRectangle("MovementOverlay", MovementRectX, MovementRectY, MovementRectW, MovementRectH, "Blue")
    else
        Gui, MovementOverlay:Destroy
return

ShowGreenRect:
    GreenRectShow := !GreenRectShow
    if (GreenRectShow)
        ShowRectangle("GreenOverlay", GreenRectX, GreenRectY, GreenRectW, GreenRectH, "Green")
    else
        Gui, GreenOverlay:Destroy
return

; =========================
; Align Mode
; =========================
ToggleAlignMode()
{
    global AlignMode
    AlignMode := !AlignMode
    if (AlignMode) {
        GuiControl,, AlignText, F3 (On)
        ShowNotification("Align Mode: On")
        PerformAlign()
    } else {
        GuiControl,, AlignText, F3 (Off)
        ShowNotification("Align Mode: Off")
    }
}