on prepareMovie
  the alertHook = script("AlertParent")
  if the runMode = "Author" then
    the alertHook = 0
  end if
end

on ShowAlert AlertID, OptionalMessage
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = "="
  alertMes = EMPTY
  repeat with f = 1 to member("AlertMessages").line.count
    if member("AlertMessages").line[f].item[1] contains AlertID then
      alertMes = member("AlertMessages").line[f].item[2]
      if AlertID = "MessageFromAdmin" then
        alertMes = OptionalMessage
      end if
      if AlertID = "ModeratorWarning" then
        alertMes = alertMes && OptionalMessage
      end if
      exit repeat
    end if
  end repeat
  put "ALERT:" && AlertID && alertMes
  the alertHook = 0
  if alertMes <> EMPTY then
    alert(alertMes)
  else
    alert(AlertID)
  end if
  the itemDelimiter = oldItemDelimiter
  the alertHook = script("AlertParent")
  if the runMode = "Author" then
    the alertHook = 0
  end if
end
