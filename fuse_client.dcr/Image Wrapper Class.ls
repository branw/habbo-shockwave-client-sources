property pOwnX, pOwnY, pOwnW, pOwnH, pOffX, pOffY, pScrolls

on new me
  return me
end

on prepare me
  pOffX = 0
  pOffY = 0
  pOwnW = me.pProps[#width]
  pOwnH = me.pProps[#height]
  pScrolls = []
  me.pimage = image(1, 1, the colorDepth)
  if me.pProps[#style] = #unique then
    pOwnX = 0
    pOwnY = 0
  else
    pOwnX = me.pProps[#locH]
    pOwnY = me.pProps[#locV]
  end if
  if me.pProps[#flipH] then
    me.flipH()
  end if
  if me.pProps[#flipV] then
    me.flipV()
  end if
  return 1
end

on feedImage me, tImage
  if not ilk(tImage, #image) then
    return error(me, "Image object expected!" && tImage, #feedImage)
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  me.pBuffer.image.fill(tTargetRect, me.pProps[#bgColor])
  me.pimage = tImage
  me.render()
  me.registerScroll()
  return 1
end

on clearImage me
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  return me.pBuffer.image.fill(tTargetRect, me.pProps[#bgColor])
end

on registerScroll me, tid
  if voidp(pScrolls) then
    me.prepare()
  end if
  if not voidp(tid) then
    if pScrolls.getPos(tid) = 0 then
      pScrolls.add(tid)
    end if
  else
    if pScrolls.count = 0 then
      return 0
    end if
  end if
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  tScrollList = []
  repeat with tScrollId in pScrolls
    tScrollList.add(getWindowManager().get(me.pMotherId).getElement(tScrollId))
  end repeat
  call(#updateData, tScrollList, tSourceRect, me.pimage.rect)
end

on adjustOffsetTo me, tX, tY
  pOffX = tX
  pOffY = tY
  me.clearImage()
  me.render()
end

on adjustOffsetBy me, tOffX, tOffY
  pOffX = pOffX + tOffX
  pOffY = pOffY + tOffY
  me.clearImage()
  me.render()
end

on adjustXOffsetTo me, tX
  me.adjustOffsetTo(tX, pOffY)
end

on adjustYOffsetTo me, tY
  me.adjustOffsetTo(pOffX, tY)
end

on setOffsetX me, tX
  me.adjustOffsetTo(tX, pOffY)
end

on setOffsetY me, tY
  me.adjustOffsetTo(pOffX, tY)
end

on getOffsetX me
  return pOffX
end

on getOffsetY me
  return pOffY
end

on resizeBy me, tOffX, tOffY
  if tOffX <> 0 or tOffY <> 0 then
    if me.pProps[#style] = #unique then
      case me.pStrech of
        #moveH:
          me.pLocX = me.pLocX + tOffX
        #moveV:
          me.pLocY = me.pLocY + tOffY
        #strechH:
          me.pWidth = me.pWidth + tOffX
        #strechV:
          me.pHeight = me.pHeight + tOffY
        #centerH:
          me.pLocX = me.pLocX + tOffX / 2
        #centerV:
          me.pLocY = me.pLocY + tOffY / 2
        #moveHV:
          me.pLocX = me.pLocX + tOffX
          me.pLocY = me.pLocY + tOffY
        #strechHV:
          me.pWidth = me.pWidth + tOffX
          me.pHeight = me.pHeight + tOffY
        #moveHstrechV:
          me.pLocX = me.pLocX + tOffX
          me.pHeight = me.pHeight + tOffY
        #moveVstrechH:
          me.pLocY = me.pLocY + tOffY
          me.pWidth = me.pWidth + tOffX
        #centerHV, #center:
          me.pLocX = me.pLocX + tOffX / 2
          me.pLocY = me.pLocY + tOffY / 2
          me.pWidth = me.pWidth + tOffX
          me.pHeight = me.pHeight + tOffY
      end case
      pOwnW = me.pWidth
      pOwnH = me.pHeight
      me.pBuffer.image = image(pOwnW, pOwnH, me.pDepth)
      me.pBuffer.regPoint = point(0, 0)
      me.pSprite.width = pOwnW
      me.pSprite.height = pOwnH
    else
      case me.pStrech of
        #moveH:
          pOwnX = pOwnX + tOffX
        #moveV:
          pOwnY = pOwnY + tOffY
        #strechH:
          pOwnW = pOwnW + tOffX
        #strechV:
          pOwnH = pOwnH + tOffY
        #centerH:
          pOwnX = pOwnX + tOffX / 2
        #centerV:
          pOwnY = pOwnY + tOffY / 2
        #moveHV:
          pOwnX = pOwnX + tOffX
          pOwnY = pOwnY + tOffY
        #strechHV:
          pOwnW = pOwnW + tOffX
          pOwnH = pOwnH + tOffY
        #moveHstrechV:
          pOwnX = pOwnX + tOffX
          pOwnH = pOwnH + tOffY
        #moveVstrechH:
          pOwnY = pOwnY + tOffY
          pOwnW = pOwnW + tOffX
        #centerHV, #center:
          pOwnX = pOwnX + tOffX / 2
          pOwnY = pOwnY + tOffY / 2
          pOwnW = pOwnW + tOffX
          pOwnH = pOwnH + tOffY
      end case
    end if
    me.registerScroll()
    me.render()
  end if
end

on render me
  if not me.pVisible then
    return 
  end if
  tTargetRect = rect(pOwnX, pOwnY, pOwnX + pOwnW, pOwnY + pOwnH)
  tSourceRect = rect(pOffX, pOffY, pOffX + pOwnW, pOffY + pOwnH)
  me.pBuffer.image.copyPixels(me.pimage, tTargetRect, tSourceRect, me.pParams)
end

on mouseDown me
  return point(the mouseH - me.pSprite.locH + pOwnX + pOffX, the mouseV - me.pSprite.locV + pOwnY + pOffY)
end

on mouseUp me
  return point(the mouseH - me.pSprite.locH + pOwnX + pOffX, the mouseV - me.pSprite.locV + pOwnY + pOffY)
end
