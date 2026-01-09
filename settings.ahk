; =========================
; Load INI (robust) + Webhook section + General
; =========================
if FileExist("rects.ini") {
    IniRead, tmp, rects.ini, Bar, X
    if (tmp != "")       BarRectX := tmp
    IniRead, tmp, rects.ini, Bar, Y
    if (tmp != "")       BarRectY := tmp
    IniRead, tmp, rects.ini, Bar, W
    if (tmp != "")       BarRectW := tmp
    IniRead, tmp, rects.ini, Bar, H
    if (tmp != "")       BarRectH := tmp

    IniRead, tmp, rects.ini, Movement, X
    if (tmp != "")       MovementRectX := tmp
    IniRead, tmp, rects.ini, Movement, Y
    if (tmp != "")       MovementRectY := tmp
    IniRead, tmp, rects.ini, Movement, W
    if (tmp != "")       MovementRectW := tmp
    IniRead, tmp, rects.ini, Movement, H
    if (tmp != "")       MovementRectH := tmp

    IniRead, tmp, rects.ini, Green, X
    if (tmp != "")       GreenRectX := tmp
    IniRead, tmp, rects.ini, Green, Y
    if (tmp != "")       GreenRectY := tmp
    IniRead, tmp, rects.ini, Green, W
    if (tmp != "")       GreenRectW := tmp
    IniRead, tmp, rects.ini, Green, H
    if (tmp != "")       GreenRectH := tmp

    IniRead, tmp, rects.ini, Colors, Fish
    if (tmp != "") {
        tmp := Trim(tmp)
        StringReplace, tmp, tmp, #, , All
        if InStr(tmp, "0x")
            FishColor := tmp
        else
            FishColor := "0x" . tmp
    }
    IniRead, tmp, rects.ini, Colors, Block
    if (tmp != "") {
        tmp := Trim(tmp)
        StringReplace, tmp, tmp, #, , All
        if InStr(tmp, "0x")
            BlockColor := tmp
        else
            BlockColor := "0x" . tmp
    }
    IniRead, tmp, rects.ini, Colors, Variation
    if (tmp != "") {
        Variation := tmp + 0
    }

    ; Webhook settings
    IniRead, tmp, rects.ini, Webhook, Enabled
    if (tmp != "") {
        WebhookEnabled := (tmp = "1")
    }
    IniRead, tmp, rects.ini, Webhook, URL
    if (tmp != "") {
        WebhookURL := tmp
    }
    IniRead, tmp, rects.ini, Webhook, PingUserID
    if (tmp != "") {
        PingUserID := tmp
    }

    ; General settings (MaxRuns etc.)
    IniRead, tmp, rects.ini, General, MaxRuns
    if (tmp != "") {
        MaxRuns := tmp + 0
        if (MaxRuns <= 0)
            MaxRuns := DefaultMaxRuns
    }

    ; optionally allow overriding watchdog/interval via INI (optional)
    IniRead, tmp, rects.ini, General, WatchdogIntervalMs
    if (tmp != "") {
        WatchdogIntervalMs := tmp + 0
        if (WatchdogIntervalMs < 1000)
            WatchdogIntervalMs := 1000
    }
    IniRead, tmp, rects.ini, General, WatchdogStaleThresholdMs
    if (tmp != "") {
        WatchdogStaleThresholdMs := tmp + 0
        if (WatchdogStaleThresholdMs < 5000)
            WatchdogStaleThresholdMs := 5000
    }
    IniRead, tmp, rects.ini, General, WatchdogMaxRetries
    if (tmp != "") {
        WatchdogMaxRetries := tmp + 0
        if (WatchdogMaxRetries < 0)
            WatchdogMaxRetries := 0
    }
    IniRead, afkVal, rects.ini, General, AFKModeEnabled, 0
    AFKModeEnabled := (afkVal = 1 ? true : false)
} else {
    ; no INI -> defaults remain; Edit UI will show them on first open
}