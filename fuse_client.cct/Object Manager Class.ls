property pObjectList, pUpdateList, pPrepareList, pManagerList, pInstanceList, pEraseLock, pTimeout, pUpdatePause, pBaseClsMem

on construct me
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  pManagerList = []
  pInstanceList = []
  pEraseLock = 0
  pTimeout = VOID
  pUpdatePause = 0
  pBaseClsMem = script("Object Base Class")
  pObjectList.sort()
  pUpdateList.sort()
  return 1
end

on deconstruct me
  pEraseLock = 1
  if objectp(pTimeout) then
    pTimeout.forget()
    pTimeout = VOID
  end if
  repeat with i = pInstanceList.count down to 1
    me.Remove(pInstanceList[i])
  end repeat
  repeat with i = pManagerList.count down to 1
    me.Remove(pManagerList[i])
  end repeat
  pObjectList = [:]
  pUpdateList = []
  pPrepareList = []
  return 1
end

on create me, tid, tClassList
  if not symbolp(tid) and not stringp(tid) then
    return error(me, "Symbol or string expected:" && tid, #create, #major)
  end if
  if objectp(pObjectList[tid]) then
    return error(me, "Object already exists:" && tid, #create, #major)
  end if
  if tid = #random then
    tid = getUniqueID()
  end if
  if voidp(tClassList) then
    return error(me, "Class member name expected!", #create, #major)
  end if
  if not listp(tClassList) then
    tClassList = [tClassList]
  end if
  tClassList = tClassList.duplicate()
  tObject = VOID
  tTemp = VOID
  tBase = pBaseClsMem.new()
  tBase.construct()
  if tid <> #temp then
    tBase.id = tid
    pObjectList[tid] = tBase
  end if
  tClassList.addAt(1, tBase)
  repeat with tClass in tClassList
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      if me.managerExists(#resource_manager) then
        tMemNum = me.getManager(#resource_manager).getmemnum(tClass)
      else
        tMemNum = member(tClass).number
      end if
      if tMemNum < 1 then
        if tid <> #temp then
          pObjectList.deleteProp(tid)
        end if
        return error(me, "Script not found:" && tMemNum, #create, #major)
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    if ilk(tObject, #instance) then
      tObject[#ancestor] = tTemp
      tTemp = tObject
    end if
    if tid <> #temp and tClassList.getLast() = tClass then
      pObjectList[tid] = tObject
      pInstanceList.append(tid)
    end if
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return tObject
end

on GET me, tid
  tObj = pObjectList[tid]
  if voidp(tObj) then
    return 0
  else
    return tObj
  end if
end

on Remove me, tid
  tObj = pObjectList[tid]
  if voidp(tObj) then
    return 0
  end if
  if ilk(tObj, #instance) then
    if not tObj.valid then
      return 0
    end if
    repeat with i = 1 to tObj.delays.count
      tDelayID = tObj.delays.getPropAt(i)
      tObj.Cancel(tDelayID)
    end repeat
    tObj.deconstruct()
    tObj.valid = 0
  end if
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  tObj = VOID
  if not pEraseLock then
    pObjectList.deleteProp(tid)
    pInstanceList.deleteOne(tid)
    pManagerList.deleteOne(tid)
  end if
  return 1
end

on exists me, tid
  if voidp(tid) then
    return 0
  end if
  return objectp(pObjectList[tid])
end

on print me
  repeat with i = 1 to pObjectList.count
    tProp = pObjectList.getPropAt(i)
    if symbolp(tProp) then
      tProp = "#" & tProp
    end if
    put tProp && ":" && pObjectList[i]
  end repeat
  return 1
end

on registerObject me, tid, tObject
  if not objectp(tObject) then
    return error(me, "Invalid object:" && tObject, #register, #major)
  end if
  if not voidp(pObjectList[tid]) then
    return error(me, "Object already exists:" && tid, #register, #minor)
  end if
  pObjectList[tid] = tObject
  pInstanceList.append(tid)
  return 1
end

on unregisterObject me, tid
  if voidp(pObjectList[tid]) then
    return error(me, "Referred object not found:" && tid, #unregister, #minor)
  end if
  tObj = pObjectList[tid]
  pObjectList.deleteProp(tid)
  pUpdateList.deleteOne(tObj)
  pPrepareList.deleteOne(tObj)
  pInstanceList.deleteOne(tid)
  tObj = VOID
  return 1
end

on registerManager me, tid
  if not me.exists(tid) then
    return error(me, "Referred object not found:" && tid, #registerManager, #major)
  end if
  if pManagerList.getOne(tid) <> 0 then
    return error(me, "Manager already registered:" && tid, #registerManager, #minor)
  end if
  pInstanceList.deleteOne(tid)
  pManagerList.append(tid)
  return 1
end

on unregisterManager me, tid
  if not me.exists(tid) then
    return error(me, "Referred object not found:" && tid, #unregisterManager, #minor)
  end if
  if pInstanceList.getOne(tid) <> 0 then
    return error(me, "Manager already unregistered:" && tid, #unregisterManager, #minor)
  end if
  pManagerList.deleteOne(tid)
  pInstanceList.append(tid)
  return 1
end

on getManager me, tid
  if not pManagerList.getOne(tid) then
    return error(me, "Manager not found:" && tid, #getManager, #major)
  end if
  return pObjectList[tid]
end

on managerExists me, tid
  return pManagerList.getOne(tid) <> 0
end

on receivePrepare me, tid
  if voidp(pObjectList[tid]) then
    return 0
  end if
  if pPrepareList.getPos(pObjectList[tid]) > 0 then
    return 0
  end if
  pPrepareList.add(pObjectList[tid])
  if not pUpdatePause then
    if voidp(pTimeout) then
      pTimeout = timeout("objectmanager" & the milliSeconds).new(60 * 1000 * 60, #null, me)
    end if
  end if
  return 1
end

on removePrepare me, tid
  if voidp(pObjectList[tid]) then
    return 0
  end if
  if pPrepareList.getOne(pObjectList[tid]) < 1 then
    return 0
  end if
  pPrepareList.deleteOne(pObjectList[tid])
  if pPrepareList.count = 0 and pUpdateList.count = 0 then
    if objectp(pTimeout) then
      pTimeout.forget()
      pTimeout = VOID
    end if
  end if
  return 1
end

on receiveUpdate me, tid
  if voidp(pObjectList[tid]) then
    return 0
  end if
  if pUpdateList.getPos(pObjectList[tid]) > 0 then
    return 0
  end if
  pUpdateList.add(pObjectList[tid])
  if not pUpdatePause then
    if voidp(pTimeout) then
      pTimeout = timeout("objectmanager" & the milliSeconds).new(60 * 1000 * 60, #null, me)
    end if
  end if
  return 1
end

on removeUpdate me, tid
  if voidp(pObjectList[tid]) then
    return 0
  end if
  if pUpdateList.getOne(pObjectList[tid]) < 1 then
    return 0
  end if
  pUpdateList.deleteOne(pObjectList[tid])
  if pPrepareList.count = 0 and pUpdateList.count = 0 then
    if objectp(pTimeout) then
      pTimeout.forget()
      pTimeout = VOID
    end if
  end if
  return 1
end

on pauseUpdate me
  if objectp(pTimeout) then
    pTimeout.forget()
    pTimeout = VOID
  end if
  pUpdatePause = 1
  return 1
end

on resumeUpdate me
  if pUpdateList.count > 0 and voidp(pTimeout) then
    pTimeout = timeout("objectmanager" & the milliSeconds).new(60 * 1000 * 60, #null, me)
  end if
  pUpdatePause = 0
  return 1
end

on prepareFrame me
  call(#prepare, pPrepareList)
  call(#update, pUpdateList)
end

on null me
end
