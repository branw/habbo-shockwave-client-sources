property pState, pLogoSpr, pFadingLogo, pLogoStartTime

on construct me
  tSession = createObject(#session, getClassVariable("variable.manager.class"))
  tSession.set("client_startdate", the date)
  tSession.set("client_starttime", the long time)
  tSession.set("client_version", getVariable("system.version"))
  tSession.set("client_url", getMoviePath())
  tSession.set("client_lastclick", EMPTY)
  createObject(#headers, getClassVariable("variable.manager.class"))
  createObject(#classes, getClassVariable("variable.manager.class"))
  createObject(#cache, getClassVariable("variable.manager.class"))
  createBroker(#Initialize)
  registerMessage(#requestHotelView, me.getID(), #initTransferToHotelView)
  pFadingLogo = 0
  pLogoStartTime = 0
  return me.updateState("load_variables")
end

on deconstruct me
  return me.hideLogo()
end

on showLogo me
  if memberExists("Logo") then
    tmember = member(getmemnum("Logo"))
    pLogoSpr = sprite(reserveSprite(me.getID()))
    pLogoSpr.member = tmember
    pLogoSpr.ink = 0
    pLogoSpr.blend = 90
    pLogoSpr.locZ = -20000001
    pLogoSpr.loc = point((the stage).rect.width / 2, (the stage).rect.height / 2 - tmember.height)
    pLogoStartTime = the milliSeconds
  end if
  return 1
end

on hideLogo me
  if pLogoSpr.ilk = #sprite then
    releaseSprite(pLogoSpr.spriteNum)
    pLogoSpr = VOID
  end if
  return 1
end

on initTransferToHotelView me
  tShowLogoForMs = 1000
  tLogoNowShownMs = the milliSeconds - pLogoStartTime
  if tLogoNowShownMs >= tShowLogoForMs then
    createTimeout("logo_timeout", 2000, #initUpdate, me.getID(), VOID, 1)
  else
    createTimeout("init_timeout", tShowLogoForMs - tLogoNowShownMs + 1, #initTransferToHotelView, me.getID(), VOID, 1)
  end if
end

on initUpdate me
  pFadingLogo = 1
  receiveUpdate(me.getID())
end

on update me
  if pFadingLogo then
    tBlend = 0
    if pLogoSpr <> VOID then
      pLogoSpr.blend = pLogoSpr.blend - 10
      tBlend = pLogoSpr.blend
    end if
    if tBlend <= 0 then
      removeUpdate(me.getID())
      pFadingLogo = 0
      me.hideLogo()
      executeMessage(#showHotelView)
    end if
  end if
end

on assetDownloadCallbacks me, tAssetId, tSuccess
  if tSuccess = 0 then
    case tAssetId of
      "load_variables", "load_texts", "load_casts":
        fatalError(["error": tAssetId])
    end case
    return 0
  end if
  case tAssetId of
    "load_variables":
      me.updateState("load_params")
    "load_texts":
      me.updateState("load_casts")
    "load_casts":
      me.updateState("validate_resources")
    "validate_resources":
      me.updateState("validate_resources")
  end case
end

on updateState me, tstate
  case tstate of
    "load_variables":
      pState = tstate
      me.showLogo()
      cursor(4)
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        repeat with i = 1 to 9
          tParamBundle = externalParamValue("sw" & i)
          if not voidp(tParamBundle) then
            the itemDelimiter = ";"
            repeat with j = 1 to tParamBundle.item.count
              tParam = tParamBundle.item[j]
              the itemDelimiter = "="
              if tParam.item.count > 1 then
                tKey = tParam.item[1]
                tValue = tParam.item[2..tParam.item.count]
                if tKey = "client.fatal.error.url" then
                  getVariableManager().set(tKey, tValue)
                else
                  if tKey = "client.allow.cross.domain" then
                    getVariableManager().set(tKey, tValue)
                  else
                    if tKey = "client.notify.cross.domain" then
                      getVariableManager().set(tKey, tValue)
                    else
                      if tKey = "external.variables.txt" then
                        getSpecialServices().setExtVarPath(tValue)
                      else
                        if tKey = "processlog.enabled" then
                          getVariableManager().set(tKey, tValue)
                        end if
                      end if
                    end if
                  end if
                end if
              end if
              the itemDelimiter = ";"
            end repeat
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      tURL = getExtVarPath()
      tMemName = tURL
      if tURL contains "?" then
        tParamDelim = "&"
      else
        tParamDelim = "?"
      end if
      if the moviePath contains "http://" then
        tURL = tURL & tParamDelim & the milliSeconds
      else
        if tURL contains "http://" then
          tURL = tURL & tParamDelim & the milliSeconds
        end if
      end if
      sendProcessTracking(9)
      tMemNum = queueDownload(tURL, tMemName, #field, 1)
      if tMemNum = 0 then
        fatalError(["error": tstate])
        return 0
      else
        return registerDownloadCallback(tMemNum, #assetDownloadCallbacks, me.getID(), tstate)
      end if
    "load_params":
      pState = tstate
      dumpVariableField(getExtVarPath())
      removeMember(getExtVarPath())
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        repeat with i = 1 to 9
          tParamBundle = externalParamValue("sw" & i)
          if not voidp(tParamBundle) then
            the itemDelimiter = ";"
            repeat with j = 1 to tParamBundle.item.count
              tParam = tParamBundle.item[j]
              the itemDelimiter = "="
              if tParam.item.count > 1 then
                getVariableManager().set(tParam.item[1], tParam.item[2..tParam.item.count])
              end if
              the itemDelimiter = ";"
            end repeat
          end if
        end repeat
        the itemDelimiter = tDelim
      end if
      setDebugLevel(0)
      getStringServices().initConvList()
      puppetTempo(getIntVariable("system.tempo", 30))
      if variableExists("client.reload.url") then
        getObject(#session).set("client_url", obfuscate(getVariable("client.reload.url")))
      end if
      return me.updateState("load_texts")
    "load_texts":
      pState = tstate
      tURL = getVariable("external.texts.txt")
      tMemName = tURL
      if tMemName = EMPTY then
        return me.updateState("load_casts")
      end if
      if tURL contains "?" then
        tParamDelim = "&"
      else
        tParamDelim = "?"
      end if
      if the moviePath contains "http://" then
        tURL = tURL & tParamDelim & the milliSeconds
      else
        if tURL contains "http://" then
          tURL = tURL & tParamDelim & the milliSeconds
        end if
      end if
      sendProcessTracking(12)
      tMemNum = queueDownload(tURL, tMemName, #field)
      if tMemNum = 0 then
        fatalError(["error": tstate])
        return 0
      else
        return registerDownloadCallback(tMemNum, #assetDownloadCallbacks, me.getID(), tstate)
      end if
    "load_casts":
      pState = tstate
      tTxtFile = getVariable("external.texts.txt")
      if tTxtFile <> 0 then
        if memberExists(tTxtFile) then
          dumpTextField(tTxtFile)
          removeMember(tTxtFile)
        end if
      end if
      tCastList = []
      i = 1
      repeat while 1
        if not variableExists("cast.entry." & i) then
          exit repeat
        end if
        tFileName = getVariable("cast.entry." & i)
        tCastList.add(tFileName)
        i = i + 1
      end repeat
      if count(tCastList) > 0 then
        tLoadID = startCastLoad(tCastList, 1, VOID, VOID, 1)
        if getVariable("loading.bar.active") then
          showLoadingBar(tLoadID, [#buffer: #window, #locY: 500, #width: 300])
        end if
        return registerCastloadCallback(tLoadID, #assetDownloadCallbacks, me.getID(), tstate)
      else
        return me.updateState("init_threads")
      end if
    "validate_resources":
      pState = tstate
      tCastList = []
      tNewList = []
      tVarMngr = getVariableManager()
      i = 1
      repeat while 1
        if not tVarMngr.exists("cast.entry." & i) then
          exit repeat
        end if
        tFileName = tVarMngr.GET("cast.entry." & i)
        tCastList.add(tFileName)
        i = i + 1
      end repeat
      if count(tCastList) > 0 then
        repeat with tCast in tCastList
          if not castExists(tCast) then
            tNewList.add(tCast)
          end if
        end repeat
      end if
      if count(tNewList) > 0 then
        tLoadID = startCastLoad(tNewList, 1, VOID, VOID, 1)
        if getVariable("loading.bar.active") then
          showLoadingBar(tLoadID, [#buffer: #window, #locY: 500, #width: 300])
        end if
        return registerCastloadCallback(tLoadID, #assetDownloadCallbacks, me.getID(), tstate)
      else
        return me.updateState("init_threads")
      end if
    "init_threads":
      pState = tstate
      cursor(0)
      (the stage).title = getVariable("client.window.title")
      me.hideLogo()
      getThreadManager().initAll()
      return executeMessage(#Initialize, "initialize")
  end case
  return error(me, "Unknown state:" && tstate, #updateState, #major)
end
