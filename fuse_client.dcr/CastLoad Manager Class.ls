property pWaitList, pState, pAvailableDynCasts, pPermanentLevelList, pFileExtension, pTasksId, pLatestTaskID, pCurrentDownLoads, pLoadedCasts, pTempWaitList, pCastLibCount

on new me
  return me
end

on construct me
  if the runMode = "Author" then
    pFileExtension = ".cst"
  else
    pFileExtension = ".cct"
  end if
  pLoadedCasts = [:]
  pTempWaitList = []
  pCastLibCount = 0
  return 1
end

on startCastLoad me, tCasts, tPermanentOrNot, tAdd
  if voidp(tPermanentOrNot) then
    tPermanentOrNot = 0
  end if
  tTempWaitList = []
  tCastsList = []
  if tCasts.ilk = #propList then
    repeat with f = 1 to tCasts.count
      tPermanentLevel = tCasts.getPropAt(f)
      tCastName = tCasts[f]
      tCastsList.add(tCastName)
      me.addOneCastToWaitList(tCastName, tPermanentLevel)
    end repeat
  else
    if tCasts.ilk = #list then
      repeat with tCastName in tCasts
        tCastsList.add(tCastName)
        me.addOneCastToWaitList(tCastName, tPermanentOrNot)
      end repeat
    else
      if not listp(tCasts) then
        tCasts = list(tCasts)
        repeat with tCastName in tCasts
          tCastsList.add(tCastName)
          me.addOneCastToWaitList(tCastName, tPermanentOrNot)
        end repeat
      end if
    end if
  end if
  if tCasts.count() = 0 then
    return 0
  end if
  if voidp(tAdd) then
    tAdd = 0
  end if
  tid = getUniqueID()
  pLatestTaskID = tid
  if tAdd = 0 then
    me.removeTemporaryCast(tCastsList)
  end if
  if pTempWaitList.count > 0 then
    pWaitList[tid] = pTempWaitList
  end if
  if pWaitList.count = 0 then
    tTaskStatus = #ready
    tPercent = 1.0
  else
    tTaskStatus = #LOADING
    tPercent = 0
  end if
  pTasksId[tid] = createObject(#temp, getClassVariable("castload.task.class"))
  pTasksId[tid].define([#id: tid, #status: tTaskStatus, #Percent: tPercent, #sofarloaded: 0, #castCount: pTempWaitList.count, #callback: VOID, #manager: me])
  me.AddNextpreloadNetThing()
  me.AddNextpreloadNetThing()
  return tid
end

on registerCallback me, tid, tMethod, tClientID, tArgument
  if voidp(pTasksId.findPos(tid)) then
    return 0
  else
    return call(#registerCallbackToTask, pTasksId[tid], tid, tMethod, tClientID, tArgument)
  end if
end

on resetCastLibs me, tClean, tForced
  if tClean <> 1 then
    tClean = 0
  end if
  tTempList = []
  if the runMode = "Author" and tForced <> 1 then
    f = 1
    repeat while 1
      if variableExists("cast.dev." & f) then
        tTempList.add(getVariable("cast.dev." & f))
      else
        exit repeat
      end if
      f = f + 1
    end repeat
  end if
  pCastLibCount = the number of castLibs
  tEmptyCastNum = 1
  repeat with tCastNum = 3 to pCastLibCount
    tCastName = castLib(tCastNum).name
    if tTempList.findPos(tCastName) = 0 then
      if tClean then
        closeThread(tCastNum)
      end if
      if tClean then
        unregisterMembers(tCastNum)
      end if
      castLib(tCastNum).name = "empty" & tEmptyCastNum
      castLib(tCastNum).fileName = the moviePath & "empty" & pFileExtension
      tEmptyCastNum = tEmptyCastNum + 1
      next repeat
    end if
    pLoadedCasts[tCastName] = string(tCastNum)
  end repeat
  return me.InitPreloader()
end

on getLoadPercent me, tid
  if voidp(tid) then
    tid = pLatestTaskID
  end if
  if not voidp(pTasksId.findPos(tid)) then
    tTemp = pTasksId[tid].getTaskPercent()
    if pTasksId[tid].getTaskState() = #ready then
      return 1.0
    else
      return tTemp
    end if
  else
    return 1.0
  end if
end

on FindCastNumber me, tCast
  repeat with j = 1 to the number of castLibs
    tFileExtension = castLib(j).fileName.char[length(castLib(j).fileName) - 2..length(castLib(j).fileName)]
    if castLib(j).name <> "Internal" and tFileExtension <> "dcr" and tFileExtension <> "dir" then
      if castLib(j).name = tCast then
        return castLib(tCast).number
        exit repeat
      end if
    end if
  end repeat
  return 0
end

on exists me, tCastName
  if tCastName = "internal" then
    return 1
  end if
  if voidp(pLoadedCasts[tCastName]) then
    return 0
  else
    return 1
  end if
end

on print me
  repeat with i = 1 to the number of castLibs
    put castLib(i).name
  end repeat
  repeat with tObj in pCurrentDownLoads
    put tObj[#pFile] && tObj[#pPercent]
  end repeat
end

on prepare me
  if pTasksId.count > 0 then
    me.AddNextpreloadNetThing()
    call(#resetPercentCounter, pTasksId)
    call(#update, pCurrentDownLoads)
  end if
end

on InitPreloader me
  pState = #LOADING_READY
  pWaitList = [:]
  pAvailableDynCasts = [:]
  pPermanentLevelList = [:]
  pTasksId = [:]
  pCurrentDownLoads = [:]
  pLatestTaskID = EMPTY
  repeat with f = 1 to the number of castLibs
    tCastNumber = me.FindCastNumber("empty" & f)
    if tCastNumber > 0 then
      pAvailableDynCasts.addProp("empty" & f, tCastNumber)
    end if
  end repeat
  return 1
end

on AddNextpreloadNetThing me
  if pCurrentDownLoads.count < getIntVariable("net.operation.count", 2) then
    if pWaitList.count > 0 then
      if pWaitList[1].count > 0 then
        tFile = pWaitList[1][1]
        tURL = the moviePath & tFile & pFileExtension
        tpreloadId = pWaitList.getPropAt(1)
        pWaitList[1].deleteAt(1)
        if pWaitList[1].count = 0 then
          pWaitList.deleteProp(pWaitList.getPropAt(1))
        end if
        pCurrentDownLoads[tFile] = createObject(#temp, getClassVariable("castload.instance.class"))
        pCurrentDownLoads[tFile].define(tFile, tURL, tpreloadId)
        pTasksId[tpreloadId].ChangeCurrentLoadingCount(1)
        receivePrepare(me.getID())
        return 1
      end if
    end if
  end if
  return 0
end

on DoneCurrentDownLoad me, tFile, tURL, tid, tState
  if tState <> #error then
    tCastNumber = me.getAvailableEmptyCast()
    if tCastNumber > 0 then
      tCastName = tFile
      me.setImportedCast(tCastNumber, tCastName, tURL)
    end if
  end if
  if voidp(pCurrentDownLoads[tFile]) then
    return error(me, "CastLoad task was lost!" && tFile, #DoneCurrentDownLoad)
  end if
  pCurrentDownLoads[tFile].deconstruct()
  pCurrentDownLoads.deleteProp(tFile)
  call(#OneCastDone, pTasksId[tid], tFile)
  pTasksId[tid].ChangeCurrentLoadingCount(-1)
  me.removeCastLoadTask(tid)
  return 1
end

on removeCastLoadTask me, tid
  if pTasksId[tid].getTaskState() = #ready then
    pTasksId[tid].DoCallBack()
    pTasksId[tid].deconstruct()
    pTasksId.deleteProp(tid)
    if pTasksId.count = 0 then
      removePrepare(me.getID())
    end if
  end if
end

on TellStreamState me, tFileName, tState, tPercent, tid
  call(#UpdateTaskPercent, pTasksId[tid], tPercent, tFileName)
end

on setImportedCast me, tCastNum, tName, tFileName
  if castLib(tCastNum).name contains "empty" then
    castLib(tCastNum).fileName = tFileName
    castLib(tCastNum).name = tName
    pPermanentLevelList[tName][2] = tCastNum
    preIndexMembers(tCastNum)
    initThread(tCastNum)
    pLoadedCasts[tName] = string(tCastNum)
  end if
end

on getAvailableEmptyCast me
  if pAvailableDynCasts.count > 0 then
    tCastNum = pAvailableDynCasts.getLast()
    pAvailableDynCasts.deleteAt(pAvailableDynCasts.count)
    return tCastNum
  else
    SystemAlert(me, "Out of free cast entries! CastLoad stopped.")
    return 0
  end if
end

on removeTemporaryCast me, tNewLoadListOfcasts
  tTemp = pPermanentLevelList.duplicate()
  repeat with f = 1 to tTemp.count
    tPermanentOrNot = tTemp[f][1]
    tCastNumber = tTemp[f][2]
    if tPermanentOrNot = 0 and tCastNumber > 0 then
      tCastName = tTemp.getPropAt(f)
      if tNewLoadListOfcasts.getOne(tCastName) = 0 then
        pPermanentLevelList.deleteProp(tCastName)
        me.ResetOneDynamicCast(tCastNumber)
        if pCastLibCount <> the number of castLibs then
          pCastLibCount = the number of castLibs
          tError = "CastLib count was changed!!!" & RETURN
          tError = tError & "CastLib with problems:" && castLib(pCastLibCount).name
          error(me, tError, #removeTemporaryCast)
        end if
      end if
    end if
  end repeat
end

on addOneCastToWaitList me, tCastName, tPermanentOrNot
  if not me.FindCastNumber(tCastName) and pWaitList.getOne(tCastName) = 0 then
    pTempWaitList.add(tCastName)
    pPermanentLevelList.addProp(tCastName, [tPermanentOrNot, 0])
  else
    if voidp(pLoadedCasts[tCastName]) then
      pLoadedCasts[tCastName] = string(me.FindCastNumber(tCastName))
    end if
  end if
end

on ResetOneDynamicCast me, tCastNum
  if pLoadedCasts.getOne(string(tCastNum)) <> 0 then
    pLoadedCasts.deleteProp(pLoadedCasts.getOne(string(tCastNum)))
  else
    error(me, "Couldn't remove cast:" && tCastNum, #ResetOneDynamicCast)
  end if
  closeThread(tCastNum)
  unregisterMembers(tCastNum)
  castLib(tCastNum).name = "empty" & tCastNum - 2
  castLib("empty" & tCastNum - 2).fileName = the moviePath & "empty" & pFileExtension
  pAvailableDynCasts.addProp("empty" & tCastNum - 2, tCastNum)
  return 1
end
