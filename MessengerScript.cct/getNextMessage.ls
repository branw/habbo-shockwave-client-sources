global gMessageManager

on mouseDown me
  msg = getNextMessage(gMessageManager)
  if not voidp(msg) then
    display(msg)
  else
    goContext("buddies")
  end if
end
