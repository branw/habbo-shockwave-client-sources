property ancestor, fireplaceOn, rolling, rollDir, rollingDirection, rollingStartTime, rollAnimDir
global gpObjects

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  rolling = update
  me.direction[1] = rollDir
  me.direction[2] = rollDir
  setDir(me, getaProp(pData, "DIR"))
  updateMembers(me)
  return me
end

on updateStuffdata me, tProp, tValue
  put tProp && tValue
  rolling = 1
  setDir(me, value(tValue))
end

on exitFrame me
  if count(me.lSprites) = 2 and rolling then
    roll(me)
    updateMembers(me)
  else
    me.direction[1] = rollDir
    me.direction[2] = rollDir
    updateMembers(me)
  end if
end

on roll me
  if rolling and the milliSeconds - rollingStartTime < 3300 then
    t = the milliSeconds - rollingStartTime
    f = t * 1.0 / 3200.0 * 3.14158999999999988 * 0.5
    rollAnimDir = rollAnimDir + cos(f) * float(rollingDirection)
    me.direction[1] = abs(integer(rollAnimDir) mod 8)
    me.direction[2] = abs(integer(rollAnimDir) mod 8)
  else
    rolling = 0
  end if
end

on setDir me, newDir
  rollDir = newDir
  if rolling then
    rollingStartTime = the milliSeconds
    rollAnimDir = me.direction[1]
    if rollDir mod 2 = 1 then
      rollingDirection = 1
    else
      rollingDirection = -1
    end if
  end if
end

on mouseDown me
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    newDir = random(8) - 1
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "DIR" & "/" & newDir)
  end if
end
