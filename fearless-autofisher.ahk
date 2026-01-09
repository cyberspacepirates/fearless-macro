#NoEnv
#SingleInstance Force

SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

#Include, variables.ahk
#Include, settings.ahk
#Include, main_gui.ahk

#Include, helpers.ahk

#Include, settings_gui.ahk

#Include, discord_webhook.ahk
; =========================
; Hotkeys
; =========================
F5:: StartMacro()
F6:: StopMacro(true)
F3:: ToggleAlignMode()

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

StopMacro(userInteracted := true)
{
    global MacroActive, LoopActive, CurrentStatus, Holding, TotalRuns, AFKModeActive, AFKModeEnabled
    
    ; Stop AFK mode if running
    if (userInteracted && AFKModeActive)
        StopAFKMode()
    
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
    
    ; Start AFK mode if user didn't interact and AFKMode is enabled
    if (!userInteracted && AFKModeEnabled) {
        ShowNotification("Starting AFK Mode script...")
        StartAFKMode()
        CurrentStatus := "AFK mode enabled!"
    }
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
                StopMacro(false)
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

        ; Send webhook; wrapper will respect rate-limit
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
    TotalWait := 3000     ; total 3.0s before we reset

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

    ; first 5 at ~1.0s
    if (elapsed >= PressTime1 && !sentAt1) {
        if (Holding) {
            Send {LButton Up}
            Holding := false
        }
        Send, 5
        Sleep, 20    ; short pause to ensure keystroke registers cleanly
        sentAt1 := true
        if (DebugMode)
            ShowNotification("Step4: Sent first 5 (1.0s)")
    }

    ; second 5 at ~1.6s
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

    ; after TotalWait reset and count run
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
            
            StopMacro(false)
            return
        }
    }
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
    StopMacro(false)
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
        StopMacro(false)
        WatchdogRetries := 0
    }
return

; =========================
; AFK Mode - Press 1 every 2 minutes with tick variation
; =========================
global AFKModeActive := false

StartAFKMode()
{
    global AFKModeActive, CurrentStatus
    AFKModeActive := true
    CurrentStatus := "AFK Mode: Running..."
    GuiControl,, CurrentStatusText, %CurrentStatus%
    ShowNotification("AFK Mode started - Press F6 to stop")
    SendDiscordWebhook("Starting AFK Mode [ENABLED]")
    SetTimer, AFKModeLoop, 120000
}

StopAFKMode()
{
    global AFKModeActive, CurrentStatus
    AFKModeActive := false
    CurrentStatus := "AFK Mode: Stopped"
    GuiControl,, CurrentStatusText, %CurrentStatus%
    SetTimer, AFKModeLoop, Off
    ShowNotification("AFK Mode stopped")
}

AFKModeLoop:
global AFKModeActive, DebugMode
if (!AFKModeActive)
{
    return
}
; selects the button 1
Send, 1
return