property ancestor, pGroupId, pStatus, pPercent, pCastloadedsofar, pCastcount, pCallBack, pTempPercet, pLastPercet, pTempLoadItemCntr, pNowLoadingCount, pCastLoadMngrObj

on new me
  return me
end

on define me, tdata
  pGroupId = tdata[#id]
  pStatus = tdata[#status]
  pPercent = tdata[#Percent]
  pCastloadedsofar = tdata[#sofarloaded]
  pCastcount = tdata[#castCount]
  pCallBack = tdata[#callback]
  pCastLoadMngrObj = tdata[#manager]
  pNowLoadingCount = 0
  pTempPercet = 0
  pLastPercet = 0
  pTempLoadItemCntr = 0
  return 1
end

on OneCastDone me
  pCastloadedsofar = pCastloadedsofar + 1.0
  if integer(pCastloadedsofar) = pCastcount then
    pStatus = #ready
  end if
  return 1
end

on ChangeCurrentLoadingCount me, tPosOrNeg
  pNowLoadingCount = pNowLoadingCount + tPosOrNeg
end

on resetPercentCounter me
  pTempPercet = 0
  pTempLoadItemCounter = 0
  return 1
end

on UpdateTaskPercent me, tInstancePercent, tFile
  pTempLoadItemCounter = pTempLoadItemCounter + 1
  pTempPercet = pTempPercet + tInstancePercent
  if pTempLoadItemCounter = pNowLoadingCount then
    tTemp = float(1.0 * (pTempPercet + pCastloadedsofar) / pCastcount)
    if tTemp <= 1.0 and pLastPercet <= tTemp then
      pPercent = tTemp
    else
      pPercent = pLastPercet
    end if
  end if
end

on getTaskState me
  return pStatus
end

on getTaskPercent me
  return pPercent
end

on DoCallBack me
  if pStatus = #ready then
    if listp(pCallBack) then
      repeat with tCall in pCallBack
        if objectExists(tCall[#client]) then
          call(tCall[#method], getObject(tCall[#client]), tCall[#argument])
        end if
      end repeat
    end if
  end if
end

on registerCallbackToTask me, tid, tMethod, tClientID, tArgument
  if not symbolp(tMethod) then
    return error(me, "Symbol referring to handler expected:" && tMethod, #registerCallbackToTask)
  end if
  if not objectExists(tClientID) then
    return error(me, "Object not found:" && tClientID, #registerCallbackToTask)
  end if
  if not getObject(tClientID).handler(tMethod) then
    return error(me, "Handler not found in object:" && tMethod & "/" & tClientID, #registerCallbackToTask)
  end if
  if pStatus = #ready then
    call(tMethod, getObject(tClientID), tArgument)
    pCastLoadMngrObj.removeCastLoadTask(pGroupId)
  else
    if pStatus = #LOADING then
      if voidp(pCallBack) then
        pCallBack = list([#method: tMethod, #client: tClientID, #argument: tArgument])
      else
        pCallBack.add([#method: tMethod, #client: tClientID, #argument: tArgument])
      end if
    end if
  end if
  return 1
end
