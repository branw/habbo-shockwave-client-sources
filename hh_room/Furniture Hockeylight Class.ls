property pActive, pFrame, pCycles, pDelay

on prepare me, tdata
  pActive = 0
  pFrame = 0
  pCycles = 0
  pDelay = 0
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "I" then
    me.setOn()
  end if
end

on update me
  if not pActive then
    return 
  end if
  if me.pSprList.count < 3 then
    return 
  end if
  pDelay = not pDelay
  if pDelay then
    return 
  end if
  pFrame = pFrame + 1
  if pFrame = 5 then
    pFrame = 1
    pCycles = pCycles + 1
    if pCycles = 4 then
      pCycles = 0
      me.setOff()
    end if
  end if
  if pActive then
    tmember = member(getmemnum("hockey_light_c_0_1_1_0_" & pFrame))
  else
    tmember = member(getmemnum("hockey_light_c_0_1_1_0_0"))
  end if
  me.pSprList[3].castNum = tmember.number
  me.pSprList[3].width = tmember.width
  me.pSprList[3].height = tmember.height
end

on setOn me
  pActive = 1
end

on setOff me
  pActive = 0
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "ON" & "/" & "I")
  end if
  return 1
end
