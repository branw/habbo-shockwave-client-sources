property pState, pClientID, pAgentID, pButtonImg, pParts, pCasts, pRects, pScrollOffset, pViewClientRect, pClientSourceRect, pScrollStep, pButtonStates, pMaxOffset, pPageSize, pClickPoint, pClickPass

on new me
  return me
end

on deconstruct me
  removeObject(pAgentID)
  return 1
end

on define me, tProps
  tField = tProps[#type] & tProps[#model] & ".element"
  tDesc = getObject(#layout_parser).parse(tField)
  pParts = tDesc[#props]
  pCasts = tDesc[#casts]
  me.pProps = tProps
  me.pID = tProps[#id]
  me.pMotherId = tProps[#mother]
  me.pType = tProps[#type]
  me.pStrech = tProps[#strech]
  me.pBuffer = tProps[#buffer]
  me.pSprite = tProps[#sprite]
  me.pLocX = me.pSprite.left
  me.pLocY = me.pSprite.top
  me.pWidth = tProps[#width]
  me.pHeight = tProps[#height]
  me.pPalette = VOID
  pClientID = tProps[#client]
  pScrollStep = tProps[#offset]
  pButtonImg = [:]
  if voidp(me.pPalette) then
    if variableExists("interface.palette") then
      me.pPalette = member(getmemnum(getVariable("interface.palette")))
    else
      me.pPalette = #systemMac
    end if
  else
    if stringp(me.pPalette) then
      me.pPalette = member(getmemnum(me.pPalette))
    end if
  end if
  pRects = [:]
  pState = #waitMouseEvent
  pScrollOffset = 0
  pButtonStates = [#top: #up, #bottom: #up, #bar: #up, #lift: #up]
  me.UpdateImageObjects(VOID, [#up, #down, #passive])
  if me.pType = "scrollbarv" then
    me.pWidth = pButtonImg["top_up"].width
  else
    me.pHeight = pButtonImg["top_up"].height
  end if
  me.pimage = image(me.pWidth, me.pHeight, 8, me.pPalette)
  me.UpdateScrollBar([#top, #bottom, #bar, #lift], #up)
  tTempOffset = me.pBuffer.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  pAgentID = me.getID() && the milliSeconds
  createObject(pAgentID, getClassVariable("event.agent.class"))
  return 1
end

on prepare me
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  me.pSprite.width = me.pWidth
  me.pSprite.height = me.pHeight
  me.pSprite.loc = point(me.pLocX, me.pLocY)
  call(#registerScroll, [getWindow(me.pMotherId).getElement(pClientID)], me.pID)
end

on getProperty me, tProp
  case tProp of
    #width:
      return me.pWidth
    #height:
      return me.pHeight
    #locX:
      return 0
    #locY:
      return 0
    #offset:
      return pScrollOffset
  end case
  return 0
end

on getScrollOffset me
  return pScrollOffset
end

on setScrollOffset me, tOffset
  me.sendAdjustOffsetTo(tOffset)
  me.UpdateLiftPosition()
  me.ButtonsStates()
  return 1
end

on updateData me, tViewClientRect, tClientSourceRect
  pViewClientRect = tViewClientRect
  pClientSourceRect = tClientSourceRect
  if me.pType = "scrollbarv" then
    if pViewClientRect.height mod pScrollStep <> 0 then
      pViewClientRect.bottom = pViewClientRect.bottom - pViewClientRect.height mod pScrollStep + pScrollStep
    end if
    if pViewClientRect.height > pClientSourceRect.height then
      pScrollOffset = 0
    end if
    pMaxOffset = pClientSourceRect.height - pViewClientRect.height
    pPageSize = pViewClientRect.height
  else
    if pViewClientRect.width mod pScrollStep <> 0 then
      pViewClientRect.right = pViewClientRect.right - pViewClientRect.width mod pScrollStep + pScrollStep
    end if
    if pViewClientRect.width > pClientSourceRect.width then
      pScrollOffset = 0
    end if
    pMaxOffset = pClientSourceRect.width - pViewClientRect.width
    pPageSize = pViewClientRect.width
  end if
  me.sendAdjustOffsetTo(pScrollOffset)
  me.ButtonsStates()
end

on ScrollBarPercentV me
  tHeight = float(pClientSourceRect.height - pViewClientRect.height)
  if tHeight = 0 then
    return 0
  else
    tPercent = float(pScrollOffset) / tHeight
    if tPercent > 1.0 then
      return 1.0
    else
      return tPercent
    end if
  end if
end

on ScrollBarPercentH me
  tWidth = float(pClientSourceRect.width - pViewClientRect.width)
  if tWidth = 0 then
    return 0
  else
    tPercent = float(pScrollOffset) / tWidth
    if tPercent > 1.0 then
      return 1.0
    else
      return tPercent
    end if
  end if
end

on mouseDown me
  if me.pSprite.blend < 100 then
    return 0
  end if
  pClickPass = 1
  pClickPoint = the mouseLoc
  me.ScrollBarMouseEvent(#down)
  me.render()
  return 1
end

on mouseUp me
  me.initEventAgent(0)
  if me.pSprite.blend < 100 then
    return 0
  end if
  if pClickPass = 0 then
    return 0
  end if
  pClickPass = 0
  me.ScrollBarMouseEvent(#up)
  pState = #waitMouseEvent
  me.ButtonsStates()
  me.render()
  return 1
end

on mouseWithin me
  if pState = #lift then
    tMouseH = the mouseH
    tMouseV = the mouseV
    if me.pType = "scrollbarv" then
      if tMouseV > me.pSprite.bottom - pRects[#bottom].height then
        tMouseV = me.pSprite.bottom - pRects[#bottom].height
      else
        if tMouseV < me.pSprite.top + pRects[#top].height then
          tMouseV = me.pSprite.top + pRects[#top].height
        end if
      end if
      tNewLocV = pClickPoint.locV - tMouseV
      tNewLiftRect = pRects[#lift] - rect(0, tNewLocV, 0, tNewLocV)
      if tNewLiftRect.bottom > pRects[#bottom].top then
        tNewLiftRect = pButtonImg[#lift_up].rect + rect(0, pRects[#bottom].top - pRects[#lift].height, 0, pRects[#bottom].top - pRects[#lift].height)
      end if
      if tNewLiftRect.top < pRects[#top].bottom then
        tNewLiftRect = pButtonImg[#lift_up].rect + rect(0, pRects[#top].height, 0, pRects[#top].height)
      end if
    else
      if tMouseH > me.pSprite.right - pRects[#bottom].left then
        tMouseH = me.pSprite.right - pRects[#bottom].left
      else
        if tMouseH < me.pSprite.left + pRects[#top].right then
          tMouseH = me.pSprite.left + pRects[#top].right
        end if
      end if
      tNewLocH = pClickPoint.locH - tMouseH
      tNewLiftRect = pRects[#lift] - rect(tNewLocH, 0, tNewLocH, 0)
      if tNewLiftRect.right > pRects[#bottom].left then
        tNewLiftRect = pButtonImg[#lift_up].rect + rect(pRects[#bottom].left - pRects[#lift].width, 0, pRects[#bottom].left - pRects[#lift].width, 0)
      end if
      if tNewLiftRect.left < pRects[#top].right then
        newLIftRect = pButtonImg[#lift_up].rect + rect(pRects[#top].width, 0, pRects[#top].width, 0)
      end if
    end if
    pRects[#lift] = tNewLiftRect
    me.UpdateScrollBar([#bar], #up)
    me.UpdateScrollBar([#lift], #down)
    me.ScrollByLift()
    me.ButtonsStates()
    pClickPoint = point(tMouseH, tMouseV)
  else
    if pState = #top or pState = #bottom then
      me.ScrollBarMouseEvent(#down)
      me.ButtonsStates()
    end if
  end if
end

on mouseUpOutSide me
  if me.pSprite.blend < 100 then
    return 0
  end if
  pClickPass = 0
  pState = #waitMouseEvent
  me.ButtonsStates()
  me.render()
  return 0
end

on UpdateLiftPosition me
  if me.pType = "scrollbarv" then
    tMoveAreaV = pRects[#bar].height - pRects[#lift].height
    tNewOffset = integer(me.ScrollBarPercentV() * tMoveAreaV)
    pRects[#lift] = rect(0, tNewOffset + pRects[#top].height, pRects[#lift].width, tNewOffset + pRects[#top].height + pRects[#lift].height)
  else
    tMoveAreaV = pRects[#bar].width - pRects[#lift].width
    tNewOffset = integer(me.ScrollBarPercentH() * tMoveAreaV)
    pRects[#lift] = rect(tNewOffset + pRects[#top].width, 0, tNewOffset + pRects[#top].width + pRects[#lift].width, pRects[#lift].height)
  end if
end

on ScrollByLift me
  if me.pType = "scrollbarv" then
    tMoveAreaV = pRects[#bar].height - pRects[#lift].height
    tScrollPercent = (pRects[#lift].top - pRects[#lift].height + 1) * 100 / tMoveAreaV
    tNowPercent = float(tScrollPercent) / 100
    tNowOffset = integer((pClientSourceRect.bottom - pViewClientRect.height) * float(tScrollPercent) / 100)
  else
    tMoveAreaH = pRects[#bar].width - pRects[#lift].width
    tScrollPercent = (pRects[#lift].left - pRects[#lift].width + 1) * 100 / tMoveAreaH
    tNowPercent = float(tScrollPercent) / 100
    tNowOffset = integer((pClientSourceRect.right - pViewClientRect.width) * float(tScrollPercent) / 100)
  end if
  if tNowOffset mod pScrollStep <> 0 then
    tNowOffset = tNowOffset - tNowOffset mod pScrollStep
  end if
  me.sendAdjustOffsetTo(tNowOffset)
end

on sendAdjustOffsetTo me, tNewOffset
  if tNewOffset <= pMaxOffset then
    pScrollOffset = tNewOffset
  else
    pScrollOffset = pMaxOffset
  end if
  if tNewOffset <= 0 then
    pScrollOffset = 0
  end if
  if me.pType = "scrollbarv" then
    call(#setOffsetY, [getWindow(me.pMotherId).getElement(pClientID)], pScrollOffset)
  else
    call(#setOffsetX, [getWindow(me.pMotherId).getElement(pClientID)], pScrollOffset)
  end if
end

on UpdateImageObjects me, tPalette, tListStates
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat with f in [#top, #lift, #bottom, #bar]
    repeat with i in tListStates
      tDesc = pParts[i][#members][f]
      if not voidp(tDesc) then
        tMember = member(tDesc[#member], pCasts[tDesc[#cast]])
        if not voidp(tDesc[#palette]) then
          me.pPalette = member(getmemnum(tDesc[#palette]))
        else
          me.pPalette = tPalette
        end if
        tImage = tMember.image.duplicate()
        if tDesc[#flipH] then
          tImage = me.flipH(tImage)
        end if
        if tDesc[#flipV] then
          tImage = me.flipV(tImage)
        end if
        if not voidp(tDesc[#rotate]) then
          tImage = me.rotateImg(tImage, tDesc[#rotate])
        end if
        pButtonImg.addProp(symbol(f & "_" & i), tImage)
      end if
    end repeat
    me.DefineRects(f)
  end repeat
  return tPalette
end

on DefineRects me, tElementPart
  if me.pType = "scrollbarv" then
    tRect = pButtonImg[tElementPart & "_up"].rect
    case tElementPart of
      #lift:
        tRect = tRect + rect(0, pButtonImg["top_up"].height, 0, pButtonImg["top_up"].height)
      #bottom:
        tRect = tRect + rect(0, me.pHeight - pButtonImg["bottom_up"].height, 0, me.pHeight - pButtonImg["bottom_up"].height)
      #bar:
        tRect = tRect + rect(0, pButtonImg[#top_up].height, 0, me.pHeight - pButtonImg[#bottom_up].height - 1)
    end case
    pRects.addProp(tElementPart, tRect)
  else
    tRect = pButtonImg[tElementPart & "_up"].rect
    case tElementPart of
      #lift:
        tRect = tRect + rect(pButtonImg["top_up"].width, 0, pButtonImg["top_up"].width, 0)
      #bottom:
        tRect = tRect + rect(me.pWidth - pButtonImg["bottom_up"].width, 0, me.pWidth - pButtonImg["bottom_up"].width, 0)
      #bar:
        tRect = tRect + rect(pButtonImg[#top_up].width, 0, me.pWidth - pButtonImg[#bottom_up].width - 1, 0)
    end case
    pRects.addProp(tElementPart, tRect)
  end if
end

on DrawSpecificRect me, tdestrect, tElementPart, tState
  tImgPropName = tElementPart & "_" & tState
  me.pimage.copyPixels(pButtonImg.getProp(tImgPropName), tdestrect, pButtonImg.getProp(tImgPropName).rect)
end

on UpdateScrollBar me, tElementPartList, tState
  repeat with f in tElementPartList
    tDstRect = pRects[f]
    tImgPropName = f & "_" & tState
    me.pimage.copyPixels(pButtonImg.getProp(tImgPropName), tDstRect, pButtonImg.getProp(tImgPropName).rect, [#ink: 36])
  end repeat
end

on ScrollBarMouseEvent me, tState
  if pButtonStates[#top] = #passive and pButtonStates[#bottom] = #passive then
    return 
  end if
  if pState = #lift then
    me.UpdateScrollBar([#bar, #lift], #up)
    pButtonStates[#lift] = #up
    return 
  end if
  tClickbutton = me.buttonOfClickArea(pClickPoint)
  if voidp(tClickbutton) then
    return 
  end if
  if pButtonStates[tClickbutton] = #passive then
    return 
  end if
  pButtonStates[tClickbutton] = tState
  pState = symbol(tClickbutton)
  if tClickbutton = #top or tClickbutton = #bottom then
    me.UpdateScrollBar([tClickbutton], tState)
    if tClickbutton = #top then
      me.sendAdjustOffsetTo(pScrollOffset - pScrollStep)
    else
      me.sendAdjustOffsetTo(pScrollOffset + pScrollStep)
    end if
    me.UpdateLiftPosition()
    me.UpdateScrollBar([#bar, #lift], #up)
  else
    if tClickbutton = #lift then
      me.UpdateScrollBar([#bar], #up)
      me.UpdateScrollBar([#lift], tState)
      me.initEventAgent(1)
    else
      if tClickbutton = #bar and tState = #down then
        tUpPageUp = 0
        me.UpdateLiftPosition()
        if me.pType = "scrollbarv" then
          if pClickPoint.locV - me.pSprite.locV <= pRects[#lift].top then
            tUpPageUp = 1
          end if
        else
          if pClickPoint.locH - me.pSprite.locH <= pRects[#lift].left then
            tUpPageUp = 1
          end if
        end if
        if me.pType = "scrollbarv" then
          if tUpPageUp then
            me.sendAdjustOffsetTo(pScrollOffset - pPageSize)
            tTop = pRects[#lift].bottom
            tBottom = pRects[#bottom].top
          else
            me.sendAdjustOffsetTo(pScrollOffset + pPageSize)
            tTop = pRects[#top].bottom
            tBottom = pRects[#lift].top
          end if
          me.UpdateScrollBar([#bar], tState)
          me.DrawSpecificRect(rect(0, tTop, pRects[#bar].width, tBottom), #bar, #up)
        else
          if tUpPageUp then
            me.sendAdjustOffsetTo(pScrollOffset - pPageSize)
            tLeft = pRects[#lift].right
            tRight = pRects[#bottom].left
          else
            me.sendAdjustOffsetTo(pScrollOffset + pPageSize)
            tLeft = pRects[#top].right
            tRight = pRects[#lift].left
          end if
          me.UpdateScrollBar([#bar], tState)
          me.DrawSpecificRect(rect(tLeft, 0, tRight, pRects[#bar].height), #bar, #up)
        end if
        me.UpdateScrollBar([#lift], #up)
      end if
    end if
  end if
end

on ButtonsStates me
  if pScrollOffset > 0 and pButtonStates[#top] <> #up and pState <> #top then
    pButtonStates[#top] = #up
    me.UpdateScrollBar([#top], #up)
  else
    if pScrollOffset <= 0 and pButtonStates[#top] <> #passive then
      pButtonStates[#top] = #passive
      me.UpdateScrollBar([#top], #passive)
    end if
  end if
  if pScrollOffset < pMaxOffset and pButtonStates[#bottom] <> #up and pState <> #bottom then
    pButtonStates[#bottom] = #up
    me.UpdateScrollBar([#bottom], #up)
  else
    if pScrollOffset >= pMaxOffset and pButtonStates[#bottom] <> #passive then
      pButtonStates[#bottom] = #passive
      me.UpdateScrollBar([#bottom], #passive)
    end if
  end if
  if pButtonStates[#top] = #passive and pButtonStates[#bottom] = #passive then
    pButtonStates[#lift] = #passive
    me.UpdateScrollBar([#bar], #up)
    me.UpdateScrollBar([#lift], #passive)
  else
    if pState <> #lift then
      pButtonStates[#lift] = #up
      me.UpdateLiftPosition()
      me.UpdateScrollBar([#bar, #lift], #up)
    end if
  end if
  me.render()
end

on buttonOfClickArea me, tpoint
  tpoint = tpoint - point(me.pSprite.left, me.pSprite.top)
  repeat with r = 1 to pRects.count()
    if tpoint.inside(pRects[r]) then
      return pRects.getPropAt(r)
      exit repeat
    end if
  end repeat
end

on initEventAgent me, tBoolean
  tAgent = getObject(pAgentID)
  if tBoolean then
    tAgent.registerEvent(me, #mouseUp, #mouseUp)
    tAgent.registerEvent(me, #mouseWithin, #mouseWithin)
  else
    tAgent.unregisterEvent(#mouseUp)
    tAgent.unregisterEvent(#mouseWithin)
  end if
end

on resizeBy me, tOffX, tOffY
  if tOffX <> 0 or tOffY <> 0 then
    case me.pStrech of
      #moveH:
        me.pSprite.locH = me.pSprite.locH + tOffX
      #moveV:
        me.pSprite.locV = me.pSprite.locV + tOffY
      #moveHV:
        me.pSprite.loc = me.pSprite.loc + [tOffX, tOffY]
      #strechH:
        me.pSprite.width = me.pSprite.width + tOffX
      #strechV:
        me.pSprite.height = me.pSprite.height + tOffY
      #centerH:
        me.pSprite.locH = me.pSprite.locH + tOffX / 2
      #centerV:
        me.pSprite.locV = me.pSprite.locV + tOffY / 2
      #strechHV:
        me.pSprite.width = me.pSprite.width + tOffX
        me.pSprite.height = me.pSprite.height + tOffY
      #moveHstrechV:
        me.pSprite.locH = me.pSprite.locH + tOffX
        me.pSprite.height = me.pSprite.height + tOffY
      #moveVstrechH:
        me.pSprite.locV = me.pSprite.locV + tOffY
        me.pSprite.width = me.pSprite.width + tOffX
      #centerHV:
        me.pSprite.locH = me.pSprite.locH + tOffX / 2
        me.pSprite.locV = me.pSprite.locV + tOffY / 2
        me.pSprite.width = me.pSprite.width + tOffX
        me.pSprite.height = me.pSprite.height + tOffY
    end case
    pRects = [:]
    pState = #waitMouseEvent
    pScrollOffset = 0
    pButtonStates = [#top: #up, #bottom: #up, #bar: #up, #lift: #up]
    me.UpdateImageObjects(VOID, [#up, #down, #passive])
    if me.pType = "scrollbarv" then
      me.pWidth = pButtonImg["top_up"].width
      me.pHeight = me.pSprite.height
    else
      me.pWidth = me.pSprite.width
      me.pHeight = pButtonImg["top_up"].height
    end if
    me.pimage = image(me.pWidth, me.pHeight, 8, me.pPalette)
    me.UpdateScrollBar([#top, #bottom, #bar, #lift], #up)
    tTempOffset = me.pBuffer.regPoint
    me.pBuffer.image = me.pimage
    me.pBuffer.regPoint = tTempOffset
  end if
end

on flipH me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on flipV me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on rotateImg me, tImg, tDirection
  tImage = image(tImg.height, tImg.width, tImg.depth)
  tQuad = [point(0, 0), point(tImg.height, 0), point(tImg.height, tImg.width), point(0, tImg.width)]
  tQuad = me.RotateQuad(tQuad, tDirection)
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on RotateQuad me, tDestquad, tClockwise
  tPoint1 = tDestquad[1]
  tPoint2 = tDestquad[2]
  tPoint3 = tDestquad[3]
  tPoint4 = tDestquad[4]
  if tClockwise then
    return [tPoint2, tPoint3, tPoint4, tPoint1]
  else
    return [tPoint4, tPoint1, tPoint2, tPoint3]
  end if
end
