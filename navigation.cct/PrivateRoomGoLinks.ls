on mouseUp me
  global gChosenFlatId, gActiveRoomInfoString, gFlatWaitStart, gFlatLetIn
  gFlatLetIn = 0
  member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
  gFlatWaitStart = the milliSeconds
  ml = (the mouseV + sprite(me.spriteNum).member.scrollTop - sprite(me.spriteNum).top) / 14 + 1
  put ml
  gActiveRoomInfoString = openFlatInfo(ml)
  GoToFlatWithNavi(gChosenFlatId)
end
