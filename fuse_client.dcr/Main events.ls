on startMovie
  return startClient()
end

on stopMovie
  return stopClient()
end

on startClient
  clearGlobals()
  moveToFront(the stage)
  (the stage).title = EMPTY
  constructObjectManager()
  dumpVariableField("System Variables")
  resetCastLibs(0, 0)
  preIndexMembers()
  dumpTextField("System Texts")
  constructCoreThread()
  return 1
end

on stopClient
  global gObjs
  if voidp(gObjs) then
    return 0
  end if
  if objectExists(#connection_manager) then
    closeAllConnections()
  end if
  if the runMode contains "Author" then
    deconstructObjectManager()
    deconstructErrorManager()
  end if
  clearGlobals()
  return 1
end

on resetClient
  if the runMode contains "Author" then
    stopClient()
    startClient()
  else
    tURL = the moviePath
    if objectExists(#session) then
      if getObject(#session).exists("client_url") then
        tURL = getObject(#session).get("client_url")
      end if
    end if
    gotoNetPage(tURL)
  end if
  return 1
end
