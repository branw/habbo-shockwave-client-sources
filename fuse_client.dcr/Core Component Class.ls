property pThreadList, pState

on new me
  return me
end

on Initialize me
  pThreadList = [:]
  me.initThread(1)
  return pThreadList[#core]
end

on construct me
  pThreadList = [#core: me]
  tSession = createObject(#session, getClassVariable("variable.manager.class"))
  tSession.set("client_startdate", the date)
  tSession.set("client_starttime", the long time)
  tSession.set("client_version", getVariable("version"))
  tSession.set("client_url", the moviePath)
  createObject(#cache, getClassVariable("variable.manager.class"))
  createObject(#layout_parser, getClassVariable("layout.parser.class"))
  createBroker(#Initialize)
  return me.updateState("load_external_variables")
end

on deconstruct me
  return me.updateState("reset")
end

on create me, tid, tInitField
  return me.initThread(tInitField, tid)
end

on remove me, tid
  return me.closeThread(tid)
end

on get me, tid
  tThread = pThreadList[tid]
  if voidp(tThread) then
    return 0
  end if
  return tThread
end

on exists me, tid
  return not voidp(pThreadList[tid])
end

on initThread me, tCastNumOrMemName, tid
  if stringp(tCastNumOrMemName) then
    if not memberExists(tCastNumOrMemName) then
      return error(me, "Index field not found:" && tCastNumOrMemName, #initThread)
    end if
    tThreadField = tCastNumOrMemName
    tCastNum = member(getmemnum(tCastNumOrMemName)).castLibNum
  else
    if symbolp(tCastNumOrMemName) then
      tThreadField = getVariable("thread.index.field")
      if the number of castLibs > 1 then
        repeat with i = 2 to the number of castLibs
          if member(tThreadField, i).number > 0 then
            tdata = createObject(#temp, getClassVariable("variable.manager.class"))
            tdata.dump(member(tThreadField, i).number)
            if symbol(tdata.get("thread.id")) = tCastNumOrMemName then
              return me.initThread(i, tid)
              exit repeat
            end if
          end if
        end repeat
      end if
    else
      if not integerp(tCastNumOrMemName) then
        return error(me, "Cast number expected:" && tCastNumOrMemName, #initThread)
      else
        if tCastNumOrMemName < 1 or tCastNumOrMemName > the number of castLibs then
          return error(me, "Cast doesn't exist:" && tCastNumOrMemName, #initThread)
        end if
      end if
      tThreadField = getVariable("thread.index.field")
      tCastNum = tCastNumOrMemName
      if member(tThreadField, tCastNum).number < 1 then
        return 0
      end if
    end if
  end if
  tdata = createObject(#temp, getClassVariable("variable.manager.class"))
  tdata.dump(member(tThreadField, tCastNum).number)
  if symbolp(tid) then
    tThread = tid
  else
    tThread = symbol(tdata.get("thread.id"))
  end if
  if not symbolp(tThread) then
    return error(me, "Invalid thread ID:" && tThread, #initThread)
  end if
  if me.exists(tThread) then
    return 0
  end if
  tThreadObj = createObject(#temp, getClassVariable("thread.instance.class"))
  tThreadObj.setID(tThread)
  repeat with tModule in [#interface, #component, #handler, #parser]
    tSymbol = symbol(tThread & "_" & tModule)
    if tdata.exists(tModule & ".class") then
      tClass = tdata.get(tModule & ".class")
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
  if objectp(tThreadObj.interface) then
    createInterface(tThreadObj.interface.getID(), tThreadObj.interface)
  end if
  if objectp(tThreadObj.component) then
    createComponent(tThreadObj.component.getID(), tThreadObj.component)
  end if
  if objectp(tThreadObj.handler) then
    createHandler(tThreadObj.handler.getID(), tThreadObj.handler)
  end if
  if objectp(tThreadObj.parser) then
    createParser(tThreadObj.parser.getID(), tThreadObj.parser)
  end if
  pThreadList[tThread] = tThreadObj
  return 1
end

on initExistingThreads me
  if the number of castLibs > 1 then
    repeat with i = the number of castLibs down to 2
      me.initThread(i)
    end repeat
  end if
  return 1
end

on closeThread me, tCastNumOrID
  tThreadField = getVariable("thread.index.field")
  tdata = createObject(#temp, getClassVariable("variable.manager.class"))
  if integerp(tCastNumOrID) then
    if member(tThreadField, tCastNumOrID).number > 0 then
      tdata.dump(member(tThreadField, tCastNumOrID).number)
      tid = symbol(tdata.get("thread.id"))
    else
      return 0
    end if
  else
    if symbolp(tCastNumOrID) then
      tid = tCastNumOrID
    else
      return error(me, "Invalid argument:" && tCastNumOrID, #closeThread)
    end if
  end if
  tThread = pThreadList[tid]
  if voidp(tThread) then
    return error(me, "Thread not found:" && tid, #closeThread)
  end if
  if objectp(tThread.getInterface()) then
    removeInterface(tThread.getInterface().getID())
    removeObject(tThread.getInterface().getID())
  end if
  if objectp(tThread.getComponent()) then
    removeComponent(tThread.getComponent().getID())
    removeObject(tThread.getComponent().getID())
  end if
  if objectp(tThread.getHandler()) then
    removeHandler(tThread.getHandler().getID())
    removeObject(tThread.getHandler().getID())
  end if
  if objectp(tThread.getParser()) then
    removeParser(tThread.getParser().getID())
    removeObject(tThread.getParser().getID())
  end if
  pThreadList.deleteProp(tid)
  return 1
end

on closeExistingThreads me
  repeat with i = pThreadList.count down to 1
    if i > 1 then
      me.closeThread(pThreadList.getPropAt(i))
    end if
  end repeat
  return 1
end

on print me
  repeat with i = 1 to pThreadList.count
    put pThreadList.getPropAt(i)
  end repeat
end

on buildThreadObj me, tid, tClassList, tThreadObj
  tObject = VOID
  tTemp = VOID
  tBase = script(getmemnum("Object Base Class")).new()
  tBase.construct()
  tBase[#ancestor] = tThreadObj
  tBase.setID(tid)
  registerObject(tid, tBase)
  tClassList.addAt(1, tBase)
  repeat with tClass in tClassList
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      tMemNum = getmemnum(tClass)
      if tMemNum < 1 then
        unregisterObject(tid)
        return error(me, "Script not found:" && tMemNum, #buildThreadObj)
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    tObject[#ancestor] = tTemp
    tTemp = tObject
    unregisterObject(tid)
    registerObject(tid, tObject)
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return tObject
end

on updateState me, tState
  case tState of
    "reset":
      pState = tState
      return me.closeExistingThreads()
    "load_external_variables":
      pState = tState
      me.getInterface().showLogo()
      cursor(4)
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        the itemDelimiter = "="
        repeat with i = 1 to 9
          tParam = externalParamValue("sw" & i)
          if not voidp(tParam) then
            if tParam.item.count = 2 then
              if tParam.item[1] = "external.variables.txt" then
                getVariableManager().set("external.variables.txt", tParam.item[2])
              end if
            end if
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      tURL = getVariable("external.variables.txt")
      tMem = tURL
      if not (the runMode contains "Author") then
        tURL = tURL & "?" & the milliSeconds
      end if
      tMember = queueDownload(tURL, tMem, #field, 1)
      return registerDownloadCallback(tMember, #updateState, me.getID(), "load_external_params")
    "load_external_params":
      pState = tState
      dumpVariableField(getVariable("external.variables.txt"))
      removeMember(getVariable("external.variables.txt"))
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        the itemDelimiter = "="
        repeat with i = 1 to 9
          tParam = externalParamValue("sw" & i)
          if not voidp(tParam) then
            if tParam.item.count = 2 then
              getVariableManager().set(tParam.item[1], tParam.item[2])
            end if
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      if variableExists("debug") then
        setDebugLevel(getIntVariable("debug"))
      end if
      puppetTempo(getIntVariable("tempo", 30))
      if variableExists("client.reload.url") then
        getObject(#session).set("client_url", getVariable("client.reload.url"))
      end if
      return me.updateState("load_external_texts")
    "load_external_texts":
      pState = tState
      if variableExists("external.texts.txt") then
        tURL = getVariable("external.texts.txt")
        tMem = tURL
        if not (the runMode contains "Author") then
          tURL = tURL & "?" & the milliSeconds
        end if
        tMember = queueDownload(tURL, tMem, #field)
        return registerDownloadCallback(tMember, #updateState, me.getID(), "load_external_casts")
      else
        return me.updateState("load_external_casts")
      end if
    "load_external_casts":
      pState = tState
      if variableExists("external.texts.txt") then
        if memberExists(getVariable("external.texts.txt")) then
          dumpTextField(getVariable("external.texts.txt"))
          removeMember(getVariable("external.texts.txt"))
        end if
      end if
      tCastList = []
      i = 1
      repeat while 1
        if not variableExists("cast.entry." & i) then
          exit repeat
        end if
        tFileName = getVariable("cast.entry." & i)
        tCastList.add(tFileName)
        i = i + 1
      end repeat
      if tCastList.count > 0 then
        tCastLoadId = startCastLoad(tCastList, 1)
        if getVariable("loading.bar.active") then
          showLoadingBar(tCastLoadId, [#buffer: #window])
        end if
        return registerCastloadCallback(tCastLoadId, #updateState, me.getID(), "validate_resources")
      else
        return me.updateState("init_threads")
      end if
    "validate_resources":
      pState = tState
      tCastList = []
      tNewList = []
      i = 1
      repeat while 1
        if not variableExists("cast.entry." & i) then
          exit repeat
        end if
        tFileName = getVariable("cast.entry." & i)
        tCastList.add(tFileName)
        i = i + 1
      end repeat
      if tCastList.count > 0 then
        repeat with tCast in tCastList
          if not castExists(tCast) then
            tNewList.add(tCast)
          end if
        end repeat
      end if
      if tNewList.count > 0 then
        tCastLoadId = startCastLoad(tNewList, 1)
        if getVariable("loading.bar.active") then
          showLoadingBar(tCastLoadId, [#buffer: #window])
        end if
        return registerCastloadCallback(tCastLoadId, #updateState, me.getID(), "validate_resources")
      else
        return me.updateState("init_threads")
      end if
    "init_threads":
      pState = tState
      cursor(0)
      (the stage).title = getVariable("client.window.title")
      me.getInterface().hideLogo()
      initExistingThreads(me)
      return executeMessage(#Initialize, "initialize")
  end case
  return error(me, "Unknown state:" && tState, #updateState)
end
