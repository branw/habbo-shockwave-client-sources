property pID, pMotherId, pType, pBuffer, pSprite, pPalette, pStrech, pLocX, pLocY, pWidth, pHeight, pDepth, pimage, pParams, pProps, pVisible

on new me
  return me
end

on define me, tProps
  pID = tProps[#id]
  pMotherId = tProps[#mother]
  pType = tProps[#type]
  pBuffer = tProps[#buffer]
  pSprite = tProps[#sprite]
  pPalette = tProps[#palette]
  pStrech = tProps[#strech]
  pLocX = tProps[#locH]
  pLocY = tProps[#locV]
  pWidth = tProps[#width]
  pHeight = tProps[#height]
  pProps = tProps
  pVisible = 1
  if voidp(pPalette) then
    pPalette = #systemMac
  else
    if stringp(pPalette) then
      pPalette = member(getResourceManager().getmemnum(pPalette))
    end if
  end if
  if voidp(pProps[#member]) then
    tMemNum = 0
  else
    tMemNum = getResourceManager().getmemnum(pProps[#member])
  end if
  if tMemNum > 0 and pType <> "image" then
    tMember = member(tMemNum)
    pDepth = tMember.image.depth
    pimage = tMember.image.duplicate()
    if pimage.paletteRef <> pPalette then
      pimage.paletteRef = pPalette
    end if
  else
    pDepth = the colorDepth
    pimage = image(1, 1, pDepth, pPalette)
  end if
  if me.pProps[#flipH] then
    me.flipH()
  end if
  if me.pProps[#flipV] then
    me.flipV()
  end if
  pParams = [:]
  if tProps[#blend] < 100 then
    pParams[#blend] = tProps[#blend]
  end if
  if tProps[#color] <> rgb(0, 0, 0) then
    pParams[#color] = tProps[#color]
  end if
  if tProps[#bgColor] <> rgb(255, 255, 255) then
    pParams[#bgColor] = tProps[#bgColor]
  end if
  if tProps[#ink] <> 0 then
    pParams[#ink] = tProps[#ink]
  end if
  if pParams.count = 0 then
    pParams = VOID
  end if
  return 1
end

on prepare me
end

on moveTo me, tLocX, tLocY
  pLocX = tLocX
  pLocY = tLocY
  me.render()
end

on moveBy me, tOffX, tOffY
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.render()
end

on resizeTo me, tX, tY
  tOffX = tX - pWidth
  tOffY = tY - pHeight
  return me.resizeBy(tOffX, tOffY)
end

on resizeBy me, tOffX, tOffY
  case pStrech of
    #moveH:
      pLocX = pLocX + tOffX
    #moveV:
      pLocY = pLocY + tOffY
    #strechH:
      pWidth = pWidth + tOffX
    #strechV:
      pHeight = pHeight + tOffY
    #centerH:
      pLocX = pLocX + tOffX / 2
    #centerV:
      pLocY = pLocY + tOffY / 2
    #center:
      pLocX = pLocX + tOffX / 2
    #moveHV:
      pLocX = pLocX + tOffX
      pLocY = pLocY + tOffY
    #strechHV:
      pWidth = pWidth + tOffX
      pHeight = pHeight + tOffY
    #moveHstrechV:
      pLocX = pLocX + tOffX
      pHeight = pHeight + tOffY
    #moveVstrechH:
      pLocY = pLocY + tOffY
      pWidth = pWidth + tOffX
    #centerHV:
      pLocX = pLocX + tOffX / 2
      pLocY = pLocY + tOffY / 2
  end case
  me.render()
end

on flipH me
  tImage = image(pimage.width, pimage.height, pimage.depth, pimage.paletteRef)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  me.pimage = tImage
end

on flipV me
  tImage = image(pimage.width, pimage.height, pimage.depth, pimage.paletteRef)
  tQuad = [point(0, pimage.height), point(pimage.width, pimage.height), point(pimage.width, 0), point(0, 0)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
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
      return pDepth
    #palette:
      return pPalette
  end case
  return 0
end

on render me
  tTargetRect = rect(pLocX, pLocY, pLocX + pWidth, pLocY + pHeight)
  tSourceRect = pimage.rect
  pBuffer.image.copyPixels(pimage, tTargetRect, tSourceRect, pParams)
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(0, 0, 255)
  end if
  tTargetRect = rect(pLocX, pLocY, pLocX + pWidth, pLocY + pHeight)
  pBuffer.image.draw(tTargetRect, [#shapeType: #rect, #color: tRGB])
end
