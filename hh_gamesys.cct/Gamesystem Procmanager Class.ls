property pProcessorObjList, pUpdateBrokerList

on construct me
  pProcessorObjList = [:]
  pUpdateBrokerList = [:]
  return 1
end

on deconstruct me
  me.removeProcessors()
  return 1
end

on defineClient me, tID
  return me.defineProcessors(tID)
end

on distributeEvent me, tTopic, tdata
  if me.getBaseLogic().handler(symbol("store_" & tTopic)) then
    call(symbol("store_" & tTopic), me.getBaseLogic(), tdata)
  end if
  tList = pUpdateBrokerList[tTopic]
  if not listp(tList) then
    return 0
  end if
  repeat with tListenerId in tList
    tListener = pProcessorObjList[tListenerId]
    if tListener <> VOID then
      call(#handleUpdate, tListener, tTopic, tdata)
      next repeat
    end if
    pProcessorObjList.deleteProp(tListenerId)
    pUpdateBrokerList[tTopic].deleteOne(tListenerId)
  end repeat
  return 1
end

on defineProcessors me, tID
  me.removeProcessors()
  if variableExists(tID & ".processors") then
    tProcIdList = getVariableValue(tID & ".processors")
  end if
  if not listp(tProcIdList) then
    return error(me, "Processor list not found:" && tID, #defineProcessors)
  end if
  if not variableExists("gamesystem.processor.superclass") then
    return error(me, "gamesystem.processor.superclass not found.", #defineProcessors)
  end if
  tBaseProcClassList = getClassVariable("gamesystem.processor.superclass")
  repeat with tProcId in tProcIdList
    tProcObjId = symbol(tID & "_proc_" & tProcId)
    tScriptList = getClassVariable(tID & "." & tProcId & ".processor.class")
    if not listp(tScriptList) then
      return error(me, "Script list not found:" && tID & "." & tProcId, #defineProcessors)
    end if
    tScriptList.addAt(1, tBaseProcClassList)
    tProcObject = createObject(tProcObjId, tScriptList)
    if not objectp(tProcObject) then
      return error(me, "Unable to create processor object:" && tProcObjId && tScriptList && tScriptList.ilk, #defineProcessors)
    end if
    tProcObject[#pFacadeId] = tID
    tProcObject[#pID] = tProcId
    tProcObject.setID(tProcId, tID)
    pProcessorObjList.addProp(tProcId, tProcObject)
    tProcessorRegList = getVariableValue(tID & "." & tProcId & ".processor.updates")
    if listp(tProcessorRegList) then
      repeat with tMsg in tProcessorRegList
        if tMsg = VOID then
          return error(me, "Invalid format in processor message:" && tProcObjId && tMsg, #defineProcessors)
        end if
        if pUpdateBrokerList[tMsg] = VOID then
          pUpdateBrokerList.addProp(tMsg, [])
        end if
        if pUpdateBrokerList[tMsg].getPos(tProcId) = 0 then
          pUpdateBrokerList[tMsg].add(tProcId)
        end if
      end repeat
    end if
  end repeat
  return 1
end

on removeProcessors me
  repeat with pProc in pProcessorObjList
    removeObject(pProc.getID())
  end repeat
  pProcessorObjList = [:]
  pUpdateBrokerList = [:]
  return 1
end
