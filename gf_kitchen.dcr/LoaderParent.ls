property pLoadingList, loaderProgress

on new me
  put "INIT LOADER"
  pLoadingList = []
  loaderProgress = [:]
  return me
end

on AddpreloadNetThing me, url
  preloadNetThing(url)
  pLoadingList.add(url)
end

on LoaderLoop me
  LoadingReady = 1
  repeat with f in pLoadingList
    if loaderProgress.findPos(f) = VOID then
      loaderProgress.addProp(f, 0)
    else
      if getStreamStatus(f).bytesTotal > 0 then
        percentNow = float(1.0 * getStreamStatus(f).bytesSoFar / getStreamStatus(f).bytesTotal)
      else
        percentNow = 0
      end if
      loaderProgress.setProp(f, percentNow)
    end if
    if getStreamStatus(f).state <> "Complete" then
      LoadingReady = 0
      put "still loading" && getStreamStatus(f)
      next repeat
    end if
  end repeat
  if LoadingReady = 1 then
    me.LoadingCompleted()
  end if
end

on LoadingCompleted me
  global gLoader
  put "LOADING READY"
  pLoadingList = VOID
  gLoader = VOID
  me = VOID
  go(the frame + 1)
end

on LoaderStatusBar me
  sofar = 0
  total = count(loaderProgress)
  repeat with i = 1 to count(loaderProgress)
    sofar = sofar + loaderProgress.getProp(loaderProgress.getPropAt(i))
  end repeat
  percentNow = float(1.0 * sofar / total)
  put percentNow * 146
  if member("progressBack").mediaReady and member("progressbar").mediaReady then
    s = sprite(71)
    s.rect = rect(s.left, s.top, s.left + 146 * percentNow, s.bottom)
  end if
end
