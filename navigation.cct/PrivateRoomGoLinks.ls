on mouseUp me
  global gChosenFlatId, gFlatWaitStart, gFlatLetIn
  gFlatLetIn = 0
  member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
  gFlatWaitStart = the milliSeconds
  ml = (the mouseV + sprite(me.spriteNum).member.scrollTop - sprite(me.spriteNum).top) / 14 + 1
  put ml
  openFlatInfo(ml)
  GoToFlatWithNavi(gChosenFlatId)
end
