global StreamBugFlag

on new me
  return me
end

on alertHook me, pErr, pMsg
  global gMyName
  errMsg = errMsg & "Error: " & pErr & RETURN
  errMsg = errMsg & "Message: " & pMsg & RETURN
  errMsg = errMsg & "Frame: " & the frame & RETURN
  if the frameLabel <> 0 then
    errMsg = errMsg & "Label: " & the frameLabel & RETURN
  end if
  errMsg = errMsg & "Movie: " & the movieName & RETURN
  mailMessage = "otto@sulake.com" & RETURN & "alert.habbo@habbo.com" & RETURN & "Habbo Alert" & RETURN
  mailMessage = mailMessage & errMsg & RETURN & RETURN
  mailMessage = mailMessage & "Environmet:" & the environment & RETURN
  mailMessage = mailMessage & "Memory: " & the memorysize / 1024 / 1024 & RETURN & RETURN
  mailMessage = mailMessage & "UserName: " & gMyName & RETURN
  if StreamBugFlag = VOID then
    StreamBugFlag = 0
  end if
  if pMsg contains "streaming is not complete" and StreamBugFlag = 0 and the movieName <> "habbo_entry.dcr" then
    StreamBugFlag = 1
    gotoNetMovie(the moviePath & the movieName & "#" & "connection_init")
    return 1
  end if
  ShowAlert(errMsg)
  return 1
end
