on prepareMovie
  clearGlobals()
  castLib(2).preloadMode = 1
  preloadNetThing(castLib(2).fileName)
  moveToFront(the stage)
  set the exitLock to 1
end

on stopMovie
  stopClient()
  clearGlobals()
end
