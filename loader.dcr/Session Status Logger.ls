property pSessionId, pEnabled

on new me
  pSessionId = externalParamValue("sw1")
  if pSessionId = VOID or pSessionId = 0 then
    pEnabled = 0
  else
    pEnabled = 1
  end if
  if pSessionId = VOID and the runMode = "Author" then
    pEnabled = 1
    pSessionId = 1
  end if
  return me
end

on signal me, tSignal, tUserId
  if pEnabled then
    tUrl = "http://www.habbohotel.com/login_log.jsp?sid=" & pSessionId & "&signal=" & tSignal
    if tUserId <> VOID then
      tUrl = tUrl & "&userid=" & tUserId
    end if
    getNetText(tUrl)
  end if
end
