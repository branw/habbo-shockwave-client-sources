property pWindowType, pLinkList, pLinkWriter, pResizeOffset, pLinkPosOrigX, pLinkPosOrigY, pWidthOrig, pHeightOrig

on construct me
  me.pWindowType = "bubble_links.window"
  me.pTextWidth = 160
  me.Init()
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseEnter)
  me.pWindow.registerProcedure(#blendHandler, me.getID(), #mouseLeave)
  me.pWindow.registerProcedure(#eventHandler, me.getID(), #mouseUp)
  tLinkFont = getStructVariable("struct.font.link")
  tLinkFont.setaProp(#lineHeight, 16)
  tWriterID = getUniqueID()
  createWriter(tWriterID, tLinkFont)
  me.pLinkWriter = getWriter(tWriterID)
  me.pLinkWriter.define([#bgColor: rgb("#F0F0F0")])
  me.pResizeOffset = 0
  me.pLinkPosOrigX = me.pWindow.getElement("bubble_links").getProperty(#locH)
  me.pLinkPosOrigY = me.pWindow.getElement("bubble_links").getProperty(#locV)
  me.pWidthOrig = me.pWindow.getProperty(#width)
  me.pHeightOrig = me.pWindow.getProperty(#height)
  me.hideLinks()
  return 1
end

on deconstruc me
  removeWindow(me.pWindow.getProperty(#id))
end

on setText me, tText
  callAncestor(#setText, [me], tText)
  me.setLinks(me.pLinkList)
end

on setLinks me, tLinkList
  me.pLinkList = tLinkList
  tElem = me.pWindow.getElement("bubble_links")
  if voidp(me.pLinkList) then
    me.hideLinks()
    return 1
  end if
  if me.pLinkList.count = 0 then
    me.hideLinks()
    return 1
  end if
  tListString = EMPTY
  repeat with tLink in tLinkList
    tListString = tListString & getText(tLink) & RETURN
  end repeat
  tListString = tListString.line[1..tListString.line.count - 1]
  tLinkImage = me.pLinkWriter.render(tListString).duplicate()
  tElem.show()
  tElem.feedImage(tLinkImage)
  tElem.resizeTo(tLinkImage.width, tLinkImage.height, 1)
  tTextH = me.pWindow.getElement("bubble_text").getProperty(#height)
  tElem.moveTo(0, tTextH + 10)
  me.pWindow.resizeTo(me.pEmptySizeX, me.pEmptySizeY + tTextH + 10 + tElem.getProperty(#height))
  me.updatePointer()
end

on hideLinks me
  tElem = me.pWindow.getElement("bubble_links")
  tElem.hide()
  tTextH = me.pWindow.getElement("bubble_text").getProperty(#height)
  me.pWindow.resizeTo(me.pEmptySizeX, me.pEmptySizeY + tTextH)
  me.updatePointer()
end

on setCheckmarks me, tStatusList
  tMarkImage = member("checkmark").image
  tLinkElem = me.pWindow.getElement("bubble_links")
  tLinkImage = tLinkElem.getProperty(#image)
  tImage = image(tLinkImage.width + 11, tLinkImage.height, 8)
  tImage.copyPixels(tLinkImage, rect(12, 0, tImage.width, tImage.height), tLinkImage.rect)
  repeat with tLinkNum = 1 to me.pLinkList.count
    tid = me.pLinkList.getPropAt(tLinkNum)
    if not tStatusList.getaProp(tid) then
      next repeat
    end if
    tY1 = 16 * (tLinkNum - 1) + 4
    tY2 = tY1 + 9
    tImage.copyPixels(tMarkImage, rect(1, tY1, 10, tY2), tMarkImage.rect)
  end repeat
  tLinkElem.feedImage(tImage)
  tLinkElem.resizeTo(tImage.width, tImage.height, 1)
end

on blendHandler me, tEvent, tSpriteID, tParam
  nothing()
end

on eventHandler me, tEvent, tSpriteID, tParam
  if me.pLinkList.ilk <> #propList then
    return 0
  end if
  if tSpriteID = "bubble_links" then
    tLineNum = tParam[2] / 16 + 1
    tTopicID = me.pLinkList.getPropAt(tLineNum)
    getThread(#tutorial).getComponent().selectTopic(tTopicID)
  end if
end
