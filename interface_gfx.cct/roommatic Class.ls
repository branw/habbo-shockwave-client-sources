property ancestor, fireplaceOn
global gpObjects, gChosenStuffId, gChosenStuffSprite, gMyName

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  repeat with iSpr in me.lSprites
    if spr <> iSpr then
      add(sprite(iSpr).scriptInstanceList, new(script("EventBroker Behavior"), spr))
    end if
  end repeat
  return me
end

on mouseDown me
  userObj = sprite(getProp(gpObjects, gMyName)).scriptInstanceList[1]
  if me.locX = userObj.locX and abs(me.locY - userObj.locY) = 1 then
    openRoomkiosk()
  else
    callAncestor(#mouseDown, ancestor)
    sendFuseMsg("Move" && me.locX && me.locY + 1)
  end if
end
