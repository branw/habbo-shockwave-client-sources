property ancestor, pLayout, pLocX, pLocY, pLocZ, pWidth, pHeight, pVisible, pSpriteList, pSpriteData, pActSprList, pDragFlag, pDragOffset, pBoundary

on new me
  return me
end

on construct me
  pLayout = []
  pLocX = 0
  pLocY = 0
  pLocZ = 0
  pWidth = 0
  pHeight = 0
  pVisible = 1
  pSpriteList = []
  pSpriteData = []
  pActSprList = [:]
  pDragFlag = 0
  pDragOffset = [0, 0]
  pBoundary = rect(0, 0, (the stage).rect.width, (the stage).rect.height) + [-1000, -1000, 1000, 1000]
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  repeat with i = 1 to pSpriteList.count
    releaseSprite(pSpriteList[i].spriteNum)
  end repeat
  pSpriteList = []
  pSpriteData = []
  pActSprList = [:]
  pBoundary = []
  return 1
end

on define me, tProps
  if voidp(tProps) then
    return 0
  end if
  if not voidp(tProps[#locX]) then
    pLocX = tProps[#locX]
  end if
  if not voidp(tProps[#locY]) then
    pLocY = tProps[#locY]
  end if
  if not voidp(tProps[#locZ]) then
    pLocZ = tProps[#locZ]
  end if
  if not voidp(tProps[#layout]) then
    pLayout = tProps[#layout]
  end if
  if not voidp(tProps[#boundary]) then
    pBoundary = tProps[#boundary]
  end if
  return me.open(pLayout)
end

on open me, tLayout
  if voidp(tLayout) then
    tLayout = pLayout
  end if
  pLayout = tLayout
  if pSpriteList.count > 0 then
    repeat with i = 1 to pSpriteList.count
      releaseSprite(pSpriteList[i].spriteNum)
    end repeat
    pSpriteList = []
  end if
  return me.buildVisual(pLayout)
end

on close me
  return me.remove(me.getID)
end

on moveTo me, tX, tY
  tOffX = tX - pLocX
  tOffY = tY - pLocY
  if pLocX + tOffX < pBoundary[1] then
    tOffX = pBoundary[1] - pLocX
  end if
  if pLocY + tOffY < pBoundary[2] then
    tOffY = pBoundary[2] - pLocY
  end if
  if pLocX + pWidth + tOffX > pBoundary[3] then
    tOffX = pBoundary[3] - pLocX - pWidth
  end if
  if pLocY + pHeight + tOffY > pBoundary[4] then
    tOffY = pBoundary[4] - pLocY - pHeight
  end if
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.moveXY(tOffX, tOffY)
end

on moveBy me, tOffX, tOffY
  if pLocX + tOffX < pBoundary[1] then
    tOffX = pBoundary[1] - pLocX
  end if
  if pLocY + tOffY < pBoundary[2] then
    tOffY = pBoundary[2] - pLocY
  end if
  if pLocX + pWidth + tOffX > pBoundary[3] then
    tOffX = pBoundary[3] - pLocX - pWidth
  end if
  if pLocY + pHeight + tOffY > pBoundary[4] then
    tOffY = pBoundary[4] - pLocY - pHeight
  end if
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.moveXY(tOffX, tOffY)
end

on moveZ me, tZ
  if not integerp(tZ) then
    return error(me, "Integer expected:" && tZ, #moveZ)
  end if
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].locZ = tZ + i - 1
  end repeat
  pLocZ = tZ
end

on getSprById me, tid
  return pActSprList[tid]
end

on getSpriteByID me, tid
  return pActSprList[tid]
end

on spriteExists me, tid
  return not voidp(pActSprList[tid])
end

on moveSprBy me, tid, tX, tY
  tSprite = pActSprList[tid]
  if voidp(tSprite) then
    return error(me, "Sprite not found:" && tid, #moveSprBy)
  end if
  tSprite.loc = tSprite.loc + [tX, tY]
  return me.refresh()
end

on moveSprTo me, tid, tX, tY
  tSprite = pActSprList[tid]
  if voidp(tSprite) then
    return error(me, "Sprite not found:" && tid, #moveSprTo)
  end if
  tSprite.loc = point(tX, tY)
  return me.refresh()
end

on setActive me
  return 1
end

on setDeactive me
  return 1
end

on hide me
  if pVisible = 1 then
    pVisible = 0
    me.moveX(10000)
    return 1
  end if
  return 0
end

on show me
  if pVisible = 0 then
    pVisible = 1
    me.moveX(-10000)
    return 1
  end if
  return 0
end

on drag me, tBoolean
  if tBoolean = 1 and pDragFlag = 0 then
    pDragOffset = the mouseLoc - [pLocX, pLocY]
    receiveUpdate(me.getID())
    pDragFlag = 1
  else
    if tBoolean = 0 and pDragFlag = 1 then
      removeUpdate(me.getID())
      pDragFlag = 0
    end if
  end if
  return 1
end

on getProperty me, tProp
  case tProp of
    #layout:
      return pLayout
    #locX:
      return pLocX
    #locY:
      return pLocY
    #locZ:
      return pLocZ
    #boundary:
      return pBoundary
    #width:
      return pWidth
    #height:
      return pHeight
    #sprCount:
      return pSpriteList.count
    #spriteList:
      return pSpriteList
    #spriteData:
      return pSpriteData
    #visible:
      return pVisible
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #layout:
      return me.open(tValue)
    #locX:
      return me.moveX(tValue)
    #locY:
      return me.moveY(tValue)
    #locZ:
      return me.moveZ(tValue)
    #boundary:
      pBoundary = tValue
      return 1
    #visible:
      if tValue then
        return me.show()
      else
        return me.hide()
      end if
  end case
  return 0
end

on moveX me, tOffX
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].locH = pSpriteList[i].locH + tOffX
  end repeat
end

on moveY me, tOffY
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].locV = pSpriteList[i].locV + tOffY
  end repeat
end

on moveXY me, tOffX, tOffY
  repeat with i = 1 to pSpriteList.count
    pSpriteList[i].loc = pSpriteList[i].loc + [tOffX, tOffY]
  end repeat
end

on update me
  me.moveTo(the mouseH - pDragOffset[1], the mouseV - pDragOffset[2])
end

on refresh me
  tRect = rect(100000, 100000, -100000, -100000)
  repeat with tSpr in pSpriteList
    if tSpr.locH < tRect[1] then
      tRect[1] = tSpr.locH
    end if
    if tSpr.locV < tRect[2] then
      tRect[2] = tSpr.locV
    end if
    if tSpr.locH + tSpr.width > tRect[3] then
      tRect[3] = tSpr.locH + tSpr.width
    end if
    if tSpr.locV + tSpr.height > tRect[4] then
      tRect[4] = tSpr.locV + tSpr.height
    end if
  end repeat
  pLocX = tRect[1]
  pLocY = tRect[2]
  pWidth = tRect.width
  pHeight = tRect.height
  if pSpriteData.count > 0 then
    repeat with i = 1 to pSpriteList.count
      pSpriteData[i][#loc] = pSpriteList[i].loc - [tRect[1], tRect[2]]
    end repeat
  end if
  return 1
end

on buildVisual me, tLayout
  tLayout = getObjectManager().get(#layout_parser).parse(tLayout)
  if not listp(tLayout) then
    return error(me, "Invalid visualizer definition:" && tLayout, #buildVisual)
  end if
  if not voidp(tLayout[#rect]) then
    if tLayout[#rect].count > 0 then
      pLocX = pLocX + tLayout[#rect][1][1]
      pLocY = pLocY + tLayout[#rect][1][2]
    end if
  end if
  tLayout = tLayout[#elements]
  repeat with i = 1 to tLayout.count
    tMemNum = getResourceManager().getmemnum(tLayout[i][#member])
    if tMemNum < 1 then
      error(me, "Member" && tLayout[i][#member] && "required by visualizer:" && me.getID() && "not found!", #buildVisual)
    end if
    tLayoutRow = tLayout[i]
    tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
    tSpr.castNum = tMemNum
    tSpr.ink = tLayoutRow[#ink]
    tSpr.locH = tLayoutRow[#locH] + pLocX
    tSpr.locV = tLayoutRow[#locV] + pLocY
    tSpr.width = tLayoutRow[#width]
    tSpr.height = tLayoutRow[#height]
    tSpr.blend = tLayoutRow[#blend]
    tSpr.rotation = tLayoutRow[#rotation]
    tSpr.skew = tLayoutRow[#skew]
    tSpr.flipH = tLayoutRow[#flipH]
    tSpr.flipV = tLayoutRow[#flipV]
    tSpr.color = rgb(tLayoutRow[#color])
    tSpr.bgColor = rgb(tLayoutRow[#bgColor])
    if not voidp(tLayoutRow[#txtColor]) then
      member(tMemNum).color = rgb(tLayoutRow[#txtColor])
    end if
    if not voidp(tLayoutRow[#txtBgColor]) then
      member(tMemNum).bgColor = rgb(tLayoutRow[#txtBgColor])
    end if
    if voidp(tLayoutRow[#locZ]) then
      tSpr.locZ = pLocZ + i - 1
    else
      tSpr.locZ = integer(tLayoutRow[#locZ]) + pLocZ
    end if
    if not voidp(tLayoutRow[#id]) then
      if tLayoutRow[#Active] = 1 or voidp(tLayoutRow[#Active]) and voidp(tLayoutRow[#type]) then
        getSpriteManager().setEventBroker(tSpr.spriteNum, tLayoutRow[#id])
        if not voidp(tLayoutRow[#cursor]) then
          tSpr.setCursor(tLayoutRow[#cursor])
        end if
        if not voidp(tLayoutRow[#link]) then
          tSpr.setLink(tLayoutRow[#link])
        end if
      end if
      pActSprList[tLayout[i][#id]] = tSpr
    end if
    pSpriteData[i] = [:]
    pSpriteList.append(tSpr)
  end repeat
  return me.refresh()
end
