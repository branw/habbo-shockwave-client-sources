property pChannelNum, pEndTime, pCounter

on define me, tChannelNum
  pChannelNum = tChannelNum
  tChannel = sound(pChannelNum)
  if ilk(tChannel) <> #instance then
    return error(me, "Invalid sound channel:" && pChannelNum, #define)
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

on createSoundInstance me, tMemName, tPriority, tProps
  tObject = createObject(#temp, "Sound Instance Class")
  if tObject = 0 then
    return 0
  end if
  tObject.define(tMemName, tPriority, tProps)
  return tObject
end

on play me, tSoundObj, tParams
  if not objectp(tSoundObj) then
    tSoundObj = me.createSoundInstance(tSoundObj, #cut, tParams)
  end if
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

on startPlaying me
  sound(pChannelNum).play()
  return 1
end

on queue me, tSoundObj, tProps
  if tProps.ilk <> #propList then
    tProps = [:]
  end if
  tmember = getMember(tSoundObj)
  if tmember = 0 then
    return 0
  end if
  tProps[#member] = tmember
  tChannel = sound(pChannelNum).queue(tProps)
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
