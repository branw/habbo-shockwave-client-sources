on new me
  return me
end

on feedImage me, tImage
  me.pimage = tImage
  me.render()
end

on moveTo me, tX, tY
  me.pLocX = tX
  me.pLocY = tY
  me.render()
end

on moveBy me, tX, tY
  me.pLocX = me.pLocX + tX
  me.pLocY = me.pLocY + tY
  me.render()
end

on resizeTo me, tX, tY
  tOffX = tX - me.pWidth
  tOffY = tY - me.pHeight
  return me.resizeBy(tOffX, tOffY)
end

on resizeBy me, tOffX, tOffY
  if tOffX <> 0 or tOffY <> 0 then
    case me.pStrech of
      #moveH:
        me.pLocX = me.pLocX + tOffX
      #moveV:
        me.pLocY = me.pLocY + tOffY
      #moveHV:
        me.pLocX = me.pLocX + tOffX
        me.pLocY = me.pLocY + tOffY
      #strechH:
        me.pWidth = me.pWidth + tOffX
      #strechV:
        me.pHeight = me.pHeight + tOffY
      #strechHV:
        me.pWidth = me.pWidth + tOffX
        me.pHeight = me.pHeight + tOffY
      #moveHstrechV:
        me.pLocX = me.pLocX + tOffX
        me.pHeight = me.pHeight + tOffY
      #moveVstrechH:
        me.pLocY = me.pLocY + tOffY
        me.pWidth = me.pWidth + tOffX
    end case
    me.render()
  end if
end

on getProperty me, tProp
  case tProp of
    #width:
      return me.pWidth
    #height:
      return me.pHeight
    #locX:
      return me.pLocX
    #locY:
      return me.pLocY
  end case
  return 0
end

on render me
  tW = me.pimage.width
  tH = me.pimage.height
  tXW = me.pWidth / me.pimage.width
  tXH = me.pHeight / me.pimage.height
  repeat with i = 0 to tXW - 1
    repeat with j = 0 to tXH - 1
      tXi = me.pLocX + i * tW
      tYi = me.pLocY + j * tH
      tRect = rect(tXi, tYi, tXi + tW, tYi + tH)
      me.pBuffer.image.copyPixels(me.pimage, tRect, me.pimage.rect, me.pParams)
    end repeat
  end repeat
end

on draw me
  me.pBuffer.image.draw(rect(me.pLocX, me.pLocY, me.pLocX + me.pWidth, me.pLocY + me.pHeight), [#shapeType: #rect, #color: rgb(255, 0, 128)])
end
