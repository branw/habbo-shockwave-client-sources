property pDynDownloadURL, pFurniCastNameTemplate, pDownloadQueue, pPriorityDownloadQueue, pCurrentDownLoads, pDownloadedAssets, pBypassList, pFurniRevisionList, pRevisionsReceived, pRevisionsLoading, pAliasList, pAliasListReceived, pAliasListLoading

on construct me
  if variableExists("dynamic.download.url") then
    pDynDownloadURL = getVariable("dynamic.download.url")
  else
    pDynDownloadURL = "dynamic_content/"
  end if
  if variableExists("dynamic.download.name.template") then
    pFurniCastNameTemplate = getVariable("dynamic.download.name.template")
  else
    pFurniCastNameTemplate = "hh_furni_xx_%typeid%.cct"
  end if
  pDownloadQueue = [:]
  pPriorityDownloadQueue = [:]
  pCurrentDownLoads = [:]
  pDownloadedAssets = [:]
  pFurniRevisionList = [:]
  pRevisionsReceived = 0
  pRevisionsLoading = 0
  pAliasList = [:]
  pAliasListReceived = 0
  pAliasListLoading = 0
  pBypassList = value(getVariable("dyn.download.bypass.list", []))
end

on isAssetDownloaded me, tAssetId
  repeat with tBypassItem in pBypassList
    tBypassWildLength = tBypassItem.length
    tBypassItem = replaceChunks(tBypassItem, "?", EMPTY)
    if tAssetId = tBypassItem then
      return 1
    end if
    if tAssetId starts tBypassItem and tAssetId.length = tBypassWildLength then
      return 1
    end if
  end repeat
  tStatus = me.checkDownloadStatus(tAssetId)
  case tStatus of
    #downloaded, #failed:
      return 1
  end case
  return 0
end

on downloadCastDynamically me, tAssetId, tAssetType, tCallbackObjectID, tCallBackHandler, tPriorityDownload, tCallbackParams
  if tAssetId = EMPTY or voidp(tAssetId) then
    error(me, "tAssetId was empty, returning with true just to prevent download sequence!", #downloadCastDynamically)
    return 1
  end if
  tStatus = me.checkDownloadStatus(tAssetId)
  case tStatus of
    #nodata, #downloading, #inqueue:
      me.addToDownloadQueue(tAssetId, tCallbackObjectID, tCallBackHandler, tPriorityDownload, 0, tCallbackParams)
      me.tryNextDownload()
      return 1
    #downloaded, #failed:
      return 0
  end case
  return error(me, "Invalid status type found:" && tStatus, #downloadCastDynamically)
end

on handleCompletedCastDownload me, tAssetId
  tDownloadObj = pCurrentDownLoads[tAssetId]
  tCastName = tDownloadObj.getDownloadName()
  tCastNum = FindCastNumber(tCastName)
  if tCastNum = 0 then
    tDownloadObj.purgeCallbacks(0)
    pDownloadedAssets[tAssetId] = #failed
    pCurrentDownLoads.deleteProp(tAssetId)
    me.tryNextDownload()
    return error(me, "Cast " & tCastName & " was not available", #handleCompletedCastDownload)
  end if
  me.acquireAssetsFromCast(tCastNum, tAssetId)
  tResetOk = getCastLoadManager().ResetOneDynamicCast(tCastNum)
  if not tResetOk then
    error(me, "Cast reset failed:" && tCastNum, #handleCompletedCastDownload)
  end if
  pCurrentDownLoads.deleteProp(tAssetId)
  pDownloadedAssets[tAssetId] = #downloaded
  tDownloadObj.purgeCallbacks(1)
  me.tryNextDownload()
end

on checkDownloadStatus me, tAssetId
  tDownloadStatus = pDownloadedAssets.getaProp(tAssetId)
  if tDownloadStatus <> VOID then
    return tDownloadStatus
  else
    if pDownloadQueue.getaProp(tAssetId) <> VOID then
      return #inqueue
    else
      if pPriorityDownloadQueue.getaProp(tAssetId) <> VOID then
        return #inqueue
      else
        if pCurrentDownLoads.getaProp(tAssetId) <> VOID then
          return #downloading
        end if
      end if
    end if
  end if
  return #nodata
end

on addToDownloadQueue me, tAssetId, tCallbackObjectID, tCallBackHandler, tPriorityDownload, tAllowIndexing, tCallbackParams
  if voidp(tAllowIndexing) then
    tAllowIndexing = 0
  end if
  tDownloadObj = VOID
  if pDownloadQueue.getaProp(tAssetId) <> VOID then
    tDownloadObj = pDownloadQueue.getaProp(tAssetId)
  else
    if pPriorityDownloadQueue.getaProp(tAssetId) <> VOID then
      tDownloadObj = pPriorityDownloadQueue.getaProp(tAssetId)
    else
      if pCurrentDownLoads.getaProp(tAssetId) <> VOID then
        tDownloadObj = pCurrentDownLoads.getaProp(tAssetId)
      else
        tDownloadObj = createObject("dyndownload-" & tAssetId, getClassVariable("dyn.download.instance"))
        if not tDownloadObj then
          error(me, "Could not create download object. Could it be a duplicate:" && tAssetId, #addToDownloadQueue)
          return 0
        end if
        tDownloadObj.setAssetId(tAssetId)
        tDownloadObj.setIndexing(tAllowIndexing)
        if tPriorityDownload then
          pPriorityDownloadQueue.addProp(tAssetId, tDownloadObj)
        else
          pDownloadQueue.addProp(tAssetId, tDownloadObj)
        end if
      end if
    end if
  end if
  tDownloadObj.addCallbackListener(tCallbackObjectID, tCallBackHandler, tCallbackParams)
end

on tryNextDownload me
  if not pAliasListReceived then
    if not pAliasListLoading then
      pAliasList = [:]
      pAliasListLoading = 1
      tConn = getConnection(getVariableValue("connection.info.id"))
      tConn.send("GET_ALIAS_LIST")
    end if
    return 0
  end if
  if not pRevisionsReceived then
    if not pRevisionsLoading then
      pFurniRevisionList = [:]
      pRevisionsLoading = 1
      getConnection(getVariableValue("connection.room.id")).send("GET_FURNI_REVISIONS")
    end if
    return 0
  end if
  tMaxItemsInProcess = 1
  tDownloadObj = VOID
  if pCurrentDownLoads.count >= tMaxItemsInProcess then
    return 0
  end if
  if pPriorityDownloadQueue.count > 0 then
    tDownloadObj = getAt(pPriorityDownloadQueue, 1)
    tAssetId = tDownloadObj.getAssetId()
    pPriorityDownloadQueue.deleteProp(tAssetId)
  else
    if pDownloadQueue.count > 0 then
      tDownloadObj = getAt(pDownloadQueue, 1)
      tAssetId = tDownloadObj.getAssetId()
      pDownloadQueue.deleteProp(tAssetId)
    else
      return 0
    end if
  end if
  if me.checkDownloadStatus(tAssetId) = #downloaded then
    tDownloadObj.purgeCallbacks(1)
    return me.tryNextDownload()
  end if
  pCurrentDownLoads.addProp(tAssetId, tDownloadObj)
  tAliasedAssetId = tAssetId
  if not voidp(pAliasList.getaProp(tAssetId)) then
    tAliasedAssetId = pAliasList[tAssetId]
  end if
  tDownloadURL = pDynDownloadURL & pFurniCastNameTemplate
  tFixedAssetId = replaceChunks(tAliasedAssetId, " ", "_")
  tDownloadURL = replaceChunks(tDownloadURL, "%typeid%", tFixedAssetId)
  if not voidp(pFurniRevisionList.findPos(tAssetId)) then
    tRevision = string(pFurniRevisionList[tAssetId])
  else
    tRevision = EMPTY
  end if
  tDownloadURL = replaceChunks(tDownloadURL, "%revision%", tRevision)
  tDownloadObj.setDownloadName(tDownloadURL)
  tAllowIndexing = tDownloadObj.getIndexing()
  if variableExists("dynamic.download.delay") then
    tTimeout = getVariable("dynamic.download.delay")
    createTimeout("dynamicdelay" & the milliSeconds, tTimeout, #executeDownloadRequest, me.getID(), [tAssetId, tDownloadURL, tAllowIndexing], 1)
  else
    me.executeDownloadRequest([tAssetId, tDownloadURL, tAllowIndexing])
  end if
end

on executeDownloadRequest me, tParams
  tAssetId = tParams[1]
  tDownloadURL = tParams[2]
  tAllowIndexing = tParams[3]
  tDownloadRefId = startCastLoad(tDownloadURL, 1, 1, tAllowIndexing)
  registerCastloadCallback(tDownloadRefId, #handleCompletedCastDownload, me.getID(), tAssetId)
end

on acquireAssetsFromCast me, tCastNum, tAssetId
  if voidp(tAssetId) then
    tAssetId = EMPTY
  end if
  tCast = castLib(tCastNum)
  if ilk(tCast) <> #castLib then
    error(me, "Download seems invalid, item is not a cast!", #acquireAssetsFromCast)
    return 0
  end if
  tSavedPaletteRefs = [:]
  repeat with tMemNo = 1 to the number of castMembers of castLib the number of tCast
    tmember = member(tMemNo, tCast.number)
    tMemType = tmember.type
    tMemName = tmember.name
    case tMemType of
      #bitmap:
        if member(tMemName).castLibNum > 4 then
          if ilk(tmember.paletteRef) <> #symbol then
            tSourceMemName = tmember.name
            tAliasedMemName = me.doAliasReplacing(tSourceMemName, tAssetId)
            tSavedPaletteRefs[tAliasedMemName] = tmember.paletteRef.name
            tmember.paletteRef = #systemMac
          end if
          me.copyMemberToBin(tmember, tAssetId)
        end if
      #palette:
        if member(tMemName).castLibNum > 4 then
          me.copyMemberToBin(tmember, VOID)
        end if
      #field:
        tSourceText = tmember.text
        tAliasedText = me.doAliasReplacing(tSourceText, tAssetId)
        tmember.text = tAliasedText
        if tMemName = "asset.index" then
          tClassesContainer = getObject(getVariable("room.classes.container"))
          repeat with i = 1 to tmember.lineCount
            tLine = tmember.line[i]
            if stringp(tLine) then
              if tLine.length > 3 then
                tLineData = value(tLine)
                tAssetId = tLineData[#id]
                tAssetClasses = tLineData[#classes]
                tClassesContainer.set(tAssetId, tAssetClasses)
                pDownloadedAssets[tAssetId] = #downloaded
              end if
            end if
          end repeat
        else
          if tMemName = "memberalias.index" then
            getResourceManager().readAliasIndexesFromField(tMemName, tCastNum)
          else
            if tMemName contains ".props" or tMemName contains ".data" then
              me.copyMemberToBin(tmember, tAssetId)
            end if
          end if
        end if
      #script:
        me.copyMemberToBin(tmember)
    end case
  end repeat
  repeat with i = 1 to tSavedPaletteRefs.count
    tMemberName = tSavedPaletteRefs.getPropAt(i)
    tPaletteName = tSavedPaletteRefs[tMemberName]
    member(getmemnum(tMemberName)).paletteRef = member(getmemnum(tPaletteName))
  end repeat
end

on copyMemberToBin me, tSourceMember, tTargetAssetClass
  if voidp(tTargetAssetClass) then
    tTargetAssetClass = EMPTY
  end if
  if tSourceMember.type <> #empty then
    if getmemnum(tSourceMember.name) = 0 then
      tSourceMemName = tSourceMember.name
      tTargetMemName = me.doAliasReplacing(tSourceMemName, tTargetAssetClass)
      tTargetMemberNum = createMember(tTargetMemName, tSourceMember.type, 0)
      if tTargetMemberNum = 0 then
        return error(me, "Could not create a new member for copying: " & tTargetMemName, #copyMemberToBin)
      end if
      tTargetMember = member(tTargetMemberNum)
      tTargetMember.media = tSourceMember.media
    end if
  end if
end

on doAliasReplacing me, tSourceString, tTargetAssetClass
  tAliasedSTring = tSourceString
  if not voidp(pAliasList[tTargetAssetClass]) then
    tSourceAssetClass = pAliasList.getaProp(tTargetAssetClass)
    if not voidp(tSourceAssetClass) then
      tAliasedSTring = replaceChunks(tAliasedSTring, tSourceAssetClass, tTargetAssetClass)
    end if
  end if
  return tAliasedSTring
end

on setAssetAlias me, tOriginalClass, tAliasClass
  if voidp(tOriginalClass) and voidp(tAliasClass) then
    pAliasListLoading = 0
    pAliasListReceived = 1
    return 1
  end if
  pAliasList[tOriginalClass] = tAliasClass
end

on setFurniRevision me, tClass, tRevision, tIsFurni
  if voidp(tClass) then
    pRevisionsReceived = 1
    pRevisionsLoading = 0
    me.tryNextDownload()
    return 1
  end if
  tOffset = offset("*", tClass)
  if tOffset then
    tClass = tClass.char[1..tOffset - 1]
  end if
  if not voidp(pFurniRevisionList[tClass]) then
    pFurniRevisionList[tClass] = max(pFurniRevisionList[tClass], tRevision)
  else
    pFurniRevisionList[tClass] = tRevision
  end if
  return 1
end
