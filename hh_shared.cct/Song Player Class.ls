property pUpdateTimeout, pSongData, pPlayTimeout, pPreviewChannel, pSongChannels

on construct me
  pSongData = [:]
  pUpdateTimeout = "song player loop update"
  pPlayTimeout = "song play timeout"
  pPreviewChannel = 5
  pSongChannels = [1, 2, 3, 4]
  return 
end

on deconstruct me
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
  return 
end

on reserveSongChannels me
  repeat with j = 1 to 4
    queueSound("sound_machine_sample_0", pSongChannels[j])
    startSoundChannel(pSongChannels[j])
  end repeat
end

on startSong me, tSongData
  pSongData = tSongData
  me.stopSong()
  createTimeout(pPlayTimeout, 30, #startChannels, me.getID(), VOID, 1)
  me.reserveSongChannels()
  if not timeoutExists(pUpdateTimeout) then
    createTimeout(pUpdateTimeout, 3000, #checkLoopData, me.getID(), VOID, 0)
  end if
  return 1
end

on startChannels me
  repeat with tChannel = 1 to 4
    stopSoundChannel(pSongChannels[tChannel])
  end repeat
  tPlayRoundsOnQueue = 2
  repeat with i = 1 to tPlayRoundsOnQueue
    me.addPlayRound()
  end repeat
  stopSoundChannel(pPreviewChannel)
  queueSound("sound_machine_sample_0", pPreviewChannel)
  startSoundChannel(pPreviewChannel)
  repeat with j = 4 down to 1
    startSoundChannel(pSongChannels[j])
  end repeat
end

on stopSong me
  repeat with tChannel = 1 to 4
    stopSoundChannel(pSongChannels[tChannel])
  end repeat
  if timeoutExists(pUpdateTimeout) then
    removeTimeout(pUpdateTimeout)
  end if
  return 1
end

on addPlayRound me
  if pSongData.getaProp(#sounds) = VOID then
    return 1
  end if
  repeat with i = 1 to pSongData.sounds.count
    tSound = pSongData.sounds[i]
    repeat with j = 1 to tSound.loops
      queueSound(tSound.name, tSound.channel)
    end repeat
  end repeat
  return 1
end

on checkLoopData me
  tPlayList = sound(1).getPlaylist()
  tLength = 0
  repeat with i = 1 to tPlayList.count
    tLength = tLength + tPlayList[i].member.duration
  end repeat
  if tLength < 60000 then
    me.addPlayRound()
  end if
  return 1
end

on startSamplePreview me, tParams
  tSuccess = playSoundInChannel(tParams.name, pPreviewChannel)
  if not tSuccess then
    return error(me, "Sound could not be started", #startSamplePreview)
  end if
  return 1
end

on stopSamplePreview me
  tSuccess = stopSoundChannel(pPreviewChannel)
  if not tSuccess then
    return error(me, "Sound could not be stopped", #stopSamplePreview)
  end if
  return 1
end
