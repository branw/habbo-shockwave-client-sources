property ancestor, pStatus, pMemName, pMemNum, pURL, pType, pCallBack, pNetId, pPercent, ptryCount

on new me
  return me
end

on define me, tMemName, tdata
  pStatus = #initializing
  pMemName = tMemName
  pMemNum = tdata[#memNum]
  pURL = tdata[#url]
  pType = tdata[#type]
  pCallBack = tdata[#callback]
  pPercent = 0.0
  return Activate(me)
end

on addCallBack me, tMemName, tCallback
  if tMemName <> pMemName then
    return 0
  end if
  pCallBack = tCallback
  return 1
end

on getProperty me, tProp
  case tProp of
    #status:
      return pStatus
    #Percent:
      return pPercent
    #url:
      return pURL
    #type:
      return pType
  end case
  return 0
end

on Activate me
  if pType = #text or pType = #field then
    pNetId = getNetText(pURL)
  else
    pNetId = preloadNetThing(pURL)
  end if
  pStatus = #LOADING
  ptryCount = 0
  return 1
end

on update me
  if pStatus <> #LOADING then
    return 0
  end if
  tStreamStatus = getStreamStatus(pNetId)
  if listp(tStreamStatus) then
    tBytesSoFar = tStreamStatus[#bytesSoFar]
    tBytesTotal = tStreamStatus[#bytesTotal]
    if tBytesTotal = 0 then
      tBytesTotal = tBytesSoFar
    end if
    if tStreamStatus[#bytesSoFar] > 0 then
      pPercent = float(1.0 * tBytesSoFar / tBytesTotal)
    end if
  end if
  if netDone(pNetId) = 1 then
    if netError(pNetId) = "OK" then
      importFileToCast(me, pURL)
      getDownloadManager().removeActiveTask(pMemName, pCallBack)
      pStatus = #complete
      return 1
    else
      error(me, "Download error:" & RETURN & pMemName & RETURN & getDownloadManager().solveNetErrorMsg(netError(pNetId)), #update)
      case netError(pNetId) of
        6, 4159, 4165:
          if not (pURL contains getDownloadManager().getProperty(#defaultURL)) then
            pURL = getDownloadManager().getProperty(#defaultURL) & pURL
            Activate(me)
          else
            getDownloadManager().removeActiveTask(pMemName, pCallBack)
          end if
        4242:
          return getDownloadManager().removeActiveTask(pMemName, pCallBack)
        4155:
          nothing()
      end case
      ptryCount = ptryCount + 1
      if ptryCount > getIntVariable("castload.failure.count", 10) then
        getDownloadManager().removeActiveTask(pMemName, pCallBack)
        return error(me, "Download failed:" & RETURN & pURL, #update)
      end if
    end if
  end if
end

on importFileToCast me
  if pType = #text or pType = #field then
    member(pMemNum).text = netTextresult(pNetId)
  else
    importFileInto(member(pMemNum), pURL)
  end if
  member(pMemNum).name = pMemName
  return 1
end
