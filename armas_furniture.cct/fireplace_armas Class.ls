property ancestor, fireplaceOn
global gpObjects, gChosenStuffId, gChosenStuffSprite

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  if getaProp(me.pData, "FIREON") = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
  return me
end

on updateStuffdata me, tProp, tValue
  if tValue = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
end

on exitFrame me
  if count(me.lSprites) = 3 and fireplaceOn then
    mname = me.lSprites[3].member.name
    newMName = char 1 to mname.length - 1 of mname & random(11) - 1
    me.lSprites[3].locZ = me.lSprites[2].locZ + 2
    if getmemnum(newMName) > 0 then
      me.lSprites[3].castNum = getmemnum(newMName)
    end if
  else
    if fireplaceOn = 0 then
      mname = me.lSprites[3].member.name
      me.lSprites[3].castNum = getmemnum(char 1 to mname.length - 1 of mname & "0")
    end if
  end if
end

on setOn me
  fireplaceOn = 1
end

on setOff me
  fireplaceOn = 0
end

on mouseDown me
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    if fireplaceOn = 1 then
      onString = "OFF"
    else
      onString = "ON"
    end if
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "FIREON" & "/" & onString)
  end if
end
