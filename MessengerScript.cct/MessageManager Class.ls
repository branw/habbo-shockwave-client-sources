property pBuddyMsgs
global gBuddyList

on new me
  pBuddyMsgs = [:]
  return me
end

on handleFusePMessage me, data
  msg = new(script("Message Class"), data)
  l = getaProp(pBuddyMsgs, msg.senderID)
  if l = VOID then
    l = []
    addProp(pBuddyMsgs, msg.senderID, l)
  end if
  puppetSound(3, getmemnum("newmessage.sound"))
  add(l, msg)
  if objectp(gBuddyList) then
    update(gBuddyList)
  end if
end

on handleFusePCampaignMessage me, data
  global gDialogMessage
  msg = new(script("Campaign Message Class"), data)
  if msg.type = #dialog then
    if the frame > label("hotel") then
      tDialog = new(script("PopUp Context Class"), 2130000000, 851, 865, point(0, 0))
      tFrame = msg.link
      tDialog.displayFrame(tFrame)
    end if
    gDialogMessage = msg
  else
    l = getaProp(pBuddyMsgs, msg.senderID)
    if l = VOID then
      l = []
      addProp(pBuddyMsgs, msg.senderID, l)
    end if
    puppetSound(3, getmemnum("newmessage.sound"))
    add(l, msg)
  end if
end

on getMessageCount me
  c = 0
  repeat with b in pBuddyMsgs
    c = c + count(b)
  end repeat
  return c
end

on getBuddyMsgCount me, buddyId
  l = getaProp(pBuddyMsgs, buddyId)
  if l = VOID then
    return 0
  else
    return count(l)
  end if
end

on getNextBuddyMsg me, buddyId
  global gBuddyFigures
  l = getaProp(pBuddyMsgs, buddyId)
  if l = VOID then
    return VOID
  else
    if count(l) > 0 then
      msg = l[1]
      deleteAt(l, 1)
      update(gBuddyList)
      if count(l) = 0 then
        deleteProp(pBuddyMsgs, buddyId)
      end if
      if buddyId > 0 then
        MyWireFace(FigureDataParser(gBuddyFigures.getaProp(buddyId)), "face_icon")
      end if
      return msg
    else
      return getNextMessage(me)
    end if
  end if
end

on getNextMessage me
  if count(pBuddyMsgs) > 0 then
    bid = getPropAt(pBuddyMsgs, 1)
    return getNextBuddyMsg(me, bid)
  end if
  return VOID
end
