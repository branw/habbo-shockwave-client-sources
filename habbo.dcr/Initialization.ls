on prepareMovie
  if _player.traceScript then
    return 0
  end if
  castLib(2).preloadMode = 1
  preloadNetThing(castLib(2).fileName)
  moveToFront(the stage)
  set the exitLock to 1
  puppetTempo(15)
end

on stopMovie
  stopClient()
  go(1)
end
