on prepareMovie
  if externalParamValue("sw9") = "processlog.enabled=1" then
    getNetText("javascript:log(8)")
  end if
  the debugPlaybackEnabled = 0
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
