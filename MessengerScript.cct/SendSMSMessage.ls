global gBuddyList, gMessageManager, gChosenBuddyId, gMModeChosenMode

on mouseDown me
  receivers = field("receivers")
  if receivers.length < 1 then
    ShowAlert("ChooseWhoToSentMessage")
    return 
  end if
  message = member(getmemnum("messenger.message.new")).text
  if message.length < 1 then
    return 
  else
    sendEPFuseMsg("MESSENGER_SENDSMSMSG" && receivers & RETURN & message)
    goContext("buddies")
  end if
  put EMPTY into field getmemnum("receivers")
  member(getmemnum("messenger.message.new")).text = EMPTY
  member(getmemnum("messenger.message.new")).scrollTop = 0
  member(getmemnum("message.charCount")).text = "0/255"
  puppetSound(2, getmemnum("messagesent"))
end
