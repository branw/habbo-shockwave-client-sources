property pID, pMotherId, pType, pBuffer, pSprite, pPalette, pStrech, pLocX, pLocY, pWidth, pHeight, pVisible, pDepth, pimage, pParams, pProps

on new me
  return me
end

on define me, tProps
  pID = tProps[#id]
  pMotherId = tProps[#mother]
  pType = tProps[#type]
  pStrech = tProps[#strech]
  pBuffer = tProps[#buffer]
  pSprite = tProps[#sprite]
  pLocX = pSprite.left
  pLocY = pSprite.top
  pWidth = tProps[#width]
  pHeight = tProps[#height]
  pPalette = tProps[#palette]
  pProps = tProps
  pDepth = the colorDepth
  if voidp(pPalette) then
    pPalette = #systemMac
  else
    if stringp(pPalette) then
      pPalette = member(getResourceManager().getmemnum(pPalette))
    end if
  end if
  pVisible = 1
  tMemNum = getResourceManager().getmemnum(pProps[#member])
  if tMemNum > 0 and pType <> "image" then
    tMember = member(tMemNum)
    if tMember.type = #bitmap then
      pimage = tMember.image.duplicate()
      pDepth = tMember.image.depth
      if pimage.paletteRef <> pPalette then
        pimage.paletteRef = pPalette
      end if
    end if
  else
    pDepth = the colorDepth
    pimage = image(1, 1, pDepth, pPalette)
  end if
  if pProps[#flipH] then
    me.flipH()
  end if
  if pProps[#flipV] then
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
  pSprite.loc = point(tLocX, tLocY)
end

on moveBy me, tOffX, tOffY
  pSprite.loc = pSprite.loc + [tOffX, tOffY]
end

on resizeTo me, tX, tY
  tOffX = tX - pSprite.width
  tOffY = tY - pSprite.height
  return me.resizeBy(tOffX, tOffY)
end

on resizeBy me, tOffX, tOffY
  if tOffX <> 0 or tOffY <> 0 then
    case pStrech of
      #moveH:
        pSprite.locH = pSprite.locH + tOffX
      #moveV:
        pSprite.locV = pSprite.locV + tOffY
      #moveHV:
        pSprite.loc = pSprite.loc + [tOffX, tOffY]
      #strechH:
        pSprite.width = pSprite.width + tOffX
      #strechV:
        pSprite.height = pSprite.height + tOffY
      #centerH:
        pSprite.locH = pSprite.locH + tOffX / 2
      #centerV:
        pSprite.locV = pSprite.locV + tOffY / 2
      #center:
        pSprite.locH = pSprite.locH + tOffX / 2
      #strechHV:
        pSprite.width = pSprite.width + tOffX
        pSprite.height = pSprite.height + tOffY
      #moveHstrechV:
        pSprite.locH = pSprite.locH + tOffX
        pSprite.height = pSprite.height + tOffY
      #moveVstrechH:
        pSprite.locV = pSprite.locV + tOffY
        pSprite.width = pSprite.width + tOffX
      #centerHV:
        pSprite.locH = pSprite.locH + tOffX / 2
        pSprite.locV = pSprite.locV + tOffY / 2
        pSprite.width = pSprite.width + tOffX
        pSprite.height = pSprite.height + tOffY
    end case
    pWidth = pSprite.width
    pHeight = pSprite.height
    me.render()
  end if
end

on flipH me
  tImage = image(pimage.width, pimage.height, pimage.depth)
  tQuad = [point(pimage.width, 0), point(0, 0), point(0, pimage.height), point(pimage.width, pimage.height)]
  tImage.copyPixels(pimage, tQuad, pimage.rect)
  pimage = tImage
end

on flipV me
  tImage = image(pimage.width, pimage.height, pimage.depth)
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
      return pSprite.width
    #height:
      return pSprite.height
    #locX:
      return pSprite.locH
    #locY:
      return pSprite.locV
    #strech:
      return pStrech
    #depth:
      return pimage.depth
    #palette:
      return pPalette
    #visible:
      return pVisible
    #blend:
      return pSprite.blend
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #width:
      me.resizeTo(tValue, pHeight)
    #height:
      me.resizeTo(pWidth, tValue)
    #locX:
      me.moveTo(tValue, pSprite.locV)
    #locY:
      me.moveTo(pSprite.locH, tValue)
    #strech:
      pStrech = tValue
    #depth:
      pDepth = tValue
      tImage = pimage.duplicate()
      pimage = image(pimage.width, pimage.height, pDepth)
      pimage.copyPixels(tImage, tImage.rect, tImage.rect)
      pimage.paletteRef = pPalette
    #palette:
      pPalette = tValue
      pimage.paletteRef = pPalette
    #visible:
      if tValue = 1 then
        me.show()
      else
        me.hide()
      end if
    #blend:
      pSprite.blend = tValue
  end case
  return 0
  return 1
end

on render me
  pBuffer.image.copyPixels(pimage, pBuffer.image.rect, pimage.rect, pParams)
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pBuffer.image.draw(pBuffer.image.rect, [#shapeType: #rect, #color: tRGB])
end
