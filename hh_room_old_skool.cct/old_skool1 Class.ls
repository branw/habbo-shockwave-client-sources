property pAnimThisUpdate, pSin, pAnimTimer, pSpriteList, pOrigLocs, pDiscoStyle, pDiscoStyleCount, pLightSwitchTimer, pWallLightSprites, pWallLightValues, pWallLightCount

on construct me
  pSin = 0.0
  pAnimTimer = the timer
  pSpriteList = []
  pOrigLocs = []
  pDiscoStyle = 1
  pDiscoStyleCount = 10
  pLightSwitchTimer = the timer
  pAnimThisUpdate = 0
  pWallLightCount = 60
  pWallLightSprites = []
  pWallLightValues = []
  return 1
end

on deconstruct me
  me.removeWallLights()
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tNum = tMsg[#show_command]
  return me.changeDiscoStyle(tNum)
end

on changeDiscoStyle me, tNr
  if tNr = VOID then
    pDiscoStyle = pDiscoStyle + 1
  else
    pDiscoStyle = tNr
  end if
  if pDiscoStyle < 1 or pDiscoStyle > pDiscoStyleCount then
    pDiscoStyle = 1
  end if
  return 1
end

on update me
  pAnimThisUpdate = not pAnimThisUpdate
  if pAnimThisUpdate then
    return 1
  end if
  pSin = pSin + 0.07000000000000001
  if pSpriteList = [] then
    return me.getSpriteList()
  end if
  me.rotateWallLights()
  case pDiscoStyle of
    1:
      me.fullRotation(15, 15, 15, 15, point(-10, -10), point(-10, -10))
    2:
      me.fullRotation(15, 15, 15, 15, point(30, 15), point(-40, -15))
      me.switchLights(#show1, 1)
    3:
      me.fullRotation(15, 15, 15, 15, point(30, 15), point(-40, -15))
      me.switchLights(#showAll, 0.69999999999999996)
    4:
      me.fullRotation(0, 19, 19, 0, point(30, 0), point(-10, 0))
    5:
      me.fullRotation(19, 0, 0, 19, point(50, 20), point(-50, 20))
    6:
      me.fullRotation(15, 15, 15, 15, VOID, VOID)
    7:
      me.fullRotation(20, 20, 20, 20, VOID, VOID)
    8:
      me.switchLights(#show1, 3)
    9:
      me.fullRotation(8, 8, 8, 8, VOID, point(-5, -5))
      me.switchLights(#showAll, 1)
    10:
      me.switchLights(#showAll, 0.69999999999999996)
    11:
      me.switchLights(#show1, 2)
  end case
end

on fullRotation me, tX1, tY1, tX2, tY2, tOffset1, tOffset2
  if tOffset1 = VOID then
    tOffset1 = point(0, 0)
  end if
  if tOffset2 = VOID then
    tOffset2 = point(0, 0)
  end if
  pSpriteList[3].loc = pOrigLocs[1] + tOffset1 + point(sin(pSin) * tX1, cos(pSin) * tY1)
  pSpriteList[6].loc = pOrigLocs[2] + tOffset2 + point(cos(pSin) * tX2, sin(pSin) * tY2)
  tLocs = [pSpriteList[3].loc + point(pSpriteList[3].width / 2.0 - 15, 0), pSpriteList[6].loc - point(pSpriteList[6].width / 2.0 - 10, 0)]
  pSpriteList[2].rect = rect(pSpriteList[2].rect[1], pSpriteList[2].rect[2], tLocs[1][1], tLocs[1][2])
  pSpriteList[5].rect = rect(tLocs[2][1], pSpriteList[5].rect[2], pSpriteList[5].rect[3], tLocs[2][2])
  return 1
end

on switchLights me, tStyle, tTime
  if the timer < pLightSwitchTimer + tTime * 60 then
    return 1
  end if
  pLightSwitchTimer = the timer
  tVisibleList = [pSpriteList[1].visible, pSpriteList[4].visible]
  case tStyle of
    #show1:
      repeat with i = 1 to tVisibleList.count
        tVisibleList[i] = not tVisibleList[i]
        tLightStart = (i - 1) * 3
        repeat with j = 1 to 6
          if j = tLightStart + 1 or j = tLightStart + 2 or j = tLightStart + 3 then
            pSpriteList[j].visible = tVisibleList[i]
          end if
        end repeat
      end repeat
    #blink:
      repeat with i = 1 to tVisibleList.count
        tVisibleList[i] = not tVisibleList[1]
      end repeat
      repeat with j = 1 to 6
        pSpriteList[j].visible = tVisibleList[1]
      end repeat
    #showAll:
      repeat with j = 1 to 6
        pSpriteList[j].visible = 1
      end repeat
  end case
end

on getSpriteList me
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return 0
  end if
  repeat with i = 1 to 2
    tSp1 = tObj.getSprById("disco_bulb_" & i)
    tSp2 = tObj.getSprById("disco_light_" & i)
    tSp3 = tObj.getSprById("disco_spot_" & i)
    if tSp1 < 1 or tSp2 < 1 or tSp3 < 1 then
      return 0
    end if
    pSpriteList.add(tSp1)
    pSpriteList.add(tSp2)
    pSpriteList.add(tSp3)
  end repeat
  pOrigLocs = [pSpriteList[3].loc, pSpriteList[6].loc]
  repeat with i = 1 to pSpriteList.count
    removeEventBroker(pSpriteList[i].spriteNum)
  end repeat
  me.createWallLights()
  return 1
end

on createWallLights me
  repeat with i = 1 to pWallLightCount
    pWallLightValues[i] = []
    pWallLightValues[i][1] = random(155)
    pWallLightValues[i][2] = random(100)
    pWallLightSprites[i] = sprite(reserveSprite(me.getID()))
    pWallLightSprites[i].ink = 32
    pWallLightSprites[i].blend = random(70)
    pWallLightSprites[i].locH = 64 + random(608 - 65)
    pWallLightSprites[i].member = getMember("lightspot_1")
  end repeat
  return me.rotateWallLights()
end

on rotateWallLights me
  repeat with i = 1 to pWallLightCount
    tDimValue = pWallLightValues[i][2]
    tDimValue = tDimValue + 0.19
    if tDimValue > 100 then
      tDimValue = 1
    end if
    pWallLightValues[i][2] = tDimValue
    tLocH = pWallLightSprites[i].locH
    tLocH = tLocH + 2
    if tLocH > 608 then
      tLocH = 65
      pWallLightSprites[i].flipH = 0
      pWallLightValues[i][1] = random(155)
    end if
    if tLocH > 353 then
      pWallLightSprites[i].flipH = 1
      tLocV = 38 + (tLocH - 353) * 0.5 + pWallLightValues[i][1]
    else
      tLocV = 38 + (353 - tLocH) * 0.5 + pWallLightValues[i][1]
    end if
    pWallLightSprites[i].loc = point(tLocH, tLocV)
    pWallLightSprites[i].blend = max(0, sin(tDimValue) * 60)
  end repeat
  return 1
end

on removeWallLights me
  repeat with tWallSprite in pWallLightSprites
    if tWallSprite.ilk = #sprite then
      releaseSprite(tWallSprite.spriteNum)
    end if
  end repeat
  return 1
end
