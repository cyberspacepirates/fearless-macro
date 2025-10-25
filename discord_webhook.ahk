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