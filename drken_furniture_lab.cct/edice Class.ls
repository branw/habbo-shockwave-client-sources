property ancestor, BarDoorOpentimer, pValue, pAnimStart
global gpObjects, gChosenStuffId, gChosenStuffSprite, gMyName

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  pAnimStart = 0
  pValue = 0
  put me.pData
  if getaProp(me.pData, "VALUE") <> VOID then
    pValue = value(getaProp(me.pData, "VALUE"))
  end if
  return me
end

on mouseDown me
  global hiliter, gInfofieldIconSprite, gpUiButtons
  userObj = sprite(getProp(gpObjects, gMyName)).scriptInstanceList[1]
  if rollover(me.lSprites[2]) then
    if the doubleClick then
      if abs(userObj.locX - me.locX) > 1 or abs(userObj.locY - me.locY) > 1 then
        repeat with xx = me.locX - 1 to me.locX + 1
          repeat with yy = me.locY - 1 to me.locY + 1
            if yy = me.locY or xx = me.locX then
              if getCoordinateEmpty(xx, yy) = 1 then
                sendFuseMsg("Move" && xx && yy)
                return 
              end if
            end if
          end repeat
        end repeat
        return 
      else
        throwDice(me)
      end if
    end if
  else
    if rollover(me.lSprites[1]) and the doubleClick then
      sendFuseMsg("DICE_OFF /" & me.id)
      return 
    end if
  end if
  if rollover(me.lSprites[2]) then
    return 
  end if
  if listp(gpUiButtons) and the movieName contains "private" then
    mouseDown(hiliter, 1)
    gChosenStuffId = me.id
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
    gChosenStuffSprite = me.spriteNum
    gChosenStuffType = #stuff
    setInfoTexts(me)
    myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
    if myUserObj.controller = 1 then
      hilite(me)
      if the optionDown then
        moveStuff(hiliter, gChosenStuffSprite)
      end if
    end if
  end if
end

on throwDice me
  sendFuseMsg("THROW_DICE /" & me.id)
end

on diceThrown me, tValue
  pValue = tValue
  if pValue > 0 then
    pAnimStart = the milliSeconds
  end if
end

on exitFrame me
  tSprite = me.lSprites[2]
  if the milliSeconds - pAnimStart < 2000 or random(100) = 2 and pValue <> 0 then
    if tSprite.castNum = getmemnum("edice_b_0_1_1_0_7") then
      tSprite.castNum = getmemnum("edice_b_0_1_1_0_0")
    else
      tSprite.castNum = getmemnum("edice_b_0_1_1_0_7")
    end if
  else
    tSprite.castNum = getmemnum("edice_b_0_1_1_0_" & pValue)
  end if
end
