property ancestor, pFile, pURL, pNetId, pGroupId, pLoadTime, pBytesSoFar, ptryCount, pMaxTimeBeforeTryNewLoad, pMaxLoadTryBeforeAlert, pPercent, pState

on new me
  return me
end

on define me, tFile, tURL, tpreloadId
  pFile = tFile
  pURL = tURL
  pGroupId = tpreloadId
  ptryCount = 1
  pMaxTimeBeforeTryNewLoad = getIntVariable("castload.try.delay", 25000)
  pMaxLoadTryBeforeAlert = getIntVariable("castload.failure.count", 10)
  return Activate(me)
end

on Activate me
  pNetId = preloadNetThing(pURL)
  pLoadTime = the milliSeconds
  pBytesSoFar = 0
  pPercent = 0.0
  pState = #LOADING
  return 1
end

on update me
  if pState <> #done then
    DownloadCurrent(me)
  end if
end

on DownloadCurrent me
  tStreamStatus = getStreamStatus(pNetId)
  if listp(tStreamStatus) then
    if tStreamStatus.bytesSoFar > 0 then
      tBytesSoFar = tStreamStatus.bytesSoFar
      tBytesTotal = tStreamStatus.bytesTotal
      if tBytesTotal = 0 then
        tBytesTotal = tBytesSoFar
      end if
      pPercent = float(1.0 * tBytesSoFar / tBytesTotal)
      getCastLoadManager().TellStreamState(pFile, pState, pPercent, pGroupId)
    end if
    if tStreamStatus.bytesSoFar <> pBytesSoFar then
      pBytesSoFar = tStreamStatus.bytesSoFar
      pLoadTime = the milliSeconds
    else
      if the milliSeconds - pLoadTime > pMaxTimeBeforeTryNewLoad then
        error(me, "Failed network operation. Time run out while preloading" && pFile, #DownloadCurrent)
        ptryCount = ptryCount + 1
        if ptryCount >= pMaxLoadTryBeforeAlert then
          SystemAlert(me, "Failed network operation:" & RETURN & "Tried to load file" && pFile && pMaxLoadTryBeforeAlert && "times.", #DownloadCurrent)
        end if
        Activate(me)
      end if
    end if
  else
    return error(me, "Preloading problems:" && pFile & RETURN & tStreamStatus, #DownloadCurrent)
  end if
  if tStreamStatus.error <> EMPTY and tStreamStatus.error <> "OK" then
    pState = #error
    error(me, me.GetNetError(netError(pNetId)) & RETURN & pFile & RETURN & tStreamStatus, #DownloadCurrent)
    SystemAlert(me, me.GetNetError(netError(pNetId)) & RETURN & pFile & RETURN & tStreamStatus, #DownloadCurrent)
  end if
  if netDone(pNetId) then
    pPercent = 1.0
    if pState <> #error then
      pState = #done
    end if
    getCastLoadManager().DoneCurrentDownLoad(pFile, pURL, pGroupId, pState)
  end if
end

on GetNetError me, tError
  case tError of
    EMPTY:
      return "Unknown error."
    "OK":
      return "OK"
    -128:
      return "Operation was cancelled."
    0:
      return "OK"
    4:
      return "Bad MOA Class. Network Xtras may be improperly installed."
    5:
      return "Bad MOA Interface. Network Xtras may be improperly installed."
    6:
      return "General transfer error."
    20:
      return "Internal error."
    900:
      return "Failed attempt to write to locked media."
    903:
      return "Disk is full."
    905:
      return "Bad URL."
    4144:
      return "Failed network operation."
    4145:
      return "Failed network operation."
    4146:
      return "Connection could not be established with the remote host."
    4147:
      return "Failed network operation."
    4148:
      return "Failed network operation."
    4149:
      return "Data supplied by the server was in an unexpected format."
    4150:
      return "Unexpected early closing of connection."
    4151:
      return "Failed network operation."
    4152:
      return "Data returned is truncated."
    4153:
      return "Failed network operation."
    4154:
      return "Operation could not be completed due to timeout."
    4155:
      return "Not enough memory available to complete the transaction."
    4156:
      return "Protocol reply to request indicates an error in the reply."
    4157:
      return "Transaction failed to be authenticated."
    4159:
      return "Invalid URL."
    4160:
      return "Failed network operation."
    4161:
      return "Failed network operation."
    4162:
      return "Failed network operation."
    4163:
      return "Failed network operation."
    4164:
      return "Could not create a socket"
    4165:
      return "Requested Object could not be found (URL may be incorrect)."
    4166:
      return "Generic proxy failure."
    4167:
      return "Transfer was intentionally interrupted by client."
    4168:
      return "Failed network operation."
    4242:
      return "Download stopped by netAbort(url)."
    4836:
      return "Cache download stopped for an unknown reason."
  end case
  return "Other network error" & ":" && tError
end
