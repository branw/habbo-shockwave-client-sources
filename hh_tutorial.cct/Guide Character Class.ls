property pTopicList, pMenuID, pWindow, pBubble, pDirection, pPosX, pPosY, pPose, pSex, pimage, pFlipped

on construct me
  me.pMenuID = getUniqueID()
  createWindow(pMenuID, "guide_character.window")
  me.pWindow = getWindow(pMenuID)
  me.pBubble = createObject(getUniqueID(), ["Bubble Class", "Link Bubble Class"])
  me.hide()
  me.pBubble.setProperty(#targetID, "guide_image")
  me.pBubble.setProperty([#offsetx: 50])
  me.pBubble.update()
  me.pPose = 1
  me.setProperties([#offsetx: 75, #offsety: 300])
  me.pWindow.registerProcedure(#eventHandlerTutorialMenu, me.getID(), #mouseUp)
  return 1
end

on deconstruct me
  removeObject(me.pBubble.getID())
  removeWindow(me.pWindow.getProperty(#id))
end

on setLinks me, tLinkList
  me.pBubble.setText(getText("tutorial_menu_text"))
  me.pBubble.setLinks(tLinkList)
end

on setStatuses me, tStatuses
  if voidp(tStatuses) then
    return 0
  end if
  me.pBubble.setCheckmarks(tStatuses)
end

on hideLinks me
  me.pBubble.setLinks(VOID)
end

on update me
  tWindowList = getWindowIDList()
  tPosGuide = tWindowList.getPos(me.pMenuID)
  if tPosGuide > 0 then
    tWindowList.deleteAt(tPosGuide)
  end if
  tPosBubble = tWindowList.getPos(me.pBubble.getProperty(#windowID))
  if tPosBubble > 0 then
    tWindowList.deleteAt(tPosBubble)
  end if
  tWindowList.add(me.pMenuID)
  tWindowList.add(me.pBubble.getProperty(#windowID))
  getWindowManager().reorder(tWindowList)
  me.pBubble.update()
end

on setProperties me, tProperties
  if not listp(tProperties) then
    return 0
  end if
  repeat with i = 1 to tProperties.count
    me.setProperty(tProperties.getPropAt(i), tProperties[i])
  end repeat
end

on getProperty me, tProp
  case tProp of
    #sex:
      return me.pSex
  end case
end

on setProperty me, tProperty, tValue
  case tProperty of
    #textKey:
      me.pBubble.setText(getText(tValue))
    #offsetx:
      me.pPosX = tValue
      me.pWindow.moveTo(me.pPosX, me.pPosY)
    #offsety:
      me.pPosY = tValue
      me.pWindow.moveTo(me.pPosX, me.pPosY)
    #links:
      me.pBubble.setLinks(tValue)
    #sex:
      me.pSex = tValue
      me.updateImage()
    #pose, #direction:
      me.pPose = tValue
      me.updateImage()
    #topics:
      me.pTopicList = tValue
  end case
end

on moveTo me, tX, tY
  me.pPosX = tX
  me.pPosY = tY
  me.pWindow.moveTo(me.pPosX, me.pPosY)
  me.pBubble.update()
end

on setDirection me, tDirection
  if tDirection <> me.pDirection then
    tElem = me.pWindow.getElement("guide_image")
    tElem.flipH()
    tElem.render()
  end if
  me.pDirection = tDirection
end

on hide me
  me.pWindow.hide()
  me.pBubble.hide()
end

on show me
  if voidp(me.pimage) then
    return 0
  end if
  me.updateImage()
  me.pWindow.show()
  me.pBubble.show()
end

on updateImage me
  if voidp(me.pSex) or voidp(pPose) then
    return 0
  end if
  tPose = integer(me.pPose)
  me.pFlipped = 0
  if tPose > 10 then
    return 0
  end if
  tImageElem = pWindow.getElement("guide_image")
  if tPose > 5 then
    tPose = tPose - 5
    me.pFlipped = 1
  end if
  tMemberName = "tutor_" & me.pSex & "_" & string(tPose)
  me.pimage = member(getmemnum(tMemberName)).image
  if voidp(me.pimage) then
    return 0
  end if
  tImageElem.feedImage(me.pimage)
  if me.pFlipped then
    tImageElem.flipH()
    tImageElem.render()
  end if
  tImageElem.resizeTo(me.pimage.width, me.pimage.height, 1)
end

on eventHandlerTutorialMenu me, tEvent, tSpriteID, tParam
end
