property pWriterPlain, pTutorialConfig, pTopicList, pView, pMenuID, pBubbles, pGuide, pExitMenuWindow

on construct me
  me.pMenuID = #tutorial_menu
  me.pWriterPlain = "tutorial_writer_plain"
  me.pGuide = createObject(getUniqueID(), "Guide Character Class")
  me.pBubbles = []
  tID = getUniqueID()
  createWindow(tID, "tutorial_exit_menu.window")
  me.pExitMenuWindow = getWindow(tID)
  me.pExitMenuWindow.hide()
  me.pExitMenuWindow.moveTo(5, 5)
  me.pExitMenuWindow.registerProcedure(#eventHandlerTutorialExitMenu, me.getID(), #mouseUp)
  receivePrepare(me.getID())
  return 1
end

on deconstruct me
  return 1
end

on stopTutorial me
  me.hide()
  removePrepare(me.getID())
end

on setBubbles me, tBubbleList
  repeat with i = pBubbles.count down to 1
    removeObject(pBubbles[i].getID())
  end repeat
  me.pBubbles = []
  if voidp(tBubbleList) then
    return 1
  end if
  repeat with i = 1 to tBubbleList.count
    tBubble = createObject(getUniqueID(), "Bubble Class")
    tBubble.setProperty(tBubbleList[i])
    me.pBubbles.add(tBubble)
  end repeat
end

on setTutor me, tTutorList
  me.pGuide.setProperties(tTutorList)
end

on hide me
  me.pGuide.hide()
  repeat with tBubble in me.pBubbles
    tBubble.hide()
  end repeat
  me.pExitMenuWindow.hide()
end

on show me
  receivePrepare(me.getID())
  me.pGuide.show()
  repeat with tBubble in me.pBubbles
    tBubble.show()
  end repeat
  me.pExitMenuWindow.show()
end

on prepare me
  tWindowList = getWindowIDList()
  tExitMenuID = me.pExitMenuWindow.getProperty(#id)
  tPosExitMenu = tWindowList.getPos(tExitMenuID)
  if tPosExitMenu > 0 then
    tWindowList.deleteAt(tPosExitMenu)
  end if
  tWindowList.add(tExitMenuID)
  getWindowManager().reorder(tWindowList)
  me.updateBubbles()
  me.pGuide.update()
  return 1
end

on updateBubbles me
  if voidp(me.pBubbles) then
    return 1
  end if
  tWindowList = getWindowIDList()
  tAttachedWindows = [:]
  repeat with tBubble in me.pBubbles
    tBubble.update()
    tBubbleWindowID = tBubble.getProperty(#windowID)
    tPos = tWindowList.getPos(tBubbleWindowID)
    if tPos = 0 then
      next repeat
    end if
    tWindowList.deleteAt(tPos)
    tTargetWindowID = tBubble.getProperty(#targetWindowID)
    if voidp(tAttachedWindows.getaProp(tTargetWindowID)) then
      tAttachedWindows.setaProp(tTargetWindowID, [tBubbleWindowID])
      next repeat
    end if
    tAttachedWindows[tTargetWindowID].add(tBubbleWindowID)
  end repeat
  tOrderList = []
  repeat with tID in tWindowList
    tOrderList.add(tID)
    if not voidp(tAttachedWindows.getaProp(tID)) then
      repeat with tAttached in tAttachedWindows[tID]
        tOrderList.add(tAttached)
      end repeat
    end if
  end repeat
  getWindowManager().reorder(tOrderList)
  return 1
end

on showMenu me, tstate
  me.setBubbles(VOID)
  tTutor = [:]
  tTutor.setaProp(#offsetx, 30)
  tTutor.setaProp(#offsety, 300)
  case tstate of
    #welcome:
      tTextKey = "tutorial_welcome_" & me.pGuide.getProperty(#sex)
    #offtopic:
      tTextKey = "tutorial_offtopic"
    otherwise:
      tTextKey = "tutorial_topic_list_" & me.pGuide.getProperty(#sex)
  end case
  tTutor.setaProp(#textKey, tTextKey)
  tTutor.setaProp(#links, me.getComponent().getProperty(#topics))
  tTutor.setaProp(#pose, 1)
  me.setTutor(tTutor)
  me.pGuide.setStatuses(me.getComponent().getProperty(#statuses))
end

on setUserSex me, tUserSex
  case tUserSex of
    "M":
      tTutorSex = "F"
    "F":
      tTutorSex = "M"
  end case
  me.pGuide.setProperty(#sex, tTutorSex)
end

on eventHandlerTutorialExitMenu me, tEvent, tSpriteID, tParam
  case tSpriteID of
    "tutorial_button_quit":
      me.getComponent().stopTutorial()
    "tutorial_button_menu":
      me.getComponent().showMenu()
  end case
end
