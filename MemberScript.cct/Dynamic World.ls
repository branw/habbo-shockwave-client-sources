global gBalloons, gUserColors, gLastBalloon, glHeightMap, xoffset, yoffset, xSize, ySize, gUserSprites, gXFactor, gYFactor, gHFactor, glObjectPlaceMap

on createFuseObject name, memberPrefix, memberType, locX, locY, height, dir, lDimensions, altitude, pData, partColors, update
  if memberPrefix.length = 0 then
    return 
  end if
  newSpr = sprMan_getPuppetSprite()
  dir = dir mod 8
  if getmemnum(memberPrefix && "Class") > 0 then
    scriptName = memberPrefix && "Class"
  else
    scriptName = "FuseMember Class"
  end if
  if offset("*", name) > 0 then
    name = char 1 to offset("*", name) - 1 of name & char offset("*", name) + 2 to name.length of name
  end if
  if offset("*", memberPrefix) > 0 then
    memberPrefix = char 1 to offset("*", memberPrefix) - 1 of memberPrefix
  end if
  o = new(script(scriptName), name, memberPrefix, memberType, locX, locY, height, dir, lDimensions, newSpr, altitude, pData, partColors, update)
  setProp(o, #spriteNum, newSpr)
  beginSprite(o)
  set the scriptInstanceList of sprite newSpr to [o]
  return o
end

on createBalloon user, message, ttype
  user = doSpecialCharConversion(user)
  message = doSpecialCharConversion(message)
  gLastBalloon = the ticks
  if gBalloons.count > 15 then
    put "Too many Balloon Sprites ! So kill first one." && gBalloons[1]
    sendSprite(gBalloons[1], #die)
  end if
  newSpr = sprMan_getPuppetSprite()
  balloonsUp()
  userObj = getaProp(gUserSprites, getObjectSprite(user))
  if not objectp(userObj) then
    return 
  end if
  locX = getaProp(userObj, #locX)
  locY = getaProp(userObj, #locY)
  height = getaProp(userObj, #locHe)
  screenLocs = getScreenCoordinate(locX, locY, height)
  if newSpr = 0 then
    return 
  end if
  balloonColor = getProp(userObj.pColors, #ch)
  o = new(script("Balloon Class"), newSpr, user, user & ": " & message, screenLocs[1], 281, 255, balloonColor, ttype)
  set the scriptInstanceList of sprite newSpr to [o]
end

on balloonsUp
  if voidp(gBalloons) then
    return 
  end if
  repeat with i = count(gBalloons) down to 1
    sendSprite(getAt(gBalloons, i), #moveUp)
  end repeat
end

on loadHeightMap data
  glHeightMap = []
  glObjectPlaceMap = []
  repeat with i = 1 to the number of lines in data
    l = []
    k = []
    ln = line i of data
    repeat with j = 1 to ln.length
      if char j of ln = "x" then
        add(l, 100000)
        add(k, 100000)
        next repeat
      end if
      if char j of ln = "y" then
        add(l, 0)
        add(k, 10000)
        next repeat
      end if
      add(l, integer(char j of ln))
      add(k, 0)
    end repeat
    add(glHeightMap, l)
    add(glObjectPlaceMap, k)
  end repeat
end

on getScreenCoordinate locX, locY, height
  locH = (locX - locY) * (gXFactor * 0.5) + xoffset
  locV = float((locY + locX) * gYFactor * 0.5 + yoffset) - height * gHFactor
  locZ = 1000 * (locX + locY + 1)
  return [integer(locH), integer(locV), integer(locZ)]
end

on getCoordinateHeight x, y
  x = integer(x)
  y = integer(y)
  if y < 0 or y >= count(glHeightMap) then
    return 0
  end if
  l = getAt(glHeightMap, integer(y + 1))
  if x < 0 or x >= count(l) then
    return 0
  end if
  return getAt(l, x + 1)
end

on getWorldCoordinate locX, locY, ignoreObjectCoordinates
  if voidp(glHeightMap) then
    return VOID
  end if
  x = integer((locX - gYFactor - xoffset) / gXFactor + (locY - yoffset) / gYFactor)
  y = integer((locY - yoffset) / gYFactor - (locX - gYFactor - xoffset) / gXFactor)
  height = -1
  if y >= 0 and y < count(glHeightMap) then
    if x >= 0 and x < count(getAt(glHeightMap, y + 1)) then
      height = getAt(getAt(glHeightMap, y + 1), x + 1)
    end if
  end if
  if height = 0 then
    return [x, y, height]
  else
    repeat with i = 1 to 9
      x = integer((locX - gYFactor - xoffset) / gXFactor + (locY + i * gHFactor - yoffset) / gYFactor)
      y = integer((locY + i * gHFactor - yoffset) / gYFactor - (locX - gYFactor - xoffset) / gXFactor)
      height = -1
      if y >= 0 and y < count(glHeightMap) then
        if x >= 0 and x < count(getAt(glHeightMap, y + 1)) then
          height = getAt(getAt(glHeightMap, y + 1), x + 1)
        end if
      end if
      if height = i then
        return [x, y, height]
      end if
    end repeat
  end if
  return VOID
end

on getCoordinateEmpty xx, yy
  global glObjectPlaceMap
  if yy + 1 > 0 and yy + 1 <= count(glObjectPlaceMap) then
    if xx + 1 > 0 and xx + 1 <= count(glObjectPlaceMap[yy + 1]) then
      if glObjectPlaceMap[yy + 1][xx + 1] > 1000 then
        return 0
      end if
    else
      return 0
    end if
  else
    return 0
  end if
  return 1
end
