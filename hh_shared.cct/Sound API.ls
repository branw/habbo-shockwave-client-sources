on constructSoundManager
  return createManager(#sound_manager, getClassVariable("sound.manager.class", "Sound Manager Class"))
end

on deconstructSoundManager
  return removeManager(#sound_manager)
end

on getSoundManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#sound_manager) then
    return constructSoundManager()
  end if
  return tMgr.getManager(#sound_manager)
end

on setSoundState tValue
  return getSoundManager().setSoundState(tValue)
end

on getSoundState
  return getSoundManager().getSoundState()
end

on playSound tMemName, tPriority, tProps
  return getSoundManager().play(tMemName, tPriority, tProps)
end

on playSoundInChannel tMemName, tChannelNum
  tChannelObj = getSoundManager().getChannel(tChannelNum)
  if tChannelObj = 0 then
    return error(VOID, "Invalid sound channel:" && tChannelNum, #playSoundInChannel)
  end if
  tChannelObj.reset()
  return tChannelObj.play(tMemName)
end

on queueSound tMemName, tChannelNum, tProps
  tChannelObj = getSoundManager().getChannel(tChannelNum)
  if tChannelObj = 0 then
    return error(VOID, "Invalid sound channel:" && tChannelNum, #queueSound)
  end if
  return tChannelObj.queue(tMemName, tProps)
end

on stopAllSounds tid
  if not managerExists(#sound_manager) then
    return 0
  end if
  return getSoundManager().stopAllSounds(tid)
end

on startSoundChannel tNum
  return getSoundManager().playChannel(tNum)
end

on stopSoundChannel tNum
  return getSoundManager().stopChannel(tNum)
end
