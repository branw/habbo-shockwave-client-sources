property pSelectedSoundSet, pSelectedSoundSetSample, pHooveredSoundSet, pHooveredSoundSetSample, pHooveredSampleReady, pHooveredSoundSetTab, pSoundSetLimit, pSoundSetList, pSampleHorCount, pSampleVerCount, pSoundSetListPageSize, pSoundSetInventoryList, pSoundSetListPage, pTimeLineChannelCount, pTimeLineSlotCount, pTimeLineSlotLength, pTimeLineCursorX, pTimeLineCursorY, pSampleNameBase, pTimeLineUpdateTimer, pSongController, pSoundMachineFurniID, pConnectionId, pConfirmedAction, pConfirmedActionParameter, pSoundSetInsertLocked, pSongChanged, pTimeLineData, pTimeLineReady, pSoundMachineFurniOn, pSongStartTime, pSongPlaying, pSongData

on construct me
  pTimeLineUpdateTimer = "sound_machine_timeline_timer"
  pSampleNameBase = "sound_machine_sample_"
  pConnectionId = getVariableValue("connection.info.id", #info)
  pSampleHorCount = 3
  pSampleVerCount = 3
  pSoundSetLimit = 3
  pSoundSetListPageSize = 3
  pTimeLineChannelCount = 4
  pTimeLineSlotCount = 20
  pTimeLineSlotLength = 2000
  pSongController = "song controller"
  createObject(pSongController, "Song Controller Class")
  me.reset()
  registerMessage(#sound_machine_selected, me.getID(), #soundMachineSelected)
  registerMessage(#sound_machine_set_state, me.getID(), #soundMachineSetState)
  registerMessage(#sound_machine_removed, me.getID(), #soundMachineRemoved)
  registerMessage(#sound_machine_created, me.getID(), #soundMachineCreated)
  return 1
end

on deconstruct me
  if timeoutExists(pTimeLineUpdateTimer) then
    removeTimeout(pTimeLineUpdateTimer)
  end if
  unregisterMessage(#sound_machine_selected, me.getID())
  unregisterMessage(#sound_machine_set_state, me.getID())
  unregisterMessage(#sound_machine_removed, me.getID())
  unregisterMessage(#sound_machine_created, me.getID())
  return 1
end

on reset me
  pSoundMachineFurniOn = 0
  me.closeEdit()
  me.clearSoundSets()
  pSoundSetInventoryList = []
  me.clearTimeLine()
end

on closeEdit me
  pSoundMachineFurniID = 0
  pHooveredSampleReady = 1
  pSelectedSoundSet = 0
  pSelectedSoundSetSample = 0
  pHooveredSoundSet = 0
  pHooveredSoundSetSample = 0
  pHooveredSoundSetTab = 0
  pSoundSetListPage = 1
  pTimeLineCursorX = 0
  pTimeLineCursorY = 0
  pConfirmedAction = EMPTY
  pConfirmedActionParameter = EMPTY
  pSoundSetInsertLocked = 0
  pSongChanged = 0
  me.clearTimeLine()
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("GET_SOUND_DATA")
  end if
  return 1
end

on confirmAction me, tAction, tParameter
  pConfirmedAction = tAction
  pConfirmedActionParameter = tParameter
  case tAction of
    "eject":
      tReferences = me.checkSoundSetReferences(tParameter)
      if tReferences then
        return 1
      end if
    "close":
      if pSongChanged then
        return 1
      end if
    "clear":
      return 1
    "save":
      return 1
  end case
  me.actionConfirmed()
  return 0
end

on actionConfirmed me
  case pConfirmedAction of
    "eject":
      tRetVal = me.removeSoundSet(pConfirmedActionParameter)
      if tRetVal then
        me.getInterface().renderTimeLine()
      end if
    "close":
      me.getInterface().hideSoundMachine()
    "clear":
      me.clearTimeLine()
      me.getInterface().renderTimeLine()
    "save":
      me.saveSong()
  end case
  pConfirmedAction = EMPTY
  pConfirmedActionParameter = EMPTY
  return 1
end

on getConfigurationData me
  me.stopSong()
  if getConnection(pConnectionId) <> 0 then
    tRetVal = getConnection(pConnectionId).send("GET_SOUND_MACHINE_CONFIGURATION")
    if tRetVal then
      return getConnection(pConnectionId).send("GET_SOUND_DATA")
    end if
  end if
  return 0
end

on getSoundSetLimit me
  return pSoundSetLimit
end

on getSoundSetListPageSize me
  return pSoundSetListPageSize
end

on getSoundSetID me, tIndex
  if tIndex < 1 or tIndex > pSoundSetList.count then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  return pSoundSetList[tIndex][#id]
end

on getSoundSetListID me, tIndex
  tIndex = tIndex + (pSoundSetListPage - 1) * pSoundSetListPageSize
  if tIndex < 1 or tIndex > pSoundSetInventoryList.count then
    return 0
  end if
  return pSoundSetInventoryList[tIndex][#id]
end

on getSoundSetHooveredTab me
  return pHooveredSoundSetTab
end

on getSoundListPage me
  return pSoundSetListPage
end

on getSoundListPageCount me
  return 1 + (pSoundSetInventoryList.count() - 1) / pSoundSetListPageSize
end

on getHooveredSampleReady me
  return pHooveredSampleReady
end

on getPlayTime me
  if not pSongPlaying then
    return 0
  end if
  tTime = (the milliSeconds + 30 - pSongStartTime) mod (pTimeLineSlotLength * pTimeLineSlotCount)
  if tTime = 0 then
    tTime = tTime + 1
  end if
  return tTime
end

on getTimeLineSlotLength me
  return pTimeLineSlotLength
end

on soundMachineSelected me, tdata
  tFurniID = tdata[#id]
  tFurniOn = tdata[#furniOn]
  tResult = me.getInterface().soundMachineSelected(tFurniOn)
  if tResult then
    pSoundMachineFurniID = tFurniID
    pSoundMachineFurniOn = tFurniOn
  end if
end

on soundMachineSetState me, tdata
  tFurniID = tdata[#id]
  tFurniOn = tdata[#furniOn]
  tIsEditing = 0
  if pSoundMachineFurniID = tFurniID then
    tIsEditing = 1
  end if
  pSoundMachineFurniOn = tFurniOn
  if tIsEditing then
    me.soundMachineSelected([#id: tFurniID, #furniOn: pSoundMachineFurniOn])
  else
    if tFurniOn then
      if not pSongPlaying and pTimeLineReady then
        me.playSong()
      end if
    else
      me.stopSong()
    end if
  end if
end

on soundMachineRemoved me, tFurniID
  me.clearTimeLine()
  pSoundMachineFurniID = 0
  pSoundMachineFurniOn = 0
  me.stopSong()
  me.getInterface().hideSoundMachine()
end

on soundMachineCreated me, tFurniID
  me.clearTimeLine()
  if getConnection(pConnectionId) <> 0 then
    return getConnection(pConnectionId).send("GET_SOUND_DATA")
  end if
  return 0
end

on changeFurniState me
  tNewState = not pSoundMachineFurniOn
  tObj = getThread(#room).getComponent().getActiveObject(pSoundMachineFurniID)
  if tObj <> 0 then
    call(#changeState, [tObj], tNewState)
  end if
  pSoundMachineFurniID = 0
end

on updateSetList me, tList
  pSoundSetInventoryList = []
  repeat with tid in tList
    tItem = [#id: tid]
    pSoundSetInventoryList.add(tItem)
  end repeat
  me.changeSetListPage(0)
  me.getInterface().updateSoundSetList()
end

on updateSoundSet me, tIndex, tid, tSampleList
  if tIndex >= 1 and tIndex <= pSoundSetLimit then
    tSoundSet = [#id: tid]
    tMachineSampleList = []
    repeat with tSampleID in tSampleList
      tMachineSampleList.add([#id: tSampleID, #length: 0])
    end repeat
    tSoundSet[#samples] = tMachineSampleList
    pSoundSetList[tIndex] = tSoundSet
    repeat with tSampleIndex = 1 to tMachineSampleList.count
      me.getSampleReady(tSampleIndex, tIndex)
    end repeat
    me.getInterface().updateSoundSetSlots()
  end if
end

on removeSoundSetInsertLock me
  pSoundSetInsertLocked = 0
end

on changeSetListPage me, tChange
  tIndex = pSoundSetListPage + tChange
  if tIndex < 1 then
    tIndex = me.getSoundListPageCount()
  else
    if tIndex > me.getSoundListPageCount() then
      tIndex = 1
    end if
  end if
  if tIndex = pSoundSetListPage then
    return 0
  end if
  pSoundSetListPage = tIndex
  return 1
end

on checkSoundSetReferences me, tIndex
  if tIndex < 1 then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  repeat with tChannel in pTimeLineData
    repeat with tSlot = 1 to tChannel.count
      if not voidp(tChannel[tSlot]) then
        tSampleID = tChannel[tSlot]
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if me.getSampleSetNumber(tSampleID) = tIndex then
          return 1
        end if
      end if
    end repeat
  end repeat
  repeat with tChannel in pSongData
    repeat with tSample in tChannel
      if not voidp(tSample) then
        tSampleID = tSample[#id]
        if me.getSampleSetNumber(tSampleID) = tIndex then
          return 1
        end if
      end if
    end repeat
  end repeat
  return 0
end

on loadSoundSet me, tIndex
  tIndex = tIndex + (pSoundSetListPage - 1) * pSoundSetListPageSize
  if tIndex < 1 or tIndex > pSoundSetInventoryList.count then
    return 0
  end if
  if pSoundSetInsertLocked then
    return 0
  end if
  tFreeSlot = 0
  repeat with i = 1 to pSoundSetList.count
    if pSoundSetList[i] = VOID then
      tFreeSlot = i
      exit repeat
    end if
  end repeat
  if tFreeSlot = 0 then
    return 0
  end if
  tSoundSet = pSoundSetInventoryList[tIndex]
  tSetID = tSoundSet[#id]
  if getConnection(pConnectionId) <> 0 then
    pSoundSetInventoryList.deleteAt(tIndex)
    pSoundSetInsertLocked = 1
    return getConnection(pConnectionId).send("INSERT_SOUND_PACKAGE", [#integer: tSetID, #integer: tFreeSlot])
  else
    return 0
  end if
end

on removeSoundSet me, tIndex
  if tIndex < 1 then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  repeat with tChannel in pTimeLineData
    repeat with tSlot = 1 to tChannel.count
      if not voidp(tChannel[tSlot]) then
        tSampleID = tChannel[tSlot]
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if me.getSampleSetNumber(tSampleID) = tIndex then
          pSongChanged = 1
          tChannel[tSlot] = VOID
        end if
      end if
    end repeat
  end repeat
  repeat with tChannel in pSongData
    repeat with tSlot = 1 to tChannel.count
      tSample = tChannel[tSlot]
      if not voidp(tSample) then
        tSampleID = tSample[#id]
        if me.getSampleSetNumber(tSampleID) = tIndex then
          pSongChanged = 1
          tChannel[tSlot] = VOID
        end if
      end if
    end repeat
  end repeat
  if pSelectedSoundSet = tIndex then
    pSelectedSoundSet = 0
    pSelectedSoundSetSample = 0
  end if
  tNewSong = me.encodeTimeLineData()
  if tNewSong <> 0 then
    if getConnection(pConnectionId) <> 0 then
      pSoundSetList[tIndex] = VOID
      return getConnection(pConnectionId).send("EJECT_SOUND_PACKAGE", [#integer: tIndex, #string: tNewSong])
    else
      return 1
    end if
  else
    return 0
  end if
end

on clearSoundSets me
  pSoundSetList = []
  repeat with i = 1 to pSoundSetLimit
    pSoundSetList[i] = VOID
  end repeat
  me.getInterface().updateSoundSetSlots()
end

on soundSetEvent me, tSetID, tX, tY, tEvent
  if tX >= 1 and tX <= pSampleHorCount and tY >= 1 and tY <= pSampleVerCount and tSetID >= 1 and tSetID <= pSoundSetLimit then
    if tEvent = #mouseDown then
      tSampleIndex = tX + (tY - 1) * pSampleHorCount
      if not me.getSampleReady(tSampleIndex, tSetID) then
        return 0
      end if
      if pSelectedSoundSet = tSetID and pSelectedSoundSetSample = tSampleIndex then
        pSelectedSoundSet = 0
        pSelectedSoundSetSample = 0
      else
        pSelectedSoundSet = tSetID
        pSelectedSoundSetSample = tSampleIndex
      end if
    else
      if tEvent = #mouseWithin then
        tSample = tX + (tY - 1) * pSampleHorCount
        if pHooveredSoundSet = tSetID and pHooveredSoundSetSample = tSample then
          return 0
        end if
        pHooveredSoundSet = tSetID
        pHooveredSoundSetSample = tX + (tY - 1) * pSampleHorCount
        pHooveredSampleReady = me.getSampleReady(pHooveredSoundSetSample, pHooveredSoundSet)
        if pHooveredSampleReady then
          me.playSample(pHooveredSoundSetSample, pHooveredSoundSet)
        end if
      else
        if tEvent = #mouseLeave then
          pHooveredSoundSet = 0
          pHooveredSoundSetSample = 0
          pHooveredSampleReady = 1
          me.stopSample()
        end if
      end if
    end if
    return 1
  end if
  return 0
end

on soundSetTabEvent me, tSetID, tEvent
  if tSetID >= 1 and tSetID <= pSoundSetLimit then
    if tEvent = #mouseDown then
      tConfirm = me.getInterface().confirmAction("eject", tSetID)
      return not tConfirm
    else
      if tEvent = #mouseWithin then
        if tSetID = pHooveredSoundSetTab then
          return 0
        end if
        pHooveredSoundSetTab = tSetID
      else
        if tEvent = #mouseLeave then
          pHooveredSoundSetTab = 0
        end if
      end if
    end if
    return 1
  end if
  return 0
end

on timeLineEvent me, tX, tY, tEvent
  if tEvent = #mouseDown then
    tInsert = me.insertSample(tX, tY)
    if tInsert then
      pTimeLineCursorX = 0
      pTimeLineCursorY = 0
      return 1
    else
      return me.removeSample(tX, tY)
    end if
  else
    if tEvent = #mouseWithin then
      if tX <> pTimeLineCursorX or tY <> pTimeLineCursorY then
        tid = 0
        tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
        if tSample <> 0 then
          tid = tSample[#id]
        end if
        tInsert = me.getCanInsertSample(tX, tY, tid)
        if tInsert then
          pTimeLineCursorX = tX
          pTimeLineCursorY = tY
          return 1
        end if
      end if
    else
      if tEvent = #mouseLeave then
        if tX < 1 or tX > pTimeLineSlotCount or tY < 1 or tY > pTimeLineChannelCount then
          pTimeLineCursorX = 0
          pTimeLineCursorY = 0
          return 1
        end if
      end if
    end if
  end if
  return 0
end

on clearTimeLine me
  me.stopSong()
  pTimeLineData = []
  pSongData = []
  repeat with i = 1 to pTimeLineChannelCount
    tChannel = []
    repeat with j = 1 to pTimeLineSlotCount
      tChannel[j] = VOID
    end repeat
    pTimeLineData[i] = tChannel
    pSongData[i] = tChannel.duplicate()
  end repeat
  pTimeLineReady = 1
  pSongChanged = 1
end

on renderSoundSet me, tIndex, tWd, tHt, tMarginWd, tMarginHt, tNameBase, tSampleNameBase
  if tIndex < 0 or tIndex > pSoundSetList.count then
    return 0
  end if
  if voidp(pSoundSetList[tIndex]) then
    return 0
  end if
  tImg = image(pSampleHorCount * tWd + tMarginWd * (pSampleHorCount - 1), pSampleVerCount * tHt + tMarginHt * (pSampleVerCount - 1), 32)
  tSampleList = pSoundSetList[tIndex][#samples]
  if voidp(tSampleList) then
    return 0
  end if
  repeat with tSample = 1 to tSampleList.count
    tX = 1 + (tSample - 1) mod pSampleHorCount
    tY = 1 + (tSample - 1) / pSampleVerCount
    if tY > pSampleVerCount then
      exit repeat
    end if
    ttype = 1
    if tIndex = pSelectedSoundSet and tSample = pSelectedSoundSetSample then
      ttype = 3
    else
      if tIndex = pHooveredSoundSet and tSample = pHooveredSoundSetSample then
        ttype = 2
      end if
    end if
    tName = [tNameBase & ttype, tSampleNameBase & tSample]
    repeat with tPart = 1 to tName.count
      if member(tName[tPart]) <> member(0) then
        tRect = member(tName[tPart]).image.rect
        tImgWd = tRect[3] - tRect[1]
        tImgHt = tRect[4] - tRect[2]
        tRect[1] = tRect[1] + (tX - 1) * (tWd + tMarginWd) + (tWd - tImgWd) / 2
        tRect[2] = tRect[2] + (tY - 1) * (tHt + tMarginHt) + (tHt - tImgHt) / 2
        tRect[3] = tRect[3] + (tX - 1) * (tWd + tMarginWd) + (tWd - tImgWd) / 2
        tRect[4] = tRect[4] + (tY - 1) * (tHt + tMarginHt) + (tHt - tImgHt) / 2
        tSourceImg = member(tName[tPart]).image
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink: 8, #maskImage: tSourceImg.createMatte()])
      end if
    end repeat
  end repeat
  return tImg
end

on renderTimeLine me, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tBgImage
  tImg = image(pTimeLineSlotCount * tWd + tMarginWd * (pTimeLineSlotCount - 1), pTimeLineChannelCount * tHt + tMarginHt * (pTimeLineChannelCount - 1), 32)
  if member(tBgImage) <> member(0) then
    tImg.copyPixels(member(tBgImage).image, tImg.rect, member(tBgImage).image.rect)
  end if
  repeat with tChannel = 1 to pTimeLineData.count
    tChannelData = pTimeLineData[tChannel]
    repeat with tSlot = 1 to tChannelData.count
      if not voidp(tChannelData[tSlot]) then
        tSampleNumber = tChannelData[tSlot]
        if not me.renderSample(tSampleNumber, tSlot, tChannel, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg) then
        end if
      end if
    end repeat
  end repeat
  if pTimeLineCursorX <> 0 and pTimeLineCursorY <> 0 then
    tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
    if tSample <> 0 then
      if not me.renderSample(tSample[#id], pTimeLineCursorX, pTimeLineCursorY, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg, 50) then
      end if
    end if
  end if
  return tImg
end

on renderSample me, tSampleNumber, tSlot, tChannel, tWd, tHt, tMarginWd, tMarginHt, tNameBaseList, tSampleNameBase, tImg, tBlend
  tLength = me.getSampleLength(tSampleNumber)
  if tSampleNumber < 0 then
    tBlend = 20
    tSampleNumber = -tSampleNumber
  end if
  tSampleSet = me.getSampleSetNumber(tSampleNumber)
  tSampleIndex = me.getSampleIndex(tSampleNumber)
  tSample = me.getSample(tSampleIndex, tSampleSet)
  if tSample = 0 then
    return 0
  end if
  if voidp(tBlend) then
    tBlend = 100
  end if
  if tSampleSet < 1 or tSampleSet > tNameBaseList.count then
    return 0
  end if
  tNameBase = tNameBaseList[tSampleSet]
  repeat with tPos = 1 to tLength
    tName = [tNameBase & "1", tSampleNameBase & tSampleIndex]
    repeat with tPart = 1 to tName.count
      if member(tName[tPart]) <> member(0) then
        tRect = member(tName[tPart]).image.rect
        tImgWd = tRect[3] - tRect[1]
        tImgHt = tRect[4] - tRect[2]
        tRect[1] = tRect[1] + (tSlot + (tPos - 1) - 1) * (tWd + tMarginWd) + (tWd - tImgWd) / 2
        tRect[2] = tRect[2] + (tChannel - 1) * (tHt + tMarginHt) + (tHt - tImgHt) / 2
        tRect[3] = tRect[3] + (tSlot + (tPos - 1) - 1) * (tWd + tMarginWd) + (tWd - tImgWd) / 2
        tRect[4] = tRect[4] + (tChannel - 1) * (tHt + tMarginHt) + (tHt - tImgHt) / 2
        tSourceImg = member(tName[tPart]).image
        tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink: 8, #maskImage: tSourceImg.createMatte(), #blend: tBlend])
      end if
    end repeat
  end repeat
  repeat with tPos = 1 to tLength - 1
    tName = tNameBase & "sp"
    if member(tName) <> member(0) then
      tRect = member(tName).image.rect
      tImgWd = tRect[3] - tRect[1]
      tImgHt = tRect[4] - tRect[2]
      tRect[1] = tRect[1] + (tSlot + (tPos - 1)) * (tWd + tMarginWd) - tImgWd / 2
      tRect[2] = tRect[2] + (tChannel - 1) * (tHt + tMarginHt) + (tHt - tImgHt) / 2
      tRect[3] = tRect[3] + (tSlot + (tPos - 1)) * (tWd + tMarginWd) - tImgWd / 2
      tRect[4] = tRect[4] + (tChannel - 1) * (tHt + tMarginHt) + (tHt - tImgHt) / 2
      tSourceImg = member(tName).image
      tImg.copyPixels(tSourceImg, tRect, tSourceImg.rect, [#ink: 8, #maskImage: tSourceImg.createMatte(), #blend: tBlend])
    end if
  end repeat
  return 1
end

on playSample me, tSampleIndex, tSoundSet
  if pSongPlaying then
    return 1
  end if
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    tReady = 1
    tSampleName = me.getSampleName(tSample[#id])
    if objectExists(pSongController) then
      tReady = getObject(pSongController).startSamplePreview(tSampleName)
    end if
    return tReady
  end if
  return 0
end

on stopSample me
  if objectExists(pSongController) then
    return getObject(pSongController).stopSamplePreview()
  end if
  return 0
end

on getSampleReady me, tSampleIndex, tSoundSet
  tSample = me.getSample(tSampleIndex, tSoundSet)
  if tSample <> 0 then
    if tSample[#length] = 0 then
      tReady = 0
      tLength = me.getSampleLength(tSample[#id])
      if tLength then
        tSample[#length] = tLength
        tReady = 1
      end if
      return tReady
    else
      return 1
    end if
  end if
  return 0
end

on getSampleLength me, tSampleID
  if tSampleID < 0 then
    return 1
  end if
  tLength = 0
  tSampleName = me.getSampleName(tSampleID)
  if objectExists(pSongController) then
    tSongController = getObject(pSongController)
    tReady = tSongController.getSampleLoadingStatus(tSampleName)
    if not tReady then
      tSongController.preloadSounds([tSampleName])
    else
      tLength = tSongController.getSampleLength(tSampleName)
      tLength = (tLength + (pTimeLineSlotLength - 1)) / pTimeLineSlotLength
    end if
  end if
  return tLength
end

on getSample me, tSampleIndex, tSampleSet
  if tSampleSet >= 1 and tSampleSet <= pSoundSetLimit then
    if not voidp(pSoundSetList[tSampleSet]) then
      if pSoundSetList[tSampleSet][#samples].count >= tSampleIndex then
        return pSoundSetList[tSampleSet][#samples][tSampleIndex]
      end if
    end if
  end if
  return 0
end

on getSampleName me, tSampleID
  tName = pSampleNameBase & tSampleID
  return tName
end

on insertSample me, tSlot, tChannel
  tid = 0
  tSample = me.getSample(pSelectedSoundSetSample, pSelectedSoundSet)
  if tSample <> 0 then
    tid = tSample[#id]
  else
    return 0
  end if
  tInsert = me.getCanInsertSample(tSlot, tChannel, tid)
  if tInsert then
    pSongChanged = 1
    pTimeLineData[tChannel][tSlot] = tid
    me.stopSong()
    return 1
  end if
  return 0
end

on removeSample me, tSlot, tChannel
  if tChannel >= 1 and tChannel <= pTimeLineData.count then
    if tSlot >= 1 and tSlot <= pTimeLineData[tChannel].count then
      if not voidp(pTimeLineData[tChannel][tSlot]) then
        if pTimeLineData[tChannel][tSlot] < 0 then
          return 0
        end if
      else
        repeat with i = tSlot - 1 down to 1
          if not voidp(pTimeLineData[tChannel][i]) then
            tSampleID = pTimeLineData[tChannel][i]
            if tSampleID >= 0 then
              tSampleLength = me.getSampleLength(tSampleID)
              if tSampleLength <> 0 then
                if i + (tSampleLength - 1) >= tSlot then
                  tSlot = i
                  exit repeat
                  next repeat
                end if
                return 0
              end if
            end if
          end if
        end repeat
      end if
      pSongChanged = 1
      me.stopSong()
      pTimeLineData[tChannel][tSlot] = VOID
      return 1
    end if
  end if
  return 0
end

on getSampleSetNumber me, tSampleID
  tSamplePos = me.resolveSamplePosition(tSampleID)
  if tSamplePos <> 0 then
    return tSamplePos[#soundset]
  end if
  return 0
end

on getSampleIndex me, tSampleID
  tSamplePos = me.resolveSamplePosition(tSampleID)
  if tSamplePos <> 0 then
    return tSamplePos[#sample]
  end if
  return 0
end

on getCanInsertSample me, tX, tY, tid
  tLength = me.getSampleLength(tid)
  if tLength <> 0 then
    if tX >= 1 and tX + (tLength - 1) <= pTimeLineSlotCount and tY >= 1 and tY <= pTimeLineData.count then
      tChannel = pTimeLineData[tY]
      repeat with i = tX to tX + tLength - 1
        if not voidp(tChannel[i]) then
          return 0
        end if
      end repeat
      repeat with i = tX - 1 down to 1
        if not voidp(tChannel[i]) then
          tNumber = tChannel[i]
          if i + (me.getSampleLength(tNumber) - 1) >= tX then
            return 0
            next repeat
          end if
          return 1
        end if
      end repeat
      return 1
    end if
  end if
  return 0
end

on playSong me
  if pSongPlaying then
    return me.stopSong()
  end if
  tSongData = [#offset: 0, #sounds: []]
  repeat with tChannel = 1 to pTimeLineData.count
    tChannelData = pTimeLineData[tChannel]
    tSlot = 1
    repeat while tSlot <= tChannelData.count
      if not voidp(tChannelData[tSlot]) then
        tSampleID = tChannelData[tSlot]
        tSampleLength = me.getSampleLength(tSampleID)
        if tSampleLength <> 0 and tSampleID >= 0 then
          tCount = 0
          repeat while tChannelData[tSlot] = tSampleID
            tCount = tCount + 1
            tSlot = tSlot + tSampleLength
            if tSlot > tChannelData.count then
              exit repeat
            end if
          end repeat
          tSampleName = me.getSampleName(tSampleID)
          tSampleData = [#name: tSampleName, #loops: tCount, #channel: tChannel]
          tSongData[#sounds][tSongData[#sounds].count + 1] = tSampleData
        else
          tSampleName = me.getSampleName(0)
          tSampleData = [#name: tSampleName, #loops: 1, #channel: tChannel]
          tSongData[#sounds][tSongData[#sounds].count + 1] = tSampleData
          tSlot = tSlot + 1
        end if
        next repeat
      end if
      tCount = 0
      repeat while voidp(tChannelData[tSlot])
        tCount = tCount + 1
        tSlot = tSlot + 1
        if tSlot > tChannelData.count then
          exit repeat
        end if
      end repeat
      tSampleName = me.getSampleName(0)
      tSampleData = [#name: tSampleName, #loops: tCount, #channel: tChannel]
      tSongData[#sounds][tSongData[#sounds].count + 1] = tSampleData
    end repeat
  end repeat
  tReady = 0
  if objectExists(pSongController) then
    tReady = getObject(pSongController).playSong(tSongData)
    if tReady then
      pSongPlaying = 1
      pSongStartTime = the milliSeconds
      me.getInterface().updatePlayButton()
    end if
  end if
  return tReady
end

on stopSong me
  if pSongPlaying then
    pSongPlaying = 0
    me.getInterface().updatePlayHead()
    me.getInterface().updatePlayButton()
  end if
  pSongStartTime = 0
  if objectExists(pSongController) then
    getObject(pSongController).stopSong()
  end if
  return 1
end

on saveSong me, tdata
  tNewSong = me.encodeTimeLineData()
  if tNewSong <> 0 then
    if getConnection(pConnectionId) <> 0 then
      return getConnection(pConnectionId).send("SAVE_SOUND_MACHINE_CONFIGURATION", [#string: tNewSong])
    else
      return 1
    end if
  else
    return 0
  end if
end

on parseSongData me, tdata
  me.clearTimeLine()
  pSongChanged = 0
  repeat with i = 1 to tdata.count
    tChannel = tdata[i]
    if i <= pSongData.count then
      tSongChannel = pSongData[i]
      tSlot = 1
      repeat with tSample in tChannel
        tid = tSample[#id]
        tLength = tSample[#length]
        if tSlot <= tSongChannel.count then
          pSongData[i][tSlot] = tSample.duplicate()
        end if
        tSlot = tSlot + tLength
      end repeat
    end if
  end repeat
  me.processSongData()
  return 1
end

on processSongData me
  repeat with i = 1 to pTimeLineData.count
    repeat with j = 1 to pTimeLineData[i].count
      if pTimeLineData[i][j] < 0 then
        pTimeLineData[i][j] = VOID
      end if
    end repeat
  end repeat
  tReady = 1
  repeat with i = 1 to min(pSongData.count, pTimeLineData.count)
    tSongChannel = pSongData[i]
    tTimeLineChannel = pTimeLineData[i]
    repeat with j = 1 to tSongChannel.count
      tSample = tSongChannel[j]
      if not voidp(tSample) then
        tid = tSample[#id]
        tLength = tSample[#length]
        tSampleLength = me.getSampleLength(tid)
        tWasReady = 1
        if tSampleLength = 0 then
          tSampleLength = 1
          tid = -tid
          tReady = 0
          tWasReady = 0
        end if
        if tid <> 0 then
          tRepeats = tLength / tSampleLength
          repeat with k = 1 to tRepeats
            if me.getCanInsertSample(j + (k - 1) * tSampleLength, i, tid) then
              tTimeLineChannel[j + (k - 1) * tSampleLength] = tid
            end if
          end repeat
        end if
        if tWasReady then
          tSongChannel[j] = VOID
        end if
      end if
    end repeat
  end repeat
  pTimeLineReady = tReady
  if not pTimeLineReady then
    if not timeoutExists(pTimeLineUpdateTimer) then
      createTimeout(pTimeLineUpdateTimer, 500, #processSongData, me.getID(), VOID, 1)
    end if
  end if
  me.getInterface().renderTimeLine()
  if pTimeLineReady then
    tIsEditing = 0
    if pSoundMachineFurniID <> 0 then
      tIsEditing = 1
    end if
    if not tIsEditing and pSoundMachineFurniOn then
      pSongPlaying = 0
      me.playSong()
    end if
  end if
  return tReady
end

on resolveSamplePosition me, tSampleID
  repeat with i = 1 to pSoundSetList.count
    tSoundSet = pSoundSetList[i]
    if not voidp(tSoundSet) then
      tSampleList = tSoundSet[#samples]
      repeat with j = 1 to tSampleList.count
        tSample = tSampleList[j]
        if tSample[#id] = tSampleID then
          return [#sample: j, #soundset: i]
        end if
      end repeat
    end if
  end repeat
  return 0
end

on encodeTimeLineData me
  tStr = EMPTY
  repeat with i = 1 to pTimeLineData.count
    tChannel = pTimeLineData[i]
    tStr = tStr & i & ":"
    j = 1
    tChannelData = []
    repeat while j <= tChannel.count
      if voidp(tChannel[j]) then
        tSample = [#id: 0, #length: 1]
        j = j + 1
      else
        tSampleID = tChannel[j]
        tSampleLength = me.getSampleLength(tSampleID)
        if tSampleID < 0 then
          tSampleID = -tSampleID
        end if
        if tSampleLength = 0 then
          tSample = [#id: 0, #length: 1]
        else
          tSample = [#id: tSampleID, #length: tSampleLength]
        end if
        j = j + tSample[#length]
      end if
      tChannelData[tChannelData.count + 1] = tSample
    end repeat
    j = 1
    repeat while j < tChannelData.count
      if tChannelData[j][#id] = tChannelData[j + 1][#id] then
        tChannelData[j][#length] = tChannelData[j][#length] + tChannelData[j + 1][#length]
        tChannelData.deleteAt(j + 1)
        next repeat
      end if
      j = j + 1
    end repeat
    tChannelStr = EMPTY
    repeat with tSample in tChannelData
      if tChannelStr <> EMPTY then
        tChannelStr = tChannelStr & ";"
      end if
      tChannelStr = tChannelStr & tSample[#id] & "," & tSample[#length]
    end repeat
    tStr = tStr & tChannelStr & ":"
  end repeat
  return tStr
end
