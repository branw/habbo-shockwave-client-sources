property pChanges, pActive, pTvFrame, pChannelNum

on prepare me, tdata
  pTvFrame = 0
  if integerp(integer(tdata["CHANNEL"])) then
    pChanges = 1
    pActive = 1
    pChannelNum = integer(tdata["CHANNEL"])
    if ([1, 2, 3]).getOne(pChannelNum) = 0 then
      pChannelNum = 1
    end if
  else
    pChanges = 0
    pActive = 0
    pChannelNum = 1
  end if
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
    pChannelNum = integer(tValue)
    if ([1, 2, 3]).getOne(pChannelNum) = 0 then
      pChannelNum = 1
    end if
  end if
  pChanges = 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 3 then
    return 
  end if
  pTvFrame = pTvFrame + 1
  if pActive and pTvFrame mod 3 = 1 then
    tName = me.pSprList[3].member.name
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tTmpName = tName.item[1..tName.item.count - 1] & "_"
    the itemDelimiter = tDelim
    case pChannelNum of
      1:
        tNewName = tTmpName & random(10)
      2:
        tNewName = tTmpName & 10 + random(5)
      3:
        tNewName = tTmpName & 15 + random(5)
    end case
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[3].castNum = tmember.number
      me.pSprList[3].width = tmember.width
      me.pSprList[3].height = tmember.height
    end if
    pChanges = 1
  end if
  if not pActive then
    tNewName = "wood_tv_c_0_1_2_0_0"
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[3].castNum = tmember.number
      me.pSprList[3].width = tmember.width
      me.pSprList[3].height = tmember.height
    end if
    pChanges = 0
  end if
  me.pSprList[3].locZ = me.pSprList[2].locZ + 2
end

on setOn me
  pActive = 1
  pChannelNum = random(3)
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "CHANNEL" & "/" & pChannelNum)
end

on setOff me
  pActive = 0
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "CHANNEL" & "/" & "OFF")
end

on select me
  if the doubleClick then
    if pActive then
      me.setOff()
    else
      me.setOn()
    end if
  end if
  return 1
end
