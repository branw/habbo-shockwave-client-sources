property pState, pItemList, pRoomData, pUpdatePeriod, pConnectionId, pLoaderBarID, pFlatCache

on construct me
  pItemList = [#units: [:], #flats: [:], #prvunits: [:]]
  pRoomData = [:]
  pFlatCache = [:]
  pUpdatePeriod = getIntVariable("navigator.updatetime.units", 60000)
  pConnectionId = getVariableValue("connection.info.id")
  pLoaderBarID = "Navigator Loader"
  registerMessage(#show_navigator, me.getID(), #showNavigator)
  registerMessage(#hide_navigator, me.getID(), #hideNavigator)
  registerMessage(#show_hide_navigator, me.getID(), #showhidenavigator)
  registerMessage(#leaveRoom, me.getID(), #showNavigator)
  registerMessage(#Initialize, me.getID(), #updateState)
  getObject(#session).set("user_rights", [])
  return 1
end

on deconstruct me
  pItemList = [:]
  pRoomData = [:]
  pFlatCache = [:]
  unregisterMessage(#show_navigator, me.getID())
  unregisterMessage(#hide_navigator, me.getID())
  unregisterMessage(#show_hide_navigator, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#Initialize, me.getID())
  return me.updateState("reset")
end

on showNavigator me
  return me.getInterface().showNavigator()
end

on hideNavigator me
  return me.getInterface().hideNavigator(#hide)
end

on showhidenavigator me
  return me.getInterface().showhidenavigator(#hide)
end

on getState me
  return pState
end

on saveUnitList me, tMsg
  if listp(tMsg) then
    pItemList[#units] = tMsg
  end if
  return me.getInterface().createUnitlist(pItemList[#units])
end

on UpdateUnitList me, tMsg
  if listp(tMsg) then
    repeat with f = 1 to tMsg.count()
      tUnitid = tMsg.getPropAt(f)
      if not voidp(pItemList[#units][tUnitid]) then
        pItemList[#units][tUnitid][#usercount] = tMsg[f][#usercount]
      end if
    end repeat
  end if
  return me.getInterface().UpdateUnitList(pItemList[#units])
end

on prepareFlatList me, tMsg
  pItemList[#prvunits] = [:]
  if listp(tMsg) then
    repeat with f = 1 to tMsg.count()
      tUnitPort = tMsg.getPropAt(f)
      pItemList[#prvunits][tUnitPort] = tMsg[f]
    end repeat
  end if
end

on saveFlatList me, tMsg, tMode
  pItemList[#flats] = [:]
  if listp(tMsg) then
    if tMode = #busy then
      pFlatCache[#flats] = [:]
      repeat with f = 1 to tMsg.count()
        tFlatID = tMsg.getPropAt(f)
        pItemList[#flats][tFlatID] = tMsg[f]
        pFlatCache[#flats][tFlatID] = tMsg[f]
      end repeat
    else
      repeat with f = 1 to tMsg.count()
        tFlatID = tMsg.getPropAt(f)
        pItemList[#flats][tFlatID] = tMsg[f]
      end repeat
    end if
  end if
  return me.getInterface().saveFlatList(pItemList[#flats], tMode)
end

on saveFlatInfo me, tMsg
  if listp(tMsg) then
    tFlatID = tMsg.getPropAt(1)
    tdata = tMsg[tFlatID]
    if listp(tdata) then
      repeat with f = 1 to tdata.count()
        tProp = tdata.getPropAt(f)
        tDesc = tdata[tProp]
        if voidp(pItemList[#flats][tFlatID]) then
          pItemList[#flats][tFlatID] = [:]
        end if
        pItemList[#flats][tFlatID][tProp] = tDesc
      end repeat
    end if
  end if
  return me.getInterface().saveFlatInfo(pItemList[#flats][tFlatID])
end

on roomListTimeOutUpdate me
  return me.getInterface().roomlistupdate()
end

on noflatsforuser me
  return me.getInterface().failedFlatSearch(getText("nav_private_norooms"))
end

on noflats me
  return me.getInterface().failedFlatSearch(getText("nav_prvrooms_notfound"))
end

on getUnitUpdates me
  if not connectionExists(pConnectionId) then
    return error(me, "Connection not found:" && pConnectionId, #getUnitUpdates)
  end if
  return getConnection(pConnectionId).send(#info, "GETUNITUPDATES")
end

on searchBusyFlats me, tFromNum, tToNum, tMode
  if not voidp(pFlatCache[#flats]) and tMode <> #update then
    return me.getInterface().saveFlatList(pFlatCache[#flats], #cached)
  else
    if connectionExists(pConnectionId) then
      if not integerp(tFromNum) then
        tFromNum = 0
      end if
      if not integerp(tToNum) then
        tToNum = tFromNum + getIntVariable("navigator.private.count", 40)
      end if
      getConnection(pConnectionId).send(#info, "SBUSYF /" & tFromNum & "," & tToNum)
    end if
  end if
  return 0
end

on getOwnFlats me
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send(#info, "SUSERF /" & getObject(#session).get("user_name"))
  end if
  return 0
end

on getFavouriteFlats me
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send(#info, "GETFVRF")
  end if
  return 0
end

on addToFavouriteFlats me, tRoomId
  if connectionExists(pConnectionId) then
    if voidp(tRoomId) then
      return error(me, "Room ID expected!", #addToFavouriteFlats)
    end if
    return getConnection(pConnectionId).send(#info, "ADD_FAVORITE_ROOM" && tRoomId)
  end if
  return 0
end

on removeFavouriteFlats me, tRoomId
  if connectionExists(pConnectionId) then
    if voidp(tRoomId) then
      return error(me, "Room ID expected!", #removeFavouriteFlats)
    else
      return getConnection(pConnectionId).send(#info, "DEL_FAVORITE_ROOM" && tRoomId)
    end if
  end if
  return 0
end

on getFlatInfo me, tRoomId
  if connectionExists(pConnectionId) then
    if voidp(tRoomId) then
      return error(me, "Room ID expected!", #getFlatInfo)
    else
      return getConnection(pConnectionId).send(#info, "GETFLATINFO /" & tRoomId)
    end if
  end if
  return 0
end

on searchFlats me, tQuery
  if connectionExists(pConnectionId) then
    if voidp(tQuery) then
      return error(me, "Search query is void. cant search flats", #searchFlats)
    end if
    return getConnection(pConnectionId).send(#info, "SRCHF /" & "%" & tQuery & "%")
  end if
  return 0
end

on GetUnitUsers me, tUnitName, tSubUnitName
  if connectionExists(pConnectionId) then
    if not voidp(tSubUnitName) then
      return getConnection(pConnectionId).send(#info, "GETUNITUSERS" && "/" & tUnitName & "/" & tSubUnitName)
    else
      return getConnection(pConnectionId).send(#info, "GETUNITUSERS" && "/" & tUnitName)
    end if
  end if
  return 0
end

on deleteFlat me, tFlatID
  if connectionExists(pConnectionId) then
    return getConnection(pConnectionId).send(#info, "DELETEFLAT /" & tFlatID)
  else
    return 0
  end if
end

on sendupdateFlatInfo me, tPropList
  if tPropList.ilk <> #propList or voidp(tPropList[#id]) then
    return error(me, "Cant send updateFlatInfo", #sendupdateFlatInfo)
  end if
  tFlatMsg = EMPTY
  repeat with tProp in [#id, #name, #door, #showownername]
    tFlatMsg = tFlatMsg & tPropList[tProp] & "/"
  end repeat
  tFlatMsg = tFlatMsg.char[1..length(tFlatMsg) - 1]
  getConnection(pConnectionId).send(#info, "UPDATEFLAT /" & tFlatMsg)
  tFlatMsg = string(tPropList[#id]) & "/" & RETURN
  tFlatMsg = tFlatMsg & "description=" & tPropList[#description] & RETURN
  tFlatMsg = tFlatMsg & "password=" & tPropList[#password] & RETURN
  tFlatMsg = tFlatMsg & "allsuperuser=" & tPropList[#ableothersmovefurniture]
  getConnection(pConnectionId).send(#info, "SETFLATINFO /" & tFlatMsg)
  return 1
end

on getFlatIp me, tFlatPort
  if not voidp(pItemList[#prvunits][tFlatPort]) then
    return pItemList[#prvunits][tFlatPort][#ip]
  else
    return error(me, "Missing flat server! Port:" && tFlatPort, #getFlatIp)
  end if
end

on getRoomProperties me, tRoomId
  if integerp(value(tRoomId)) then
    if not voidp(pItemList[#flats][tRoomId]) then
      tRoomProps = pItemList[#flats][tRoomId]
      tRoomProps[#id] = tRoomId
      tRoomProps[#type] = #private
      tRoomProps[#ip] = me.getFlatIp(tRoomProps[#port])
    end if
  else
    if not voidp(pItemList[#units][tRoomId]) then
      tRoomProps = pItemList[#units][tRoomId]
      tRoomProps[#id] = tRoomId
      tRoomProps[#type] = #public
    end if
  end if
  if listp(tRoomProps) then
    return tRoomProps
  else
    return error(me, "Couldn't find room properties:" && tRoomId, #getRoomProperties)
  end if
end

on roomkioskGoingFlat me, tRoomProps
  tTemp = [:]
  tTemp[tRoomProps[#id]] = tRoomProps
  me.saveFlatList(tTemp)
  return me.getInterface().roomkioskGoingFlat(tRoomProps[#id])
end

on getFlatPassword me, tFlatID
  return me.getInterface().getFlatPassword(tFlatID)
end

on flatAccessResult me, tMsg
  case tMsg of
    "flat_letin", "flatpassword_ok":
    "incorrect flat password", "password required":
      me.getInterface().flatPasswordIncorrect()
      me.updateState("enterEntry")
  end case
end

on getUnitId me, tMsg
  repeat with f = 1 to pItemList[#units].count
    tUnitid = pItemList[#units].getPropAt(f)
    tUnitData = pItemList[#units][tUnitid]
    if tUnitData[#port] = tMsg[#port] and tUnitData[#marker] = tMsg[#marker] then
      return tUnitid
      exit repeat
    end if
  end repeat
  return 0
end

on updateState me, tstate, tProps
  case tstate of
    "reset":
      pState = tstate
      if timeoutExists(#navigator_update) then
        removeTimeout(#navigator_update)
      end if
      return 0
    "initialize":
      pState = tstate
      initThread("thread.hobba")
      me.delay(1000, #updateState, "login")
    "login":
      if getIntVariable("figurepartlist.loaded", 1) = 0 then
        return me.delay(1000, #updateState, "login")
      end if
      pState = tstate
      if not variableExists("login.mode") then
        setVariable("login.mode", #normal)
      end if
      getObject(#session).set("lastroom", "Entry")
      if not variableExists("quickLogin") then
        setVariable("quickLogin", 0)
      end if
      if getIntVariable("quickLogin", 0) and the runMode contains "Author" then
        if not voidp(getPref(getVariable("fuse.project.id", "fusepref"))) then
          tTemp = value(getPref(getVariable("fuse.project.id", "fusepref")))
          getObject(#session).set(#userName, tTemp[1])
          getObject(#session).set(#password, tTemp[2])
          return me.updateState("connection")
        end if
      end if
      initThread("thread.hobba")
      case getVariableValue("login.mode") of
        #trial:
          executeMessage(#show_registration)
        #subscribe:
          executeMessage(#show_registration)
        otherwise:
          me.getInterface().getLogin().showLogin()
      end case
    "forgottenPassWord":
      pState = tstate
      return 1
    "connection":
      pState = tstate
      tHost = getVariable("connection.info.host")
      tPort = getIntVariable("connection.info.port")
      if voidp(tHost) or voidp(tPort) then
        return error(me, "Server data not found!", #updateState)
      end if
      if not createConnection(pConnectionId, tHost, tPort) then
        return error(me, "Failed to create info connection!!!", #updateState)
      else
        return 1
      end if
    "connectionOk":
      if pState = "forgottenPassWord" then
        return 1
      end if
      if not connectionExists(pConnectionId) then
        return me.updateState("connection")
      end if
      pState = tstate
      tUserName = getObject(#session).get(#userName)
      tPassword = getObject(#session).get(#password)
      if voidp(tUserName) or voidp(tPassword) then
        return 0
      end if
      if tUserName = EMPTY or tPassword = EMPTY then
        return 0
      end if
      if not stringp(tUserName) or not stringp(tPassword) then
        return 0
      end if
      getConnection(pConnectionId).send(#info, "LOGIN" && tUserName && tPassword)
      getConnection(pConnectionId).send(#info, "UNIQUEMACHINEID" && getMachineID())
      return 1
    "loginOk":
      pState = tstate
      executeMessage(#userlogin, 1)
      if not connectionExists(pConnectionId) then
        return me.updateState("connection")
      end if
      if getIntVariable("quickLogin", 0) and the runMode contains "Author" then
        setPref(getVariable("fuse.project.id", "fusepref"), string([getObject(#session).get(#userName), getObject(#session).get(#password)]))
        me.getInterface().getLogin().hideLogin()
        me.updateState("openNavigator")
      else
        me.getInterface().getLogin().showUserFound()
        me.delay(2000, #updateState, "openNavigator")
      end if
      tConnection = getConnection(pConnectionId)
      tConnection.send(#info, "GETALLUNITS")
      tConnection.send(#info, "GETADFORME general")
      tConnection.send(#info, "MESSENGERINIT")
      me.searchBusyFlats(VOID, VOID, #update)
      return 1
    "openNavigator":
      pState = tstate
      me.showNavigator()
      createTimeout(#navigator_update, pUpdatePeriod, #roomListTimeOutUpdate, me.getID(), VOID, 0)
      return executeMessage(#navigator_activated, #navigator)
    "enterEntry":
      pState = tstate
      executeMessage(#leaveRoom)
      getObject(#session).set("lastroom", "Entry")
      return 1
    "enterRoom", "enterUnit", "enterFlat":
      pState = tstate
      me.getInterface().hideNavigator()
      if getObject(#session).get("lastroom") = "Entry" then
        if threadExists(#entry) then
          getThread(#entry).getComponent().leaveEntry()
        end if
        tRoomDataStruct = me.getRoomProperties(tProps)
        getObject(#session).set("lastroom", tRoomDataStruct)
        return me.delay(500, #updateState, tstate)
      else
        if connectionExists(pConnectionId) then
          getConnection(pConnectionId).send(#info, "GETADFORME general")
        end if
        if voidp(tProps) then
          if getObject(#session).get("lastroom").ilk = #propList then
            tProps = getObject(#session).get("lastroom").getaProp(#id)
          else
            error(me, "Target room's ID expected!", #updateState)
            return me.updateState("enterEntry")
          end if
        end if
        tRoomDataStruct = me.getRoomProperties(tProps)
        getObject(#session).set("lastroom", tRoomDataStruct)
        return executeMessage(#enterRoom, tRoomDataStruct)
      end if
    "disconnection":
      pState = tstate
      return me.getInterface().showDisconnectionDialog()
  end case
  return error(me, "Unknown state:" && tstate, #updateState)
end
