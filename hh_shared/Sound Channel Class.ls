property pChannelNum, pEndTime, pCounter

on define me, tChannelNum
  pChannelNum = tChannelNum
  tChannel = sound(pChannelNum)
  if ilk(tChannel) <> #instance then
    return error(me, "Invalid sound channel:" && pChannelNum, #play)
  end if
  pCounter = 0
  pEndTime = 0
  return 1
end

on reset me
  pEndTime = 0
  tChannel = sound(pChannelNum)
  tChannel.setPlayList([])
  tChannel.stop()
  return 1
end

on play me, tSoundObj
  tmember = tSoundObj.getMember()
  if tmember = 0 then
    return 0
  end if
  tChannel = sound(pChannelNum)
  if tSoundObj.getProperty(#infiniteloop) then
    tLoopCount = 0
  else
    tLoopCount = tSoundObj.getProperty(#loopCount)
    if tLoopCount = VOID then
      tLoopCount = 1
    end if
  end if
  tChannel.volume = tSoundObj.getProperty(#volume)
  pEndTime = the milliSeconds + tmember.duration * tLoopCount
  if tLoopCount = 0 then
    pEndTime = -1
  end if
  tChannel.play([#member: tmember, #loopCount: tLoopCount])
  return pChannelNum
end

on queue me, tSoundObj
  tmember = tSoundObj.getMember()
  if tmember = 0 then
    return 0
  end if
  tChannel = sound(pChannelNum)
  tChannel.queue(tmember)
  return 1
end

on getTimeRemaining me
  tChannel = sound(pChannelNum)
  if not tChannel.isBusy() then
    return 0
  end if
  if pEndTime = -1 then
    return #infinite
  end if
  tDurationLeft = pEndTime - the milliSeconds
  if tDurationLeft < 0 then
    tDurationLeft = 0
  end if
  return tDurationLeft
end

on dump me
  tChannel = sound(pChannelNum)
  tName = "<none>"
  if tChannel.isBusy() then
    tName = tChannel.member.name
  end if
  put "* Channel" && pChannelNum & " - Playtime left:" && me.getTimeRemaining() && "Now playing:" && tName && "Queue:" && tChannel.getPlaylist().count
end