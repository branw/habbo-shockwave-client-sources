property pID, pElemList, pBuffer, pSprite, pPalette, pStrech, pStrechH, pStrechV, pLocX, pLocY, pWidth, pHeight, pVisible

on new me
  return me
end

on construct me
  pElemList = []
  pPalette = #systemMac
  pStrech = #fixed
  pStrechH = 0
  pStrechV = 0
  pLocX = 0
  pLocY = 0
  pWidth = 0
  pHeight = 0
  pVisible = 1
  return 1
end

on deconstruct me
  call(#deconstruct, pElemList)
  pElemList = []
  pBuffer = VOID
  pSprite = VOID
  return 1
end

on define me, tProps
  pID = tProps[#id]
  pBuffer = tProps[#buffer]
  pSprite = tProps[#sprite]
  pLocX = tProps[#locX]
  pLocY = tProps[#locY]
  pWidth = pBuffer.width
  pHeight = pBuffer.height
  pPalette = pBuffer.paletteRef
  return 1
end

on add me, tElement
  if not objectp(tElement) then
    return 0
  end if
  pElemList.add(tElement)
  tStrech = tElement.getProperty(#strech)
  if pElemList.count = 1 or pStrech = tStrech then
    pStrech = tStrech
  else
    if not pStrechH then
      if ([#strechH, #strechHV, #moveH, #moveHV, #moveHstrechV, #moveVstrechH, #centerH, #centerHV]).getOne(tStrech) then
        pStrechH = 1
      end if
    end if
    if not pStrechV then
      if ([#strechV, #strechHV, #moveV, #moveHV, #moveHstrechV, #moveVstrechH, #centerV, #centerHV]).getOne(tStrech) then
        pStrechV = 1
      end if
    end if
    if pStrech and pStrechV then
      pStrech = #strechHV
    else
      if pStrechH then
        pStrech = #strechH
      else
        if pStrechV then
          pStrech = #strechV
        end if
      end if
    end if
  end if
  return 1
end

on show me
  pVisible = 1
  pSprite.visible = 1
  return 1
end

on hide me
  pVisible = 0
  pSprite.visible = 0
  return 1
end

on moveTo me, tLocX, tLocY
  call(#moveTo, pElemList, tLocX, tLocY)
end

on moveBy me, tOffX, tOffY
  call(#moveBy, pElemList, tOffX, tOffY)
end

on resizeBy me, tOffX, tOffY
  if pStrechH then
    pWidth = pWidth + tOffX
    if pWidth < 1 then
      pWidth = 1
    end if
  else
    tOffX = 0
  end if
  if pStrechV then
    pHeight = pHeight + tOffY
    if pHeight < 1 then
      pHeight = 1
    end if
  else
    tOffY = 0
  end if
  if tOffX <> 0 or tOffY <> 0 then
    pBuffer.image = image(pWidth, pHeight, pBuffer.image.depth, pPalette)
    pBuffer.regPoint = point(0, 0)
    pSprite.width = pWidth
    pSprite.height = pHeight
    call(#resizeBy, pElemList, tOffX, tOffY)
  end if
end

on getProperty me, tProp
  case tProp of
    #buffer:
      return pBuffer
    #sprite:
      return pSprite
    #width:
      return pWidth
    #height:
      return pHeight
    #locX:
      return pLocX
    #locY:
      return pLocY
    #strech:
      return pStrech
    #depth:
      return pBuffer.image.depth
    #palette:
      return pPalette
    #visible:
      return pVisible
  end case
  return 0
end

on prepare me
  call(#prepare, pElemList)
end

on render me
  if pVisible then
    call(#render, pElemList)
  end if
end

on draw me, tRGB
  call(#draw, pElemList, tRGB)
end
