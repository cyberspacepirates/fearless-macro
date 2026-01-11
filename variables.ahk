; =========================
; DEFAULTS (Constants)
; =========================
DefaultFishColor := 0x2A8CF0
DefaultBlockColor := 0x909090
DefaultVariation := 45
DefaultMaxRuns := 100
DefaultFishrodSlot := 5

DefaultBarRectX := 520
DefaultBarRectY := 765
DefaultBarRectW := 875
DefaultBarRectH := 53

DefaultMovementRectX := 955
DefaultMovementRectY := 387
DefaultMovementRectW := 10
DefaultMovementRectH := 10

DefaultGreenRectX := 823
DefaultGreenRectY := 517
DefaultGreenRectW := 11
DefaultGreenRectH := 11

; =========================
; Current values initialized to defaults
; =========================
BarRectX := DefaultBarRectX
BarRectY := DefaultBarRectY
BarRectW := DefaultBarRectW
BarRectH := DefaultBarRectH
BarRectShow := false

MovementRectX := DefaultMovementRectX
MovementRectY := DefaultMovementRectY
MovementRectW := DefaultMovementRectW
MovementRectH := DefaultMovementRectH
MovementRectShow := false

GreenRectX := DefaultGreenRectX
GreenRectY := DefaultGreenRectY
GreenRectW := DefaultGreenRectW
GreenRectH := DefaultGreenRectH
GreenRectShow := false

FishColor := DefaultFishColor
BlockColor := DefaultBlockColor
Variation := DefaultVariation
FishrodSlot := DefaultFishrodSlot

; other flags / status
MacroActive := false
DebugMode := false
AlignMode := false
CurrentStatus := "Waiting to start..."
CurrentStep := 1
LoopActive := false
CooldownAfterLoopMs := 2000
NextLoopAllowed := 0

; new global: tracks whether LButton is currently held down
Holding := false

; === Fixed anchored Donate URLs (no INI) ===
DonateURL50  := "https://www.roblox.com/game-pass/1441842598"   ; replace with your actual 50 Robux URL
DonateURL100 := "https://www.roblox.com/game-pass/1440190881"  ; replace with your actual 100 Robux URL
DonateURL250 := "https://www.roblox.com/game-pass/1440728840"  ; replace with your actual 250 Robux URL
DonateURL500 := "https://www.roblox.com/game-pass/1444700174"  ; replace with your actual 500 Robux URL

; Discord link anchored in script
DiscordLink := "https://discord.gg/rzg6wx2X7A"    ; replace with your Discord link

; =========================
; Webhook / Counters
; =========================
WebhookEnabled := false
WebhookURL := ""
PingUserID := ""        ; e.g. 123456789012345678
ConsecutiveNoGreen := 0 ; counts consecutive Step1 timeouts
TotalRuns := 0          ; counts completed runs (Step4 -> reset)

; NEW: count how many times we already sent the 10x-no-green webhook
WebhookNoGreenEvents := 0

; --- New auto-stop constants (default possibly overridden from INI) ---
MaxRuns := DefaultMaxRuns
MaxConsecutiveNoGreen := 20

; =========================
; Watchdog / Heartbeat config & webhook rate-limit
; =========================
LastMainLoopTick := 0                     ; last tick time (ms) from MainLoop
WatchdogIntervalMs := 10000               ; how often the watchdog runs (ms) - default 10s
WatchdogStaleThresholdMs := 30000         ; if MainLoop didn't tick for this long, it's stale (ms) - default 30s
WatchdogRetries := 0                      ; how many restart attempts so far
WatchdogMaxRetries := 2                   ; after how many failed restarts we stop permanently
WatchdogLogFile := A_ScriptDir "\watchdog.log"

; webhook rate-limit (ms)
LastWebhookTime := 0
WebhookMinIntervalMs := 15000 ; 15s min between webhooks

global AFKModeEnabled := false
