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

; Helper: checks if variable is set (for Debug)
IsSetVar(name) {
    return (IsByRef(name) || (name != "" && VarSetCapacity(name) >= 0))
}