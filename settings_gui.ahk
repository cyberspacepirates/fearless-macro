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

; Close edit GUI
CloseEditGui:
    if WinExist("Edit") {
        Gui, EditGui:Destroy
    }
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