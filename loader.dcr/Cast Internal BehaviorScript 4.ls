on exitFrame me
  global gSessionStatusLogger
  gSessionStatusLogger = new(script("Session Status Logger"))
  gSessionStatusLogger.signal("loader_start")
  startLoading()
end
