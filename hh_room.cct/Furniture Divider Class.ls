property pChanges, pActive

on prepare me, tdata
  if tdata[#stuffdata] = "O" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  return 1
end

on updateStuffdata me, tValue
  if tValue = "O" then
    me.setOn()
  else
    me.setOff()
  end if
  pChanges = 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 2 then
    return 
  end if
  tIsGateSprite = []
  repeat with i = 1 to me.pSprList.count
    tCurName = me.pSprList[i].member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & pActive
    tMemNum = getmemnum(tNewName)
    if abs(tMemNum) > 0 then
      tmember = member(abs(tMemNum))
      me.pSprList[i].castNum = tMemNum
      me.pSprList[i].width = tmember.width
      me.pSprList[i].height = tmember.height
      if pActive then
        tIsGateSprite.append(i)
      end if
    end if
  end repeat
  tDirection = 0
  if me.pDirection.count > 0 then
    tDirection = me.pDirection[1]
  end if
  tlocz = me.pLoczList[1][tDirection + 1]
  tSpriteLocZ = me.pSprList[1].locZ
  repeat with i = 2 to me.pSprList.count
    me.pSprList[i].locZ = tSpriteLocZ + (me.pLoczList[i][tDirection + 1] - tlocz)
  end repeat
  pChanges = 0
end

on setOn me
  pActive = 1
end

on setOff me
  pActive = 0
end

on select me
  if the doubleClick then
    if pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
  end if
  return 1
end
