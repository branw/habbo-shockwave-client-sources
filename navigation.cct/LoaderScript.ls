global gLoadNo, gCurrentNetIds, gCurrentFile, gBytes, gLastF, gStartLoadingTime, gEndLoadingTime, gAllNetIds

on startLoading
  if the runMode = "Author" then
    if the movieName contains "ch_" or the movieName contains "_ch" then
      goUnit("ch_private")
    else
      goUnit("gf_private")
    end if
    exit
  end if
  gLoadNo = 0
  gLastF = 0
  gBytes = 0
  gStartLoadingTime = the milliSeconds
  gCurrentNetIds = []
  gAllNetIds = [:]
  nextLoad()
  nextLoad()
end

on nextLoad
  gLoadNo = gLoadNo + 1
  if gLoadNo <= the number of lines in field "loadlistPrivateRoom" then
    file = line gLoadNo of field "loadlistPrivateRoom"
    if the movieName contains "ch_" or the movieName contains "_ch" then
      if file = "gf_private.dcr" then
        file = "ch_private.dcr"
      end if
    end if
    if the runMode = "Author" then
      file = "http://www.habbohotel.com/dcr/dcr2505/" & file
      if the movieName contains "ch_" or the movieName contains "_ch" then
        file = "fuse.taivas.com/chabbo/dcr/dcr2806/" & file
      end if
    end if
    netId = preloadNetThing(file)
    add(gCurrentNetIds, [netId, 0, file, the milliSeconds])
    gAllNetIds.addProp(netId, 0)
    put file
  else
    if gCurrentNetIds.count = 0 then
      loadComplete()
    end if
  end if
end

on loadComplete
  global gPopUpContext2
  gLastF = 1.0
  LoaderStatusBar()
  gEndLoadingTime = the milliSeconds
  sFrame = "flat_loadReady"
  goContext(sFrame, gPopUpContext2)
  if the movieName contains "ch_" or the movieName contains "_ch" then
    goMovie("ch_private", "quickentry")
  else
    goMovie("gf_private", "quickentry")
  end if
end

on checkLoad
  global gPopUpContext2
  repeat with i = count(gCurrentNetIds) down to 1
    netId = gCurrentNetIds[i][1]
    l = getStreamStatus(gCurrentNetIds[i][1])
    if listp(l) then
      bs = getaProp(l, #bytesSoFar)
      if bs <> gCurrentNetIds[i][2] then
        gCurrentNetIds[i][2] = bs
        gCurrentNetIds[i][4] = the milliSeconds
        if getStreamStatus(netId).bytesTotal > 0 then
          percentNow = float(1.0 * getStreamStatus(netId).bytesSoFar / getStreamStatus(netId).bytesTotal)
        else
          percentNow = 0
        end if
        gAllNetIds.setProp(gCurrentNetIds[i][1], percentNow)
      else
        if the milliSeconds - gCurrentNetIds[i][4] > 25000 then
          file = gCurrentNetIds[i][3]
          netId = preloadNetThing(file)
          add(gCurrentNetIds, [netId, 0, file, the milliSeconds])
          gAllNetIds.addProp(netId, 0)
        end if
      end if
    end if
    if netDone(netId) then
      put "Done," && getaProp(l, #bytesSoFar)
      gBytes = gBytes + gCurrentNetIds[i][2]
      gAllNetIds.setProp(gCurrentNetIds[i][1], 1)
      deleteAt(gCurrentNetIds, i)
      nextLoad()
    end if
  end repeat
  LoaderStatusBar()
  sFrame = "FLAT_LOADING"
  goContext(sFrame, gPopUpContext2)
end

on LoaderStatusBar me
  sofar = 0
  total = the number of lines in field "loadlistPrivateRoom"
  repeat with i = 1 to count(gAllNetIds)
    sofar = sofar + gAllNetIds.getProp(gAllNetIds.getPropAt(i))
  end repeat
  percentNow = float(1.0 * sofar / total)
  sendAllSprites(#ProgresBar, percentNow)
end
