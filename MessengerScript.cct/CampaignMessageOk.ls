global gBuddyList, gMessageManager, gChosenBuddyId

on mouseUp me
  global gChosenBuddyId, gMessageManager
  if voidp(gMessageManager) then
    return 
  end if
  msg = getNextMessage(gMessageManager, gChosenBuddyId)
  if msg = VOID then
    goContext("buddies")
  else
    display(msg)
  end if
end
