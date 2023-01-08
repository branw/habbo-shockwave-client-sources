property pChanges, pActive, pLineSprite1, pLineSprite2, pLinesOrigLocV, pCoverSprite, pGlowSprite, pNoiseSprite, pActiveEffect, pEffectCounter, pRandomEffectList, pMovedByUser

on prepare me, tdata
  if me.pSprList.count < 9 then
    return 0
  end if
  pRandomEffectList = [#noise1, #lines1, #lines1]
  removeEventBroker(me.pSprList[2].spriteNum)
  removeEventBroker(me.pSprList[3].spriteNum)
  removeEventBroker(me.pSprList[4].spriteNum)
  removeEventBroker(me.pSprList[5].spriteNum)
  removeEventBroker(me.pSprList[6].spriteNum)
  removeEventBroker(me.pSprList[7].spriteNum)
  pLineSprite1 = me.pSprList[2]
  pLineSprite2 = me.pSprList[3]
  pGlowSprite = me.pSprList[7]
  pCoverSprite = me.pSprList[8]
  pNoiseSprite = me.pSprList[9]
  pMovedByUser = 0
  me.hideAllEffects()
  if tdata[#stuffdata] = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  return 1
end

on prepareForMove me
  pLinesOrigLocV = VOID
  pMovedByUser = 1
end

on movingFinished me
  pMovedByUser = 0
end

on hideAllEffects me
  pLineSprite1.visible = 0
  pLineSprite2.visible = 0
  if not voidp(pLinesOrigLocV) then
    pLineSprite1.locV = pLinesOrigLocV[1]
    pLineSprite2.locV = pLinesOrigLocV[2]
  end if
  pNoiseSprite.visible = 0
  pActiveEffect = #none
  pEffectCounter = 0
end

on updateStuffdata me, tValue
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
  end if
  pChanges = 1
end

on update me
  if pMovedByUser then
    return 1
  end if
  if random(40) = 5 and pActiveEffect = #none then
    me.startRandomEffect()
  end if
  if pActiveEffect <> #none then
    me.runEffect()
  end if
  if not pChanges then
    return 
  end if
  if pLinesOrigLocV = VOID then
    pLinesOrigLocV = [pLineSprite1.locV, pLineSprite2.locV]
  end if
  if pActive then
    pGlowSprite.visible = 1
    pCoverSprite.visible = 0
  else
    pGlowSprite.visible = 0
    pCoverSprite.visible = 1
    me.hideAllEffects()
  end if
end

on startRandomEffect me
  pActiveEffect = pRandomEffectList[random(pRandomEffectList.count)]
  return 1
end

on runEffect me
  pEffectCounter = pEffectCounter + 1
  case pActiveEffect of
    #noise1:
      if random(6) = 5 then
        pNoiseSprite.visible = 0
      else
        pNoiseSprite.visible = 1
      end if
      if pEffectCounter > 5 then
        me.hideAllEffects()
      end if
    #lines1:
      if pEffectCounter mod 2 = 1 then
        return 1
      end if
      pLineSprite1.visible = 1
      pLineSprite2.visible = 1
      pLineSprite1.locV = pLineSprite1.locV + 1
      pLineSprite2.locV = pLineSprite2.locV + 1
      if pEffectCounter > 90 then
        me.hideAllEffects()
      end if
    #lines2:
      pLineSprite1.visible = 1
      pLineSprite2.visible = 1
      if pEffectCounter < 45 then
        pLineSprite1.locV = pLineSprite1.locV + 1
      else
        pLineSprite1.locV = pLineSprite1.locV - 1
      end if
      if pEffectCounter > 90 then
        me.hideAllEffects()
      end if
  end case
  return 1
end

on setOn me
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "ON"])
end

on setOff me
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "OFF"])
end

on select me
  if the doubleClick then
    if pActive then
      me.setOff()
    else
      me.setOn()
    end if
  end if
  return 1
end
