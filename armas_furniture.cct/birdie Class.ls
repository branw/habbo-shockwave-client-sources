property ancestor, myswitchON, pFrame, pLastUpdate
global gpObjects, gChosenStuffId, gChosenStuffSprite

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  if getaProp(me.pData, "SWITCHON") = "ON" then
    setOn(me)
  end if
  pFrame = 0
  pLastUpdate = the milliSeconds
  return me
end

on updateStuffdata me, tProp, tValue
  pFrame = 0
  pLastUpdate = the milliSeconds
  if tValue = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
end

on exitFrame me
  if the milliSeconds < pLastUpdate then
    return 
  end if
  if myswitchON then
    tAnim = [0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 3, 2, 3, 2, 3, 3, 1, 0]
    pFrame = pFrame + 1
    if pFrame > tAnim.count then
      pFrame = 1
    end if
    tMemName = me.lSprites[1].member.name
    if tMemName = EMPTY then
      return 
    end if
    tMem = getmemnum(tMemName.char[1..tMemName.length - 1] & tAnim[pFrame])
    me.lSprites[1].member = member(tMem)
    if pFrame = tAnim.count then
      pLastUpdate = the milliSeconds + 4000
    else
      pLastUpdate = the milliSeconds + 100
    end if
  else
    pFrame = 0
    tMemName = me.lSprites[1].member.name
    if tMemName = EMPTY then
      return 
    end if
    tMem = getmemnum(tMemName.char[1..tMemName.length - 1] & pFrame)
    me.lSprites[1].member = member(tMem)
  end if
end

on setOn me
  myswitchON = 1
end

on setOff me
  myswitchON = 0
end

on mouseDown me
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    if myswitchON = 1 then
      onString = "OFF"
    else
      onString = "ON"
    end if
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "SWITCHON" & "/" & onString)
  end if
end
