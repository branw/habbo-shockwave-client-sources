property pConnectionId, pQueue

on new me
  return me
end

on construct me
  pConnectionId = #mus_data_connection
  pCallBacks = [:]
  pQueue = []
  return 1
end

on deconstruct me
  return removeConnection(pConnectionId)
end

on retrieveData me, tid, tAuth, tCallBackObject
  pQueue.add([#type: #retrieve, #id: tid, #auth: tAuth, #callback: tCallBackObject])
  if pQueue.count = 1 or not connectionExists(pConnectionId) then
    me.next()
  end if
end

on storeData me, tdata, tCallBackObject
  pQueue.add([#type: #store, #data: tdata, #callback: tCallBackObject])
  if pQueue.count = 1 or not connectionExists(pConnectionId) then
    me.next()
  end if
end

on addMessageToQueue me, tMsg
  pQueue.add([#type: #fusemsg, #message: tMsg])
  if pQueue.count = 1 or not connectionExists(pConnectionId) then
    me.next()
  end if
end

on checkConnection me
  if getConnection(pConnectionId).connectionReady() then
    getConnection(pConnectionId).send("LOGIN" && getObject(#session).get(#userName) && getObject(#session).get(#password))
    me.next()
  else
    createTimeout(#bin_data_access_mgr_connopen, 1000, #checkConnection, #binary_data_manager, VOID, 1)
  end if
end

on next me
  if not connectionExists(pConnectionId) then
    createConnection(pConnectionId, getVariable("enterprise.server.mus_host"), integer(getVariable("enterprise.server.mus_port")), #mus)
    getConnection(pConnectionId).registerBinaryDataHandler(#binary_data_manager)
    createTimeout(#bin_data_access_mgr_connopen, 1000, #checkConnection, #binary_data_manager, VOID, 1)
  else
    if getConnection(pConnectionId).connectionReady() then
      if pQueue.count > 0 then
        tTask = pQueue[1]
        case tTask.type of
          #store:
            return getConnection(pConnectionId).sendBinary(tTask.data)
          #retrieve:
            return getConnection(pConnectionId).send("GETBINDATA" && tTask.id && tTask.auth)
          #fusemsg:
            pQueue.deleteAt(1)
            getConnection(pConnectionId).send(tTask.message)
            me.next()
            return 1
        end case
      end if
    end if
  end if
end

on binaryDataStored me, tid
  tTask = pQueue[1]
  if tTask[#callback] <> VOID then
    call(#binaryDataStored, getObject(tTask[#callback]), tid)
  end if
  pQueue.deleteAt(1)
  me.next()
end

on binaryDataAuthKeyError me, tid
  pQueue.deleteAt(1)
  me.next()
end

on binaryDataReceived me, tdata
  tTask = pQueue[1]
  pQueue.deleteAt(1)
  if tTask[#callback] <> VOID then
    call(#binaryDataReceived, getObject(tTask[#callback]), tdata, tTask[#id])
  end if
  me.next()
end
