property ancestor, BarDoorOpentimer
global gpObjects, gChosenStuffId, gChosenStuffSprite, gMyName

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData, partColors, update
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  return me
end

on updateStuffdata me, tProp, tValue
end

on mouseDown me
  global hiliter, gInfofieldIconSprite, gpUiButtons
  userObj = sprite(getProp(gpObjects, gMyName)).scriptInstanceList[1]
  if the doubleClick then
    case me.direction[1] of
      4:
        if me.locX = userObj.locX and me.locY - userObj.locY = -1 then
          giveDrink(me)
        else
          sendFuseMsg("Move" && me.locX && me.locY + 1)
          return 
        end if
      0:
        if me.locX = userObj.locX and me.locY - userObj.locY = 1 then
          giveDrink(me)
        else
          sendFuseMsg("Move" && me.locX && me.locY - 1)
          return 
        end if
      2:
        if me.locY = userObj.locY and me.locX - userObj.locX = -1 then
          giveDrink(me)
        else
          sendFuseMsg("Move" && me.locX + 1 && me.locY)
          return 
        end if
      6:
        if me.locY = userObj.locY and me.locX - userObj.locX = 1 then
          giveDrink(me)
        else
          sendFuseMsg("Move" && me.locX - 1 && me.locY)
        end if
    end case
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

on giveDrink me
  put "CarryDrink" && getDrinkname(me)
  sendFuseMsg("LOOKTO" && me.locX && me.locY)
  sendFuseMsg("CarryDrink" && getDrinkname(me))
end

on getDrinkname me
  return "Tea"
end
