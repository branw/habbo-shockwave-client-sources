property pChanges, pRolling, pRollDir, pRollingDirection, pRollingStartTime, pRollAnimDir

on prepare me, tdata
  if tdata.findPos(#stuffdata) then
    me.pDirection[1] = integer(tdata[#stuffdata])
    me.pDirection[2] = integer(tdata[#stuffdata])
    if me.pDirection[1] < 0 or me.pDirection > 7 then
      me.pDirection[1] = 0
    end if
  end if
  pChanges = 0
  pRolling = 0
  pRollAnimDir = me.pDirection[1]
  pRollingDirection = me.pDirection[1]
  me.setDir(me.pDirection[1])
  me.solveMembers()
  me.moveBy(0, 0, 0)
  return 1
end

on diceThrown me, tValue
  pRolling = 1
  pChanges = 1
  me.setDir(value(tValue))
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 1 then
    return 
  end if
  if pRolling then
    me.roll()
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 1
  else
    me.pDirection[1] = pRollDir
    me.pDirection[2] = pRollDir
    me.solveMembers()
    me.moveBy(0, 0, 0)
    pChanges = 0
  end if
end

on roll me
  if pRolling and the milliSeconds - pRollingStartTime < 3300 then
    tTime = the milliSeconds - pRollingStartTime
    f = tTime * 1.0 / 3200.0 * 3.14158999999999988 * 0.5
    pRollAnimDir = pRollAnimDir + cos(f) * float(pRollingDirection)
    me.pDirection[1] = abs(integer(pRollAnimDir) mod 8)
    me.pDirection[2] = abs(integer(pRollAnimDir) mod 8)
  else
    pRolling = 0
  end if
end

on setDir me, tNewDir
  if tNewDir < 0 or tNewDir > 7 then
    tNewDir = 0
  end if
  pRollDir = tNewDir
  if pRolling then
    pRollingStartTime = the milliSeconds
    pRollAnimDir = me.pDirection[1]
    if pRollDir mod 2 = 1 then
      pRollingDirection = 1
    else
      pRollingDirection = -1
    end if
  end if
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("THROW_DICE", me.getID())
  end if
  return 1
end
