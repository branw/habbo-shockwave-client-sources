on prepareMovie
  castLib("fuse_client").preloadMode = 1
  clearGlobals()
  moveToFront(the stage)
end

on stopMovie
  stopClient()
  clearGlobals()
end
