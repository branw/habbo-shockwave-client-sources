property pThreadList, pVarMngrObj, pIndexField, pObjBaseCls

on construct me
  pThreadList = [:]
  pVarMngrObj = createObject(#temp, getClassVariable("variable.manager.class"))
  pIndexField = getVariable("thread.index.field")
  pObjBaseCls = script(getmemnum("Object Base Class"))
  return 1
end

on deconstruct me
  me.closeAll()
  pVarMngrObj = 0
  pIndexField = 0
  pObjBaseCls = 0
  return 1
end

on create me, tID, tInitField
  return me.initThread(tInitField, tID)
end

on Remove me, tID
  return me.closeThread(tID)
end

on GET me, tID
  tThreadObj = pThreadList[tID]
  if voidp(tThreadObj) then
    return 0
  else
    return tThreadObj
  end if
end

on exists me, tID
  return not voidp(pThreadList[tID])
end

on initThread me, tCastNumOrMemName, tID
  if stringp(tCastNumOrMemName) then
    tMemNum = getResourceManager().getmemnum(tCastNumOrMemName)
    if tMemNum = 0 then
      return error(me, "Thread index field not found:" && tCastNumOrMemName, #initThread, #major)
    else
      tThreadField = tCastNumOrMemName
      tCastNum = member(tMemNum).castLibNum
    end if
  else
    if symbolp(tCastNumOrMemName) then
      tThreadField = pIndexField
      if the number of castLibs > 1 then
        repeat with i = 2 to the number of castLibs
          if member(tThreadField, i).number > 0 then
            pVarMngrObj.clear()
            pVarMngrObj.dump(member(tThreadField, i).number)
            if symbol(pVarMngrObj.GET("thread.id")) = tCastNumOrMemName then
              return me.initThread(i, tID)
              exit repeat
            end if
          end if
        end repeat
      end if
    else
      if not integerp(tCastNumOrMemName) then
        return error(me, "Cast number expected:" && tCastNumOrMemName, #initThread, #major)
      else
        if tCastNumOrMemName < 1 or tCastNumOrMemName > the number of castLibs then
          return error(me, "Cast doesn't exist:" && tCastNumOrMemName, #initThread, #major)
        end if
      end if
      tThreadField = pIndexField
      tCastNum = tCastNumOrMemName
      if member(tThreadField, tCastNum).number < 1 then
        return 0
      end if
    end if
  end if
  pVarMngrObj.clear()
  pVarMngrObj.dump(member(tThreadField, tCastNum).number)
  if symbolp(tID) then
    tThreadID = tID
  else
    tThreadID = symbol(pVarMngrObj.GET("thread.id"))
  end if
  if not symbolp(tThreadID) then
    return error(me, "Invalid thread ID:" && tThreadID, #initThread, #major)
  end if
  tMultipleDef = 0
  if listp(value(pVarMngrObj.GET("thread.id"))) then
    tThreadKeys = pVarMngrObj.GetValue("thread.id")
    tMultipleDef = 1
  else
    tThreadKeys = [pVarMngrObj.GET("thread.id")]
  end if
  repeat with tThreadKey in tThreadKeys
    tThreadID = symbol(tThreadKey)
    if not me.exists(tThreadID) then
      tThreadObj = createObject(#temp, getClassVariable("thread.instance.class"))
      tThreadObj.setID(tThreadID)
      repeat with tModule in [#interface, #component, #handler]
        tSymbol = symbol(tThreadKey & "_" & tModule)
        tPreIndex = EMPTY
        if tMultipleDef then
          tPreIndex = tThreadKey & "."
        end if
        if pVarMngrObj.exists(tPreIndex & tModule & ".class") then
          tClass = pVarMngrObj.GET(tPreIndex & tModule & ".class")
          if tClass.char[1] = "[" then
            tClass = value(tClass)
          end if
          if not listp(tClass) then
            tClass = [tClass]
          end if
          tObject = me.buildThreadObj(tSymbol, tClass, tThreadObj)
          tThreadObj.setaProp(tModule, tObject)
        end if
      end repeat
      pThreadList[tThreadID] = tThreadObj
    end if
  end repeat
  return 1
end

on initAll me
  repeat with i = the number of castLibs down to 1
    me.initThread(i)
  end repeat
  return 1
end

on closeThread me, tCastNumOrID
  pVarMngrObj.clear()
  if integerp(tCastNumOrID) then
    if member(pIndexField, tCastNumOrID).number > 0 then
      pVarMngrObj.dump(member(pIndexField, tCastNumOrID).number)
      if listp(value(pVarMngrObj.GET("thread.id"))) then
        tThreadKeys = pVarMngrObj.GetValue("thread.id")
      else
        tThreadKeys = [pVarMngrObj.GET("thread.id")]
      end if
    else
      return 0
    end if
  else
    if symbolp(tCastNumOrID) then
      tThreadKeys = [tCastNumOrID]
    else
      return error(me, "Invalid argument:" && tCastNumOrID, #closeThread, #major)
    end if
  end if
  repeat with tID in tThreadKeys
    tThread = pThreadList[tID]
    if voidp(tThread) then
      return error(me, "Thread not found:" && tID, #closeThread, #minor)
    end if
    tObjMgr = getObjectManager()
    if objectp(tThread.interface) then
      tObjMgr.Remove(tThread.interface.getID())
    end if
    if objectp(tThread.component) then
      tObjMgr.Remove(tThread.component.getID())
    end if
    if objectp(tThread.handler) then
      tObjMgr.Remove(tThread.handler.getID())
    end if
    pThreadList.deleteProp(tID)
  end repeat
  return 1
end

on closeAll me
  repeat with i = pThreadList.count down to 1
    me.closeThread(pThreadList.getPropAt(i))
  end repeat
  return 1
end

on print me
  repeat with i = 1 to pThreadList.count
    put pThreadList.getPropAt(i)
  end repeat
end

on buildThreadObj me, tID, tClassList, tThreadObj
  tObject = VOID
  tTemp = VOID
  tBase = pObjBaseCls.new()
  tBase.construct()
  tBase[#ancestor] = tThreadObj
  tBase.setID(tID)
  tResMgr = getResourceManager()
  tObjMgr = getObjectManager()
  tObjMgr.registerObject(tID, tBase)
  tClassList.addAt(1, tBase)
  repeat with tClass in tClassList
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      tMemNum = tResMgr.getmemnum(tClass)
      if tMemNum < 1 then
        tObjMgr.unregisterObject(tID)
        return error(me, "Script not found:" && tMemNum, #buildThreadObj, #major)
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    tObject[#ancestor] = tTemp
    tTemp = tObject
    tObjMgr.unregisterObject(tID)
    tObjMgr.registerObject(tID, tObject)
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return tObject
end
