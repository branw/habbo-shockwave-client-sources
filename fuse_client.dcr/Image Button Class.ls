on new me
  return me
end

on prepare me
  me.pBlend = me.pProps[#blend]
  me.pButtonImg = [:]
  if voidp(me.pFixedSize) then
    me.pFixedSize = 0
  end if
  tTemp = the itemDelimiter
  the itemDelimiter = "."
  tMemName = me.pProps[#member]
  tMemName = tMemName.item[1..tMemName.item.count - 1]
  the itemDelimiter = tTemp
  me.UpdateImageObjects(VOID, #up, tMemName)
  me.UpdateImageObjects(VOID, #down, tMemName)
  me.pimage = me.createButtonImg(#up)
  tTempOffset = me.pSprite.member.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pWidth = me.pimage.width
  me.pHeight = me.pimage.height
  me.pSprite.width = me.pWidth
  me.pSprite.height = me.pHeight
  return 1
end

on mouseDown me
  if me.pBlend < 100 then
    return 0
  end if
  me.pClickPass = 1
  me.pimage = me.createButtonImg(#down)
  me.render()
  return 1
end

on mouseUp me
  if me.pBlend < 100 then
    return 0
  end if
  if me.pClickPass = 0 then
    return 0
  end if
  me.pClickPass = 0
  me.pimage = me.createButtonImg(#up)
  me.render()
  return 1
end

on mouseUpOutSide me
  if me.pBlend < 100 then
    return 0
  end if
  me.pClickPass = 0
  me.pimage = me.createButtonImg(#up)
  me.render()
  return 0
end

on UpdateImageObjects me, tPalette, tState, tMemName
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  if tState = #up then
    tMemName = tMemName & ".active"
  else
    if tState = #down then
      tMemName = tMemName & ".pressed"
    end if
  end if
  tMemNum = getmemnum(tMemName)
  if tMemNum = 0 then
    return error(me, "Member not found:" && tMemName, #UpdateImageObjects)
  end if
  tMember = member(tMemNum)
  tImage = tMember.image.duplicate()
  if tImage.paletteRef <> tPalette then
    tImage.paletteRef = tPalette
  end if
  me.pButtonImg.addProp(symbol(tState), tImage)
end

on createButtonImg me, tState
  return me.pButtonImg.getProp(tState)
end
