property pBubbles

on construct me
  pBubbles = [:]
  pUpdateOwnUserHelp = 0
  return 1
end

on deconstruct me
  me.removeAll()
  return 1
end

on removeAll me
  repeat with tItemNo = 1 to pBubbles.count
    tBubble = pBubbles[tItemNo]
    tBubble.deconstruct()
  end repeat
  pBubbles = [:]
end

on showOwnUserHelp me
  tRoomComponent = getThread("room").getComponent()
  if tRoomComponent = 0 then
    return 0
  end if
  tBubble = createObject(#random, getVariableValue("update.bubble.class"))
  if tBubble = 0 then
    return 0
  end if
  tHelpId = "own_user"
  tPointer = 7
  tText = getText("NUH_" & tHelpId)
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles[tHelpId]
    tPreviousBubble.deconstruct()
  end if
  pBubbles[tHelpId] = tBubble
end

on showGenericHelp me, tHelpId, tTargetLoc, tPointerIndex
  tLocX = 0
  tLocY = 0
  tText = EMPTY
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  if voidp(tTargetLoc) or not listp(tTargetLoc) then
    tLocX = getVariable("NUH." & tHelpId & ".bubble.loc").item[1]
    tLocY = getVariable("NUH." & tHelpId & ".bubble.loc").item[2]
  else
    tLocX = tTargetLoc[1]
    tLocY = tTargetLoc[2]
  end if
  the itemDelimiter = tDelim
  if voidp(tPointerIndex) then
    tPointer = getVariable("NUH." & tHelpId & ".pointer")
  else
    tPointer = tPointerIndex
  end if
  tText = getText("NUH_" & tHelpId)
  tBubble = createObject(#random, getVariableValue("static.bubble.class"))
  if tBubble = 0 then
    return 0
  end if
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.setProperty(#targetX, tLocX)
  tBubble.setProperty(#targetY, tLocY)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles[tHelpId]
    tPreviousBubble.deconstruct()
  end if
  pBubbles[tHelpId] = tBubble
end
