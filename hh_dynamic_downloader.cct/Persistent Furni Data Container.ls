property pStuffData, pWallitemData, pStuffDataByClass, pWallitemDataByClass, pMemberName, pRetryDownloadCount

on construct me
  pStuffData = [:]
  pStuffData.sort()
  pWallitemData = [:]
  pWallitemData.sort()
  pStuffDataByClass = [:]
  pStuffDataByClass.sort()
  pWallitemDataByClass = [:]
  pWallitemDataByClass.sort()
  pMemberName = getUniqueID()
  pDownloadRetryCount = 1
  if variableExists("furnidata.load.url") then
    tURL = getVariable("furnidata.load.url")
    tHash = getSpecialServices().getSessionHash()
    if tHash = EMPTY then
      tHash = string(random(1000000))
    end if
    tURL = replaceChunks(tURL, "%hash%", tHash)
    me.initDownload(tURL)
  end if
end

on deconstruct me
  pStuffData = [:]
  pWallitemData = [:]
end

on getProps me, ttype, tID
  case ttype of
    "s":
      return pStuffData.getaProp(tID)
    "i", "e":
      return pWallitemData.getaProp(tID)
    otherwise:
      error(me, "invalid item type", #getProps, #minor)
  end case
end

on getPropsByClass me, ttype, tClass
  case ttype of
    "s":
      return pStuffDataByClass.getaProp(tClass)
    "i", "e":
      return pWallitemDataByClass.getaProp(tClass)
    otherwise:
      error(me, "invalid item type", #getProps, #minor)
  end case
end

on initDownload me, tSourceURL
  if not createMember(pMemberName, #field) then
    return error(me, "Could not create member!", #initDownload)
  end if
  tMemNum = queueDownload(tSourceURL, pMemberName, #field, 1)
  registerDownloadCallback(tMemNum, #downloadCallback, me.getID(), tMemNum)
end

on downloadCallback me, tParams, tSuccess
  if tSuccess then
    tTime = the milliSeconds
    pData = [:]
    tmember = member(tParams)
    tNewArgument = [#member: tmember, #start: 1, #count: 1]
    createTimeout(getUniqueID(), 10, #parseCallback, me.getID(), tNewArgument, 1)
    executeMessage(#furnidataReceived)
  else
    fatalError(["error": "furnidata"])
    return error(me, "Failure while loading furnidata", #downloadCallback, #critical)
  end if
end

on parseCallback me, tArgument
  tmember = tArgument[#member]
  tStartingLine = tArgument[#start]
  tLineCount = tArgument[#count]
  if tStartingLine + tLineCount > tmember.text.line.count then
    tLineCount = tmember.text.line.count - tStartingLine
  end if
  repeat with l = tStartingLine to tStartingLine + tLineCount
    tVal = value(tmember.text.line[l])
    if ilk(tVal) = #list then
      repeat with tItem in tVal
        tdata = [:]
        tdata[#type] = tItem[1]
        tdata[#classID] = value(tItem[2])
        tdata[#class] = tItem[3]
        tdata[#revision] = value(tItem[4])
        tdata[#defaultDir] = value(tItem[5])
        tdata[#xdim] = value(tItem[6])
        tdata[#ydim] = value(tItem[7])
        tdata[#partColors] = tItem[8]
        tdata[#localizedName] = decodeUTF8(tItem[9])
        tdata[#localizedDesc] = decodeUTF8(tItem[10])
        getThread("dynamicdownloader").getComponent().setFurniRevision(tdata[#class], tdata[#revision], tdata[#type] = "s")
        if tdata[#type] = "s" then
          pStuffData.setaProp(tdata[#classID], tdata)
          pStuffDataByClass.setaProp(tItem[3], tdata)
          next repeat
        end if
        pWallitemData.setaProp(tdata[#classID], tdata)
        pWallitemDataByClass.setaProp(tItem[3], tdata)
      end repeat
    end if
  end repeat
  tNewArgument = [#member: tmember, #start: tStartingLine + tLineCount, #count: tLineCount]
  if tStartingLine + tLineCount >= tmember.text.line.count then
    getThread("dynamicdownloader").getComponent().setFurniRevision(VOID)
    sendProcessTracking(25)
  else
    createTimeout(getUniqueID(), 250, #parseCallback, me.getID(), tNewArgument, 1)
  end if
end
