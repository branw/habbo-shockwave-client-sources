on constructConnectionManager
  return createManager(#connection_manager, getClassVariable("connection.manager.class"))
end

on deconstructConnectionManager
  return removeManager(#connection_manager)
end

on getConnectionManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#connection_manager) then
    return constructConnectionManager()
  end if
  return tObjMngr.getManager(#connection_manager)
end

on createConnection tid, tHost, tPort, tProtocol
  return getConnectionManager().create(tid, tHost, tPort, tProtocol)
end

on getConnection tid
  return getConnectionManager().get(tid)
end

on removeConnection tid
  return getConnectionManager().remove(tid)
end

on connectionExists tid
  return getConnectionManager().exists(tid)
end

on registerParser tid, tParserID
  return getConnectionManager().register(#parser, tid, tParserID)
end

on unregisterParser tid, tParserID
  return getConnectionManager().unregister(#parser, tid, tParserID)
end

on registerHandler tid, tHandlerID
  return getConnectionManager().register(#handler, tid, tHandlerID)
end

on unregisterHandler tid, tHandlerID
  return getConnectionManager().unregister(#handler, tid, tHandlerID)
end

on closeAllConnections
  return getConnectionManager().closeAll()
end

on printConnections
  return getConnectionManager().print()
end
