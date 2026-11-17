#NoEnv
#SingleInstance Force

; variables
NevermindButtonX = 1439
NevermindButtonY = 730

ShopButtonX := 1485
ShopButtonY := 485

BuyBaitButtonX := 1458
BuyBaitButtonY := 568

BasicBaitButtonX := 1438
BasicBaitButtonY := 650

IncreaseBaitButtonX := 1223
IncreaseBaitButtonY := 539

CraftBaitButtonX := 960
CraftBaitButtonY := 672

BackBaitButtonX := 1339
BackBaitButtonY := 725

SellFishButtonX := 1485
SellFishButtonY := 485

AutoBuy()
{
    global CurrentStatus
    CurrentStatus := "Buying bait..."
    GuiControl,, CurrentStatusText, %CurrentStatus%
    SendInput, {Shift}
    Sleep, 100
    SendInput, {s down}
    Sleep, 100  ; Adjust this time (in milliseconds) to walk longer/shorter
    SendInput, {s up}
    Sleep, 400
    ; click left mouse button
    Click, left
    Sleep, 200
    ; Move to shop coords
    MoveMouseHuman(1485, 485)
    Sleep, 200
    Click, left
    Sleep, 200
    ; Move to baits coords
    MoveMouseHuman(1458, 568)
    Sleep, 200
    Click, left
    Sleep, 200
    ; Move to basic bait coords
    MoveMouseHuman(1438, 650)
    Sleep, 200
    Click, left
    Sleep, 200
    ; Move to increase bait coords
    MoveMouseHuman(1223, 539)
    Sleep, 200
    Click, left
    Sleep, 200
    Click, left
    Sleep, 200
    Click, left
    Sleep, 200
    Click, left
    Sleep, 200
    Click, left
    Sleep, 200
    Click, left
    Sleep, 200
    Click, left
    Sleep, 200
    ; Move to craft bait coords
    MoveMouseHuman(960, 672)
    Sleep, 200
    Click, left
    Sleep, 200
    ; Move to back
    MoveMouseHuman(1339, 725)
    Sleep, 200
    Click, left
    Sleep, 200
    ; Move to nevermind
    MoveMouseHuman(1439, 730)
    Sleep, 200
    Click, left
    Sleep, 400
    SendInput, {Shift}
    CurrentStatus := "Bait purchase sequence complete."
    GuiControl,, CurrentStatusText, %CurrentStatus%
}

MoveMouseHuman(targetX, targetY)
{
    CoordMode, Mouse, Screen
    MouseGetPos, currentX, currentY

    distance := Sqrt((targetX - currentX)**2 + (targetY - currentY)**2)
    
    ; Adjust the speed factor: higher number = slower/smoother movement
    steps := Max(Round(distance / 5), 10) 

    loop, %steps%
    {
        progress := A_Index / steps
        
        ; Ease-in ease-out formula for natural acceleration and deceleration
        smoothProgress := (1 - Cos(progress * 3.14159265)) / 2

        ; Calculate current target step with a tiny bit of human-like jitter
        currentStepX := currentX + (targetX - currentX) * smoothProgress + (Random(-1, 1))
        currentStepY := currentY + (targetY - currentY) * smoothProgress + (Random(-1, 1))

        MouseMove, %currentStepX%, %currentStepY%, 0
        
        ; Variable sleep time to simulate human hesitation
        Sleep, % Random(2, 8)
    }
    
    ; Ensure it lands precisely on the final coordinate
    MouseMove, targetX, targetY, 0
}

; Helper random function for AHK v1
Random(min, max) {
    Random, rand, min, max
    return rand
}
