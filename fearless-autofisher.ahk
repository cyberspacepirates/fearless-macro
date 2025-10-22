#NoEnv
#SingleInstance Force
; #Persistent

SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, variables.ahk

; =========================
; HELPERS
; =========================
GetHexNoPrefix(color) {
    if (color = "")
        return ""
    s := color
    if (s is number) {
        return Format("{:06X}", s & 0xFFFFFF)
    }
    StringReplace, s, s, #, , All
    StringLower, sLower, s
    if InStr(sLower, "0x") {
        pos := InStr(sLower, "0x")
        return SubStr(s, pos+2)
    }
    return s
}

#Include, settings.ahk

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

; -------------------------
; EDIT GUI (LARGER, Tabs: Areas | Colors | Webhook | General)
; keep the improved edit UI (larger) — user wanted that
; -------------------------
OpenEditGui:
    maxX := A_ScreenWidth - 1
    maxY := A_ScreenHeight - 1

    if WinExist("Edit") {
        WinActivate, Edit
        return
    }

    Gui, EditGui:New, +AlwaysOnTop +Resize, Edit
    Gui, Font, s10, Segoe UI

    ; Bigger tab control
    Gui, EditGui:Add, Tab, x10 y10 w740 h560 vEditTab, Areas|Colors|Webhook|General|Donate

    ; -------- Tab: Areas (was Rects) --------
    Gui, EditGui:Tab, Areas
    Gui, EditGui:Add, GroupBox, x12 y40 w360 h240, Bar Rect
    Gui, EditGui:Add, Text, x28 y70, X:
    Gui, EditGui:Add, Slider, x72 y68 w260 vBarRectX Range0-%maxX% TickInterval10 gUpdateRects, %BarRectX%
    Gui, EditGui:Add, Text, x340 y68 w60 h20 vBarRectXVal, %BarRectX%
    Gui, EditGui:Add, Text, x28 y100, Y:
    Gui, EditGui:Add, Slider, x72 y98 w260 vBarRectY Range0-%maxY% TickInterval10 gUpdateRects, %BarRectY%
    Gui, EditGui:Add, Text, x340 y98 w60 h20 vBarRectYVal, %BarRectY%

    Gui, EditGui:Add, GroupBox, x392 y40 w360 h240, Movement Rect
    Gui, EditGui:Add, Text, x408 y70, X:
    Gui, EditGui:Add, Slider, x452 y68 w260 vMovementRectX Range0-%maxX% TickInterval10 gUpdateRects, %MovementRectX%
    Gui, EditGui:Add, Text, x720 y68 w60 h20 vMovementRectXVal, %MovementRectX%
    Gui, EditGui:Add, Text, x408 y100, Y:
    Gui, EditGui:Add, Slider, x452 y98 w260 vMovementRectY Range0-%maxY% TickInterval10 gUpdateRects, %MovementRectY%
    Gui, EditGui:Add, Text, x720 y98 w60 h20 vMovementRectYVal, %MovementRectY%

    Gui, EditGui:Add, GroupBox, x12 y300 w740 h140, Green Rect
    Gui, EditGui:Add, Text, x28 y330, X:
    Gui, EditGui:Add, Slider, x72 y328 w640 vGreenRectX Range0-%maxX% TickInterval10 gUpdateRects, %GreenRectX%
    Gui, EditGui:Add, Text, x720 y328 w60 h20 vGreenRectXVal, %GreenRectX%
    Gui, EditGui:Add, Text, x28 y360, Y:
    Gui, EditGui:Add, Slider, x72 y358 w640 vGreenRectY Range0-%maxY% TickInterval10 gUpdateRects, %GreenRectY%
    Gui, EditGui:Add, Text, x720 y358 w60 h20 vGreenRectYVal, %GreenRectY%

    ; -------- Tab: Colors --------
    Gui, EditGui:Tab, Colors
    Gui, EditGui:Add, GroupBox, x12 y40 w740 h180, Colors / Variation
    fishHex := GetHexNoPrefix(FishColor)
    blockHex := GetHexNoPrefix(BlockColor)
    Gui, EditGui:Add, Text, x24 y70 w100, Fish Color:
    Gui, EditGui:Add, Edit, x130 y67 w160 vFishColorEdit, %fishHex%
    Gui, EditGui:Add, Button, x300 y67 w70 h26 gStartScreenPickerFish, Pick
    Gui, EditGui:Add, Text, x390 y70 w100, Block Color:
    Gui, EditGui:Add, Edit, x500 y67 w160 vBlockColorEdit, %blockHex%
    Gui, EditGui:Add, Button, x670 y67 w70 h26 gStartScreenPickerBlock, Pick

    Gui, EditGui:Add, Text, x24 y110 w120, Variation:
    Gui, EditGui:Add, Slider, x130 y108 w600 vVariation Range0-255 TickInterval5 gUpdateRects, %Variation%
    Gui, EditGui:Add, Text, x740 y108 w60 h20 vVariationVal, %Variation%

    ; small helper (english)
    Gui, EditGui:Add, Text, x12 y140 w740 h18 cGray BackgroundTrans, Tip: Use "Pick" to select a color from the screen (confirm with Middle Mouse).

    ; -------- Tab: Webhook --------
    Gui, EditGui:Tab, Webhook
    Gui, EditGui:Add, GroupBox, x12 y40 w740 h160, Discord Webhook
    Gui, EditGui:Add, Checkbox, x24 y72 w260 h22 vWebhookEnabled gToggleWebhook, Enable Webhook
    Gui, EditGui:Add, Text, x24 y100 w80, Webhook URL:
    Gui, EditGui:Add, Edit, x110 y97 w620 h26 vWebhookURLEdit, %WebhookURL%
    Gui, EditGui:Add, Text, x24 y135 w80, Ping UserID:
    Gui, EditGui:Add, Edit, x110 y132 w260 h22 vPingUserIDEdit, %PingUserID%
    Gui, EditGui:Add, Button, x390 y130 w120 h26 gTestWebhook, Test
    Gui, EditGui:Add, Text, x24 y165 w720 h30 cGray BackgroundTrans, Enter full webhook URL. UserID optional.

    ; -------- Tab: General --------
    Gui, EditGui:Tab, General
    Gui, EditGui:Add, GroupBox, x12 y40 w740 h120, General
    Gui, EditGui:Add, Text, x24 y72 w160, Max Runs (stop):
    Gui, EditGui:Add, Edit, x200 y69 w120 h24 vMaxRunsEdit, %MaxRuns%
    ; removed long note for brevity

    ; -------- Tab: Donate --------
    Gui, EditGui:Tab, Donate
    Gui, EditGui:Add, GroupBox, x12 y40 w740 h120, Roblox Donate

    Gui, EditGui:Add, Text, x24 y70 w160, Choose amount:
    Gui, EditGui:Add, DropDownList, x200 y67 w160 h100 vDonateChoice, 50 Robux|100 Robux|250 Robux|500 Robux
    Gui, EditGui:Add, Button, x380 y67 w100 h24 gDonateNow, Donate

    ; klickbarer Discord-Text (öffnet den im Script verankerten DiscordLink)
    Gui, EditGui:Add, Text, x24 y102 w120 h24 cBlue gOpenDiscord, Discord

    ; -------- Buttons (bottom) --------
    Gui, EditGui:Tab
    Gui, EditGui:Add, Button, x60 y520 w160 h32 gSaveRects, Save
    Gui, EditGui:Add, Button, x310 y520 w160 h32 gRestoreDefaults, Restore Defaults
    Gui, EditGui:Add, Button, x560 y520 w160 h32 gCloseEditGui, Close

    ; --- Sync control values with loaded variables so they remain visible after close/open ---
    GuiControl,, WebhookURLEdit, %WebhookURL%
    GuiControl,, PingUserIDEdit, %PingUserID%
    GuiControl,, WebhookEnabled, % (WebhookEnabled ? 1 : 0)
    GuiControl,, MaxRunsEdit, %MaxRuns%
    GuiControl,, FishColorEdit, % GetHexNoPrefix(FishColor)
    GuiControl,, BlockColorEdit, % GetHexNoPrefix(BlockColor)
    GuiControl,, Variation, %Variation%
    GuiControl,, VariationVal, %Variation%
    GuiControl,, BarRectXVal, %BarRectX%
    GuiControl,, BarRectYVal, %BarRectY%
    GuiControl,, MovementRectXVal, %MovementRectX%
    GuiControl,, MovementRectYVal, %MovementRectY%
    GuiControl,, GreenRectXVal, %GreenRectX%
    GuiControl,, GreenRectYVal, %GreenRectY%

    ; --- Show GUI ---
    Gui, EditGui:Show, w760 h580
return

; öffnet den festen Discord-Link
OpenDiscord:
    if (DiscordLink = "") {
        ShowNotification("Discord-Link nicht gesetzt (im Script).")
        return
    }
    Run, %DiscordLink%
return

DonateNow:
    ; Stelle sicher, dass die GUI-Werte übernommen werden
    Gui, EditGui:Submit, NoHide

    ; Versuche die Auswahl direkt zu lesen
    sel := DonateChoice
    if (sel = "") {
        ; Fallback: explizit aus dem Control holen
        GuiControlGet, sel, , DonateChoice
    }

    if (sel = "") {
        sel := "50 Robux" ; Default falls wirklich leer
    }

    ; Zahl extrahieren (50/100/250/500)
    RegExMatch(sel, "(\d+)", m)
    amt := m1
    if (!amt)
        amt := "50"

    ; entsprechende fest verankerte URL auswählen
    url := ""
    if (amt = "50")
        url := DonateURL50
    else if (amt = "100")
        url := DonateURL100
    else if (amt = "250")
        url := DonateURL250
    else if (amt = "500")
        url := DonateURL500

    if (url = "") {
        ShowNotification("Keine Donate-URL für " amt " Robux gesetzt (im Script).")
        return
    }

    ; {amount} ersetzen, falls vorhanden (optional)
    if InStr(url, "{amount}") {
        StringReplace, url, url, {amount}, %amt%, All
    }

    ; Debug (optional): entferne die 2 Zeilen, wenn sie stören
    ; ShowNotification("Auswahl: " sel " | Betrag: " amt)

    Run, %url%
    ShowNotification("Öffne Donate-Link (" amt " Robux)...")
return

; =========================
; Webhook UI callbacks
; =========================
ToggleWebhook:
    Gui, EditGui:Submit, NoHide
    WebhookURL := WebhookURLEdit
    PingUserID := PingUserIDEdit
    WebhookEnabled := (WebhookEnabled ? true : false)

    if (WebhookURL != "") {
        if (WebhookEnabled) {
            SendDiscordWebhookRateLimited("Webhook enabled: Fishing Macro is now online.", false)
            ShowNotification("Webhook enabled (message sent)")
        } else {
            SendDiscordWebhookRateLimited("Webhook disabled: Fishing Macro is now offline.", false)
            ShowNotification("Webhook disabled (message sent)")
        }
    } else {
        ShowNotification("Webhook URL missing - message not sent")
    }
return

TestWebhook:
    Gui, EditGui:Submit, NoHide
    WebhookURL := WebhookURLEdit
    PingUserID := PingUserIDEdit
    if (WebhookURL = "") {
        ShowNotification("Test failed: Webhook URL missing.")
        return
    }
    SendDiscordWebhookRateLimited("Test message from Fishing Macro. If this should ping someone, check the UserID.", true)
    ShowNotification("Test webhook sent.")
return

; =========================
; Screen Picker (confirm with Middle Button)
; =========================
StartScreenPicker(kind)
{
    global
    Gui, Picker:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Picker:Margin, 0, 0
    Gui, Picker:Add, Text, vPickerHex c000000 w80 h16 Center,
    Gui, Picker:Show, w80 h80, Picker
    WinSet, ExStyle, +0x20, Picker
    WinSet, Transparent, Off, Picker

    Loop {
        MouseGetPos, mx, my
        PixelGetColor, col, mx, my, RGB
        col := col & 0xFFFFFF
        hex := Format("{:06X}", col)

        Gui, Picker:Color, 0x%hex%
        GuiControl,, PickerHex, #%hex%

        if WinExist("Edit") {
            Gui, EditGui:Default
            if (kind = "Fish") {
                FishColor := "0x" . hex
                GuiControl,, FishColorEdit, %hex%
            } else {
                BlockColor := "0x" . hex
                GuiControl,, BlockColorEdit, %hex%
            }
        }

        px := mx + 16
        py := my + 16
        if (px + 80 > A_ScreenWidth)
            px := mx - 96
        if (py + 80 > A_ScreenHeight)
            py := my - 96
        Gui, Picker:Show, x%px% y%py% w80 h80, Picker

        if GetKeyState("MButton", "P") {
            sel := "0x" . hex
            infoText := "Picked: #" . hex . " @ " . mx . "," . my
            ShowNotification(infoText)
            break
        }
        if GetKeyState("Esc", "P") {
            ShowNotification("Picker aborted")
            break
        }
        Sleep, 20
    }

    Gui, Picker:Destroy
}

StartScreenPickerFish:
    StartScreenPicker("Fish")
return

StartScreenPickerBlock:
    StartScreenPicker("Block")
return

; -------------------------
; UpdateRects: update live numbers
; -------------------------
UpdateRects:
    Gui, EditGui:Submit, NoHide
    GuiControlGet, tmpF, , FishColorEdit
    tmpF := RegExReplace(tmpF, "[^0-9A-Fa-f]", "")
    if (tmpF != "")
        FishColor := "0x" . tmpF
    GuiControlGet, tmpB, , BlockColorEdit
    tmpB := RegExReplace(tmpB, "[^0-9A-Fa-f]", "")
    if (tmpB != "")
        BlockColor := "0x" . tmpB
    GuiControlGet, tmpV, , Variation
    if (tmpV != "")
        Variation := tmpV + 0
    GuiControl,, BarRectXVal, %BarRectX%
    GuiControl,, BarRectYVal, %BarRectY%
    GuiControl,, MovementRectXVal, %MovementRectX%
    GuiControl,, MovementRectYVal, %MovementRectY%
    GuiControl,, GreenRectXVal, %GreenRectX%
    GuiControl,, GreenRectYVal, %GreenRectY%
    GuiControl,, VariationVal, %Variation%
    if (BarRectShow) {
        Gui, BarOverlay:Destroy
        ShowRectangle("BarOverlay", BarRectX, BarRectY, BarRectW, BarRectH, "Red")
    }
    if (MovementRectShow) {
        Gui, MovementOverlay:Destroy
        ShowRectangle("MovementOverlay", MovementRectX, MovementRectY, MovementRectW, MovementRectH, "Blue")
    }
    if (GreenRectShow) {
        Gui, GreenOverlay:Destroy
        ShowRectangle("GreenOverlay", GreenRectX, GreenRectY, GreenRectW, GreenRectH, "Green")
    }
return

; Save: write values to rects.ini (including colors/variation + webhook + MaxRuns)
SaveRects:
    Gui, EditGui:Submit, NoHide
    IniWrite, %BarRectX%, rects.ini, Bar, X
    IniWrite, %BarRectY%, rects.ini, Bar, Y
    IniWrite, %BarRectW%, rects.ini, Bar, W
    IniWrite, %BarRectH%, rects.ini, Bar, H
    IniWrite, %MovementRectX%, rects.ini, Movement, X
    IniWrite, %MovementRectY%, rects.ini, Movement, Y
    IniWrite, %MovementRectW%, rects.ini, Movement, W
    IniWrite, %MovementRectH%, rects.ini, Movement, H
    IniWrite, %GreenRectX%, rects.ini, Green, X
    IniWrite, %GreenRectY%, rects.ini, Green, Y
    IniWrite, %GreenRectW%, rects.ini, Green, W
    IniWrite, %GreenRectH%, rects.ini, Green, H
    f := GetHexNoPrefix(FishColor)
    b := GetHexNoPrefix(BlockColor)
    IniWrite, %f%, rects.ini, Colors, Fish
    IniWrite, %b%, rects.ini, Colors, Block
    IniWrite, %Variation%, rects.ini, Colors, Variation
    WebhookURL := WebhookURLEdit
    PingUserID := PingUserIDEdit
    enabledVal := WebhookEnabled ? 1 : 0
    IniWrite, %WebhookURL%, rects.ini, Webhook, URL
    IniWrite, %PingUserID%, rects.ini, Webhook, PingUserID
    IniWrite, %enabledVal%, rects.ini, Webhook, Enabled

    ; MaxRuns save (validate)
    GuiControlGet, tmpMax, , MaxRunsEdit
    tmpMax := tmpMax + 0
    if (tmpMax <= 0)
        tmpMax := DefaultMaxRuns
    MaxRuns := tmpMax
    IniWrite, %MaxRuns%, rects.ini, General, MaxRuns

    ShowNotification("Position & Color saved (rects.ini)!")
return

; Restore Defaults: reset values, write INI, update GUI + overlays
RestoreDefaults:
    BarRectX := DefaultBarRectX
    BarRectY := DefaultBarRectY
    BarRectW := DefaultBarRectW
    BarRectH := DefaultBarRectH
    MovementRectX := DefaultMovementRectX
    MovementRectY := DefaultMovementRectY
    MovementRectW := DefaultMovementRectW
    MovementRectH := DefaultMovementRectH
    GreenRectX := DefaultGreenRectX
    GreenRectY := DefaultGreenRectY
    GreenRectW := DefaultGreenRectW
    GreenRectH := DefaultGreenRectH
    FishColor := DefaultFishColor
    BlockColor := DefaultBlockColor
    Variation := DefaultVariation
    MaxRuns := DefaultMaxRuns

    ; Reset webhook & counters to defaults
    WebhookEnabled := false
    WebhookURL := ""
    PingUserID := ""
    ConsecutiveNoGreen := 0
    WebhookNoGreenEvents := 0
    TotalRuns := 0

    IniWrite, %BarRectX%, rects.ini, Bar, X
    IniWrite, %BarRectY%, rects.ini, Bar, Y
    IniWrite, %BarRectW%, rects.ini, Bar, W
    IniWrite, %BarRectH%, rects.ini, Bar, H
    IniWrite, %MovementRectX%, rects.ini, Movement, X
    IniWrite, %MovementRectY%, rects.ini, Movement, Y
    IniWrite, %MovementRectW%, rects.ini, Movement, W
    IniWrite, %MovementRectH%, rects.ini, Movement, H
    IniWrite, %GreenRectX%, rects.ini, Green, X
    IniWrite, %GreenRectY%, rects.ini, Green, Y
    IniWrite, %GreenRectW%, rects.ini, Green, W
    IniWrite, %GreenRectH%, rects.ini, Green, H
    IniWrite, % GetHexNoPrefix(FishColor), rects.ini, Colors, Fish
    IniWrite, % GetHexNoPrefix(BlockColor), rects.ini, Colors, Block
    IniWrite, %Variation%, rects.ini, Colors, Variation
    IniWrite, %MaxRuns%, rects.ini, General, MaxRuns

    ; Write webhook defaults to INI as well
    IniWrite, %WebhookURL%, rects.ini, Webhook, URL
    IniWrite, %PingUserID%, rects.ini, Webhook, PingUserID
    IniWrite, % (WebhookEnabled ? 1 : 0), rects.ini, Webhook, Enabled

    if WinExist("Edit") {
        GuiControl,, BarRectX, %BarRectX%
        GuiControl,, BarRectY, %BarRectY%
        GuiControl,, MovementRectX, %MovementRectX%
        GuiControl,, MovementRectY, %MovementRectY%
        GuiControl,, GreenRectX, %GreenRectX%
        GuiControl,, GreenRectY, %GreenRectY%
        GuiControl,, BarRectXVal, %BarRectX%
        GuiControl,, BarRectYVal, %BarRectY%
        GuiControl,, MovementRectXVal, %MovementRectX%
        GuiControl,, MovementRectYVal, %MovementRectY%
        GuiControl,, GreenRectXVal, %GreenRectX%
        GuiControl,, GreenRectYVal, %GreenRectY%
        GuiControl,, FishColorEdit, % GetHexNoPrefix(FishColor)
        GuiControl,, BlockColorEdit, % GetHexNoPrefix(BlockColor)
        GuiControl,, Variation, %Variation%
        GuiControl,, VariationVal, %Variation%
        GuiControl,, WebhookURLEdit, %WebhookURL%
        GuiControl,, PingUserIDEdit, %PingUserID%
        GuiControl,, WebhookEnabled, % (WebhookEnabled ? 1 : 0)
        GuiControl,, MaxRunsEdit, %MaxRuns%
    }
    if (BarRectShow) {
        Gui, BarOverlay:Destroy
        ShowRectangle("BarOverlay", BarRectX, BarRectY, BarRectW, BarRectH, "Red")
    }
    if (MovementRectShow) {
        Gui, MovementOverlay:Destroy
        ShowRectangle("MovementOverlay", MovementRectX, MovementRectY, MovementRectW, MovementRectH, "Blue")
    }
    if (GreenRectShow) {
        Gui, GreenOverlay:Destroy
        ShowRectangle("GreenOverlay", GreenRectX, GreenRectY, GreenRectW, GreenRectH, "Green")
    }
    ShowNotification("Default settings saved.")
return

; Close edit GUI
CloseEditGui:
    if WinExist("Edit") {
        Gui, EditGui:Destroy
    }
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
; Hotkeys
; =========================
F5:: StartMacro()
F6:: StopMacro()
F3:: ToggleAlignMode()

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

PerformAlign()
{
    global CurrentStatus
    CurrentStatus := "Align Mode: Scrolling..."
    GuiControl,, CurrentStatusText, %CurrentStatus%
    Loop, 100 {
        Send, {WheelUp}
        Sleep, 10
    }
    Sleep, 600
    Loop, 10 {
        Send, {WheelDown}
        Sleep, 50
    }
    CurrentStatus := "Align completed"
    GuiControl,, CurrentStatusText, %CurrentStatus%
}

; =========================
; MAIN LOOP + Steps
; =========================
MainLoop:
    if (!MacroActive || !LoopActive)
        return
    ; heartbeat: mark that the MainLoop executed
    LastMainLoopTick := A_TickCount
    UpdateRectPositions()
    if (CurrentStep = 1)
        Step1_WaitForGreen()
    else if (CurrentStep = 2)
        Step2_WaitForMovement()
    else if (CurrentStep = 3)
        Step3_TrackFish()
    else if (CurrentStep = 4)
        Step4_Wait()
return

StartMacro()
{
    global MacroActive, LoopActive, CurrentStep, Step3_NoSignalTicks, CurrentStatus, Holding, TotalRuns
    global LastMainLoopTick, WatchdogRetries, WatchdogIntervalMs
    MacroActive := true
    LoopActive := true
    CurrentStep := 1
    Step3_NoSignalTicks := 0
    TotalRuns := 0            ; reset on start
    CurrentStatus := "Macro running..."
    GuiControl,, StatusText, On
    GuiControl,, CurrentStatusText, %CurrentStatus%
    ShowNotification("Fishing Macro: On")
    ; send webhook notification about start (rate-limited)
    SendDiscordWebhookRateLimited("Fishing Macro: Started.", false)
    Send {LButton Up}
    Holding := false
    LastMainLoopTick := A_TickCount
    WatchdogRetries := 0
    SetTimer, MainLoop, 50
    ; start watchdog timer (runs every WatchdogIntervalMs)
    SetTimer, MainLoopWatchdog, %WatchdogIntervalMs%
}

StopMacro()
{
    global MacroActive, LoopActive, CurrentStatus, Holding, TotalRuns
    MacroActive := false
    LoopActive := false
    CurrentStep := 1
    CurrentStatus := "Macro stopped..."
    GuiControl,, StatusText, Off
    GuiControl,, CurrentStatusText, %CurrentStatus%
    ShowNotification("Fishing Macro: Off")
    ; send webhook notification about stop (rate-limited)
    SendDiscordWebhookRateLimited("Fishing Macro: Stopped.", false)
    Send {LButton Up}
    Holding := false
    SetTimer, MainLoop, Off
    SetTimer, MainLoopWatchdog, Off
    ToolTip
    TotalRuns := 0    ; reset on stop
}

; =========================
; Step implementations
; =========================
Step1_WaitForGreen()
{
    global CurrentStatus, GreenRectX, GreenRectY, GreenRectW, GreenRectH, DebugMode, CurrentStep, Holding
    global ConsecutiveNoGreen, WebhookNoGreenEvents
    static entryTime := 0
    static firstRun := true
    if (entryTime = 0) {
        entryTime := A_TickCount
        firstRun := true
    }
    if (firstRun) {
        Send, 5
        Sleep, 300
        Send, 5
        firstRun := false
    }
    CurrentStatus := "Step 1: Waiting for green in green rect..."
    GuiControl,, CurrentStatusText, %CurrentStatus%
    x1 := GreenRectX
    y1 := GreenRectY
    x2 := GreenRectX + GreenRectW
    y2 := GreenRectY + GreenRectH
    PixelSearch, Px, Py, %x1%, %y1%, %x2%, %y2%, 0x00FF00, 50, Fast RGB
    if (ErrorLevel = 0) {
        if (Holding) {
            Send {LButton Up}
            Holding := false
            if (DebugMode)
                ShowNotification("Step1: Released LButton (green found)")
        }
        ConsecutiveNoGreen := 0
        CurrentStep := 2
        entryTime := 0
        firstRun := true
        return
    } else {
        if (!Holding) {
            Send {LButton Down}
            Holding := true
            if (DebugMode)
                ShowNotification("Step1: Sending LButton down")
        }
    }
    if ((A_TickCount - entryTime) > 5000) {
        if (DebugMode)
            ShowNotification("Step 1: Timeout after 5s, restarting loop")
        CurrentStep := 1
        entryTime := 0
        firstRun := true
        if (Holding) {
            Send {LButton Up}
            Holding := false
            if (DebugMode)
                ShowNotification("Step1: Released LButton (timeout)")
        }
        ConsecutiveNoGreen += 1
        if (DebugMode)
            ShowNotification("ConsecutiveNoGreen: " . ConsecutiveNoGreen)
        if (ConsecutiveNoGreen >= 10) {
            ; send the 10x webhook (rate-limited)
            SendDiscordWebhookRateLimited("Error: Step 1 failed to detect green 10 times in a row!", true)
            ShowNotification("Webhook: 10x no green detected (sent)")
            ; count that we sent this webhook once more
            WebhookNoGreenEvents += 1
            ; reset the consecutive counter so we start counting again
            ConsecutiveNoGreen := 0

            ; if we've sent that webhook twice, stop the macro
            if (WebhookNoGreenEvents >= 2) {
                SendDiscordWebhookRateLimited("Error: Step 1 failed to detect green 10 times in a row twice. Macro stopped.", true)
                ShowNotification("Macro stopped: 2x 10x-no-green events (webhook sent)")
                ; reset event counter (optional)
                WebhookNoGreenEvents := 0
                StopMacro()
                return
            }
        }
    }
}


Step2_WaitForMovement()
{
    global CurrentStatus, MovementRectX, MovementRectY, MovementRectW, MovementRectH
    global DebugMode, CurrentStep, Step3_EntryTime, Holding

    static entryTime := 0

    ; initial setup when we first enter Step 2
    if (entryTime = 0) {
        entryTime := A_TickCount
        if (DebugMode)
            ShowNotification("Step2: entered (non-blocking mode)")
    }

    CurrentStatus := "Step 2: Waiting for exclamation mark..."
    GuiControl,, CurrentStatusText, %CurrentStatus%

    x1 := MovementRectX
    y1 := MovementRectY
    x2 := MovementRectX + MovementRectW
    y2 := MovementRectY + MovementRectH

    ; Try a single ImageSearch per invocation (non-blocking)
    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, *40 Red.png
    if (ErrorLevel = 0) {
        ; found: ensure LButton released, click, go to step 3
        if (Holding) {
            Send {LButton Up}
            Holding := false
            if (DebugMode)
                ShowNotification("Step2: Released LButton before coordinate click")
        }
        Sleep, 50
        Click, %FoundX%, %FoundY%
        CurrentStep := 3
        Step3_EntryTime := A_TickCount
        entryTime := 0            ; reset for next time we come here later
        if (DebugMode)
            ShowNotification("Step 2 -> 3: Exclamation detected! (Step3 timer started)")
        return
    }

    ; check timeout (non-blocking)
    elapsed := A_TickCount - entryTime
    if (elapsed > 20000) {
        ; timeout reached: release button if held, send english webhook ping, go back to step 1
        if (DebugMode)
            ShowNotification("Step2: Timeout 20s reached - restarting loop and sending webhook (if enabled)")
        if (Holding) {
            Send {LButton Up}
            Holding := false
        }

        ; Send english webhook; wrapper will respect rate-limit
        SendDiscordWebhookRateLimited("Warning: Step 2 timed out after 20 seconds. Restarting loop.", true)

        CurrentStep := 1
        entryTime := 0
        Step3_EntryTime := 0
        return
    }

    ; otherwise do nothing else this tick (allow MainLoop timer to call again)
    return
}



Step3_TrackFish()
{
    global BarRectX, BarRectY, BarRectW, BarRectH
    global FishColor, BlockColor, Variation
    global DebugMode, CurrentStatus, Step3_EntryTime, CurrentStep, Holding
    MaxDurationMs := 9000
    if (!Step3_EntryTime)
        Step3_EntryTime := A_TickCount
    elapsed := A_TickCount - Step3_EntryTime
    CurrentStatus := "Step 3: Tracking fish... (" . Round(elapsed/1000,1) . "s)"
    GuiControl,, CurrentStatusText, %CurrentStatus%
    if (elapsed >= MaxDurationMs) {
        if (DebugMode)
            ShowNotification("Step 3 -> 4: Timeout after 9s reached")
        if (Holding)
        {
            Send {LButton Up}
            Holding := false
        }
        Step3_EntryTime := 0
        CurrentStep := 4
        return
    }
    x1 := BarRectX
    y1 := BarRectY
    x2 := BarRectX + BarRectW
    y2 := BarRectY + BarRectH
    PixelSearch, FishX, FishY, %x1%, %y1%, %x2%, %y2%, %FishColor%, %Variation%, RGB Fast
    FischGefunden := (ErrorLevel = 0)
    PixelSearch, BlockX, BlockY, %x1%, %y1%, %x2%, %y2%, %BlockColor%, %Variation%, RGB Fast
    BlockGefunden := (ErrorLevel = 0)
    if (FischGefunden && BlockGefunden) {
        if (FishX > BlockX) {
            if (!Holding)
            {
                Send {LButton Down}
                Holding := true
            }
        } else {
            if (Holding)
            {
                Send {LButton Up}
                Holding := false
            }
        }
    } else if (FischGefunden) {
        if (!Holding)
        {
            Send {LButton Down}
            Holding := true
        }
    } else {
        if (Holding)
        {
            Send {LButton Up}
            Holding := false
        }
    }
    if (DebugMode) {
        tooltipText := "Fish:" . (FischGefunden ? FishX : "n/a")
                    . " | Block:" . (BlockGefunden ? BlockX : "n/a")
                    . " | elapsed:" . Round(elapsed/1000,1) . "s"
                    . " | Holding:" . (Holding ? "1" : "0")
        ToolTip, %tooltipText%, 10, 10
    }
}

Step4_Wait()
{
    global CurrentStatus, CurrentStep, Holding
    global TotalRuns, DebugMode, MaxRuns
    static start := 0
    static sentAt1 := false
    static sentAt16 := false

    ; Timing (ms)
    PressTime1 := 1000    ; 1.0s
    PressTime2 := 1600    ; 1.6s
    TotalWait := 3000     ; insgesamt 3.0s bevor wir zurücksetzen

    if (!start) {
        start := A_TickCount
        sentAt1 := false
        sentAt16 := false
        CurrentStatus := "Step 4: Waiting..."
        GuiControl,, CurrentStatusText, %CurrentStatus%
    }

    elapsed := A_TickCount - start
    CurrentStatus := "Step 4: Waiting... " . Round(elapsed / 1000, 1) . "s"
    GuiControl,, CurrentStatusText, %CurrentStatus%

    ; erste 5 bei ~1.0s
    if (elapsed >= PressTime1 && !sentAt1) {
        if (Holding) {
            Send {LButton Up}
            Holding := false
        }
        Send, 5
        Sleep, 20    ; kurzes Pauschen damit der Tastendruck sauber registriert wird
        sentAt1 := true
        if (DebugMode)
            ShowNotification("Step4: Sent first 5 (1.0s)")
    }

    ; zweite 5 bei ~1.6s
    if (elapsed >= PressTime2 && !sentAt16) {
        if (Holding) {
            Send {LButton Up}
            Holding := false
        }
        Send, 5
        Sleep, 20
        sentAt16 := true
        if (DebugMode)
            ShowNotification("Step4: Sent second 5 (1.6s)")
    }

    ; nach TotalWait zurücksetzen und Run zählen
    if (elapsed >= TotalWait) {
        start := 0
        sentAt1 := false
        sentAt16 := false
        CurrentStep := 1
        TotalRuns += 1
        if (DebugMode)
            ShowNotification("TotalRuns: " . TotalRuns)

        if (Mod(TotalRuns, 20) == 0) {
            SendDiscordWebhookRateLimited("Info: " . TotalRuns . " runs completed.", false)
            ShowNotification("Webhook: " . TotalRuns . " runs completed (sent)")
        }

        if (TotalRuns >= MaxRuns) {
            SendDiscordWebhookRateLimited("Stopped: Out of baits. Please buy more.", true)
            ShowNotification("Stopped: Out of baits. Please buy more. (webhook sent)")
            StopMacro()
            return
        }
    }
}


; =========================
; Detection / Helpers
; =========================
DetectGreen(x, y, w, h)
{
    x2 := x + w
    y2 := y + h
    PixelSearch, px, py, %x%, %y%, %x2%, %y2%, 0x00FF00, 50, Fast
    return !ErrorLevel
}

DetectMovement(x, y, w, h)
{
    static lastColor := 0
    PixelGetColor, color, %x%, %y%, RGB
    if (lastColor != 0 && Abs(color - lastColor) > 5000)
    {
        lastColor := color
        return true
    }
    lastColor := color
    return false
}

ShowRectangle(name, x, y, w, h, color)
{
    Gui, %name%:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, %name%:Color, %color%
    WinSet, Transparent, 100
    Gui, %name%:Show, x%x% y%y% w%w% h%h%, %name%
}

; =========================
; Notification helper
; =========================
ShowNotification(message)
{
    x := (A_ScreenWidth // 2)
    y := 20
    ToolTip, %message%, %x%, %y%
    SetTimer, ClearNotification, -2000
}

ClearNotification:
    ToolTip
return

UpdateRectPositions()
{
    return
}

; =========================
; Discord Webhook Function (text)
; =========================
SendDiscordWebhook(message, mentionUser := false)
{
    global WebhookEnabled, WebhookURL, PingUserID
    if (!WebhookEnabled) {
        return false
    }
    if (WebhookURL = "") {
        return false
    }

    ; === Date & time prefix
    FormatTime, now, %A_Now%, yyyy-MM-dd HH:mm:ss
    contentStr := "[" . now . "] " . message

    if (mentionUser && PingUserID != "") {
        contentStr := "<@" . PingUserID . "> " . contentStr
    }

    escapedQuote := Chr(92) . Chr(34)
    SafeContent := StrReplace(contentStr, Chr(34), escapedQuote)
    json := "{""content"":""" . SafeContent . """" 
    if (mentionUser && PingUserID != "") {
        json .= ",""allowed_mentions"":{""users"": [""" . PingUserID . """]}"
    }
    json .= "}"
    try {
        req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        req.Open("POST", WebhookURL, false)
        req.SetRequestHeader("Content-Type", "application/json")
        req.Send(json)
        status := req.Status + 0
        if (status = 204 || status = 200) {
            return true
        } else {
            ; log error to file for debugging
            try {
                FormatTime, ts, %A_Now%, yyyy-MM-dd HH:mm:ss
                FileAppend, % "[" ts "] Webhook HTTP " status " - " message "`n", %A_ScriptDir%\webhook_errors.log
            } catch {}
            return false
        }
    } catch e {
        try {
            FormatTime, ts2, %A_Now%, yyyy-MM-dd HH:mm:ss
            FileAppend, % "[" ts2 "] Webhook exception: " e.Message " - " message "`n", %A_ScriptDir%\webhook_errors.log
        } catch {}
        return false
    }
}

; rate-limited wrapper to avoid spamming discord
SendDiscordWebhookRateLimited(message, mentionUser := false) {
    global LastWebhookTime, WebhookMinIntervalMs
    now := A_TickCount
    if ((now - LastWebhookTime) < WebhookMinIntervalMs) {
        ; suppressed due to rate limit; still log
        try {
            FormatTime, ts, %A_Now%, yyyy-MM-dd HH:mm:ss
            FileAppend, % "[" ts "] Webhook suppressed (rate limit): " . message . "`n", %A_ScriptDir%\webhook_errors.log
        } catch {}
        return false
    }
    ok := SendDiscordWebhook(message, mentionUser)
    if (ok)
        LastWebhookTime := now
    return ok
}

; Helper: checks if variable is set (for Debug)
IsSetVar(name) {
    return (IsByRef(name) || (name != "" && VarSetCapacity(name) >= 0))
}

; =========================
; Watchdog handler
; - checks if MainLoop still ticks; if stale, attempt graceful restart
; - send rate-limited webhook on recovery attempts; stop after max retries
; =========================
MainLoopWatchdog:
    global LastMainLoopTick, MacroActive, WatchdogRetries, WatchdogMaxRetries
    global WatchdogStaleThresholdMs, WatchdogLogFile, WatchdogIntervalMs
    if (!MacroActive)
        return
    now := A_TickCount
    diff := now - LastMainLoopTick
    ; healthy if MainLoop ticked within stale threshold
    if (diff < WatchdogStaleThresholdMs) {
        WatchdogRetries := 0
        return
    }

    ; stale detected
    WatchdogRetries += 1
    FormatTime, ts, %A_Now%, yyyy-MM-dd HH:mm:ss
    try {
        FileAppend, % "[" ts "] Watchdog: MainLoop stale for " diff " ms - attempt " WatchdogRetries "`n", %WatchdogLogFile%
    } catch {}

    ShowNotification("Watchdog: MainLoop stale (" diff "ms). Attempting restart.")
    ; rate-limited webhook
    SendDiscordWebhookRateLimited("Warning: Watchdog detected stale main loop (" diff " ms). Attempting graceful restart.", true)

    ; attempt graceful recovery: release button, stop & start macro
    ; ensure LButton released to avoid stuck input
    Send {LButton Up}
    Sleep, 150
    ; try restart sequence
    StopMacro()
    Sleep, 500
    StartMacro()
    Sleep, 1000

    ; after restart, check if MainLoop recovered quickly (allow next watchdog tick to verify)
    if (WatchdogRetries >= WatchdogMaxRetries) {
        FormatTime, ts2, %A_Now%, yyyy-MM-dd HH:mm:ss
        try {
            FileAppend, % "[" ts2 "] Watchdog: max retries reached (" WatchdogRetries ") - stopping macro.`n", %WatchdogLogFile%
        } catch {}
        ShowNotification("Watchdog: failed to recover - macro stopped.")
        SendDiscordWebhookRateLimited("Error: Watchdog unable to recover after " WatchdogRetries " attempts. Macro stopped.", true)
        StopMacro()
        WatchdogRetries := 0
    }
return

; End of script
