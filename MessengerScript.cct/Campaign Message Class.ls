property id, message, link, linkText, senderID, type
global gBuddyList, gActiveMsg, gBuddyFigures

on new me, fusepMsg
  senderID = -1
  id = integer(fusepMsg.line[1])
  link = fusepMsg.line[2]
  linkText = fusepMsg.line[3]
  if linkText.length < 1 or linkText = "null" then
    linkText = link
  end if
  message = fusepMsg.line[4..fusepMsg.line.count]
  if message contains "[dialog_msg]" then
    type = #dialog
  end if
  return me
end

on getMessage me
  return message
end

on markAsRead me
  sendEPFuseMsg("MESSENGER_C_READ" && id)
end

on markAsClicked me
  sendEPFuseMsg("MESSENGER_C_CLICK" && id)
end

on display me
  member(getmemnum("messenger.message")).text = message
  member(getmemnum("messenger.habbomsg_link")).text = linkText
  gActiveMsg = me
  me.markAsRead()
  goContext("habbomsg")
end

on reply me
end
