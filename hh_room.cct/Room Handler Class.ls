property pRemoteControlledUsers, pHighlightUser, pPersistentFurniData

on construct me
  pPersistentFurniData = VOID
  pRemoteControlledUsers = []
  return me.regMsgList(1)
end

on deconstruct me
  pRemoteControlledUsers = []
  return me.regMsgList(0)
end

on handle_opc_ok me, tMsg
  if me.getComponent().getRoomID() = "private" then
    me.getComponent().roomConnected(VOID, "OPC_OK")
  end if
end

on handle_clc me
  me.getComponent().roomDisconnected()
end

on handle_youaremod me, tMsg
  return 1
end

on handle_flat_letin me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tName = tConn.GetStrFrom()
  me.getInterface().showDoorBellAccepted(tName)
  if tName <> EMPTY then
    return 1
  end if
  return me.getComponent().roomConnected(VOID, "FLAT_LETIN")
end

on handle_room_ready me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tWorldType = tConn.GetStrFrom()
  tUnitId = tConn.GetIntFrom()
  me.getComponent().roomConnected(tWorldType, "ROOM_READY")
end

on handle_logout me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tuser = tConn.GetStrFrom()
  if tuser <> getObject(#session).GET("user_index") then
    me.getComponent().removeUserObject(tuser)
  end if
end

on handle_disconnect me
  me.getComponent().roomDisconnected()
end

on handle_error me, tMsg
  tConn = tMsg.connection
  tErrorCode = tConn.GetIntFrom()
  case tErrorCode of
    -13000:
      me.getInterface().stopObjectMover()
    -32000:
      getObject(#session).set("room_controller", 0)
  end case
end

on handle_doorbell_ringing me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tName = tConn.GetStrFrom()
  if tName = EMPTY then
    return me.getInterface().showDoorBellWaiting()
  else
    return me.getInterface().showDoorBellDialog(tName)
  end if
end

on handle_flatnotallowedtoenter me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tName = tConn.GetStrFrom()
  return me.getInterface().showDoorBellRejected(tName)
end

on handle_status me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tList = []
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    tuser = [:]
    tuser[#id] = tConn.GetIntFrom()
    tuser[#x] = tConn.GetIntFrom()
    tuser[#y] = tConn.GetIntFrom()
    tuser[#h] = getLocalFloat(tConn.GetStrFrom())
    tuser[#dirHead] = tConn.GetIntFrom() mod 8
    tuser[#dirBody] = tConn.GetIntFrom() mod 8
    tActionString = tConn.GetStrFrom()
    tActions = []
    tActionIndex = []
    the itemDelimiter = "/"
    repeat with j = 1 to tActionString.item.count
      if length(tActionString.item[j]) > 1 then
        tActionName = tActionString.item[j].word[1]
        tActions.add([#name: tActionName, #params: tActionString.item[j]])
        tActionIndex.add(tActionName)
      end if
    end repeat
    tuser[#actionIndex] = tActionIndex
    tuser[#actions] = tActions
    tList.add(tuser)
  end repeat
  the itemDelimiter = tDelim
  repeat with tuser in tList
    if not (pRemoteControlledUsers.getOne(tuser[#id]) > 0) then
      tUserObj = me.getComponent().getUserObject(tuser[#id])
      if tUserObj <> 0 then
        tActionIndex = tuser.getaProp(#actionIndex)
        tActions = tuser.getaProp(#actions)
        tAllowFX = call(#validateFxForActionList, [tUserObj], tActions, tActionIndex)
        if tAllowFX <> 1 then
          tActionIndex.deleteOne("fx")
        end if
        tUserObj.resetValues(tuser.getaProp(#x), tuser.getaProp(#y), tuser.getaProp(#h), tuser.getaProp(#dirHead), tuser.getaProp(#dirBody), tActionIndex)
        tPrimaryActions = ["mv", "sit", "lay"]
        tActionList = []
        tUserActions = tuser.getaProp(#actions)
        tHasPrimaryAction = 0
        repeat with i = tUserActions.count down to 1
          tAction = tUserActions[i]
          tName = tAction.getaProp(#name)
          if tPrimaryActions.findPos(tName) then
            tActionList.add(tAction)
            tUserActions.deleteAt(i)
            tHasPrimaryAction = 1
          end if
          if tName = "fx" and not tAllowFX then
            tUserActions.deleteAt(i)
          end if
        end repeat
        if not tHasPrimaryAction then
          tActionList.add([#name: "std"])
        end if
        tEffect = VOID
        repeat with tAction in tUserActions
          if tAction.getaProp(#name) = "fx" then
            tEffect = tAction.duplicate()
            next repeat
          end if
          tActionList.add(tAction)
        end repeat
        if tEffect <> VOID then
          tActionList.add(tEffect)
        end if
        repeat with tAction in tActionList
          call(symbol("action_" & tAction[#name]), [tUserObj], tAction[#params])
        end repeat
        tUserObj.Refresh(tuser[#x], tuser[#y], tuser[#h])
      end if
    end if
  end repeat
end

on handle_users me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tDelim = the itemDelimiter
  tList = []
  if not objectExists("Figure_System") then
    return error(me, "Figure system object not found!", #handle_users, #major)
  end if
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    tUserID = tConn.GetIntFrom()
    tuser = string(tUserID)
    tListItem = [:]
    tListItem[#webID] = tuser
    tListItem[#name] = tConn.GetStrFrom()
    tListItem[#custom] = tConn.GetStrFrom()
    tListItem[#figure] = tConn.GetStrFrom()
    tListItem[#id] = string(tConn.GetIntFrom())
    tListItem[#x] = tConn.GetIntFrom()
    tListItem[#y] = tConn.GetIntFrom()
    tListItem[#h] = getLocalFloat(tConn.GetStrFrom())
    tdir = tConn.GetIntFrom()
    ttype = tConn.GetIntFrom()
    tListItem[#direction] = [tdir, tdir]
    case ttype of
      1:
        tListItem[#class] = "user"
        tListItem[#sex] = tConn.GetStrFrom()
        tXP = tConn.GetIntFrom()
        if tXP <> -1 then
          tListItem[#xp] = tXP
        end if
        tListItem[#groupID] = string(tConn.GetIntFrom())
        tGroupStatus = tConn.GetIntFrom()
        tListItem[#groupstatus] = ([1: "owner", 2: "admin", 3: "member"]).getaProp(tGroupStatus)
        tPoolFigure = tConn.GetStrFrom()
        if tPoolFigure <> EMPTY then
          the itemDelimiter = "/"
          tmodel = tPoolFigure.char[1..3]
          tColor = tPoolFigure.item[2]
          the itemDelimiter = ","
          tisColorValid = 0
          if tColor.item.count = 3 then
            tColor = color(#rgb, integer(tColor.item[1]), integer(tColor.item[2]), integer(tColor.item[3]))
          else
            tColor = rgb("#EEEEEE")
          end if
          tListItem[#phfigure] = ["model": tmodel, "color": tColor]
          tListItem[#class] = "pelle"
        end if
      2:
        tListItem[#class] = "pet"
      3:
        tListItem[#class] = "bot"
    end case
    tList.add(tListItem)
  end repeat
  tFigureParser = getObject("Figure_System")
  repeat with tObject in tList
    tObject[#figure] = tFigureParser.parseFigure(tObject[#figure], tObject[#sex], tObject[#class])
  end repeat
  the itemDelimiter = tDelim
  if count(tList) = 0 then
    me.getComponent().validateUserObjects(0)
  else
    tName = getObject(#session).GET(#userName)
    repeat with tuser in tList
      if tuser[#name] = tName then
        getObject(#session).set("user_index", tuser[#id])
      end if
      me.getComponent().validateUserObjects(tuser)
      if me.getComponent().getPickedCryName() = tuser[#name] then
        me.getComponent().showCfhSenderDelayed(tuser[#id])
      end if
      if tuser[#name] = tName then
        me.getInterface().eventProcUserObj(#selection, tuser[#id], #userEnters)
        if not voidp(pHighlightUser) then
          me.getComponent().highlightUser(pHighlightUser)
          pHighlightUser = VOID
        end if
      end if
    end repeat
  end if
end

on handle_showprogram me, tMsg
  tLine = tMsg.content
  tDst = tLine.word[1]
  tCmd = tLine.word[2]
  tArg = tLine.word[3..tLine.word.count]
  tdata = [#command: "SHOWPROGRAM", #show_dest: tDst, #show_command: tCmd, #show_params: tArg]
  tObj = me.getComponent().getRoomPrg()
  if objectp(tObj) then
    call(#showprogram, [tObj], tdata)
  end if
end

on handle_no_user_for_gift me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserName = tConn.GetStrFrom()
  tAlertString = getText("no_user_for_gift")
  tAlertString = replaceChunks(tAlertString, "%user%", tUserName)
  executeMessage(#alert, [#Msg: tAlertString])
end

on handle_heightmap me, tMsg
  me.getComponent().validateHeightMap(tMsg.content)
end

on handle_floor_map me, tMsg
  me.getInterface().getGeometry().loadHeightMap(tMsg.content, 1)
end

on handle_heightmapupdate me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tMapData = tConn.GetStrFrom()
  me.getComponent().updateHeightMap(tMapData)
end

on handle_OBJECTS me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tList = []
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    tHasDimensions = tConn.GetIntFrom()
    tObj = [:]
    tObj[#id] = tConn.GetStrFrom()
    tObj[#class] = tConn.GetStrFrom()
    tObj[#x] = tConn.GetIntFrom()
    tObj[#y] = tConn.GetIntFrom()
    tObj[#h] = tConn.GetIntFrom()
    if tHasDimensions then
      tWidth = tConn.GetIntFrom()
      tHeight = tConn.GetIntFrom()
      tObj[#dimensions] = [tWidth, tHeight]
      tObj[#x] = tObj[#x] + tObj[#width] - 1
      tObj[#y] = tObj[#y] + tObj[#height] - 1
    else
      tdir = tConn.GetIntFrom() mod 8
      tObj[#direction] = [tdir, tdir, tdir]
      tObj[#dimensions] = 0
    end if
    tList.add(tObj)
  end repeat
  if count(tList) > 0 then
    repeat with tObj in tList
      me.getComponent().validatePassiveObjects(tObj)
    end repeat
  else
    me.getComponent().validatePassiveObjects(0)
  end if
end

on parseActiveObject me, tConn
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if not tConn then
    return 0
  end if
  tObj = [:]
  tObj[#id] = string(tConn.GetIntFrom())
  tClassID = tConn.GetIntFrom()
  if tClassID > -1 then
    tError = 0
    tFurniData = pPersistentFurniData.getProps("s", tClassID)
    if voidp(tFurniData) then
      error(me, "Persistent properties missing for furni classid " & tClassID, #parseActiveObject, #major)
      tError = 1
    else
      tObj[#class] = tFurniData[#class]
      tObj[#colors] = tFurniData[#partColors]
      tWidth = tFurniData[#xdim]
      tHeight = tFurniData[#ydim]
      tObj[#dimensions] = [tWidth, tHeight]
      if tObj[#colors] = EMPTY then
        tObj[#colors] = "0"
      end if
    end if
  end if
  tObj[#x] = tConn.GetIntFrom()
  tObj[#y] = tConn.GetIntFrom()
  tDirection = tConn.GetIntFrom() mod 8
  tObj[#direction] = [tDirection, tDirection, tDirection]
  tObj[#altitude] = getLocalFloat(tConn.GetStrFrom())
  tExtra = tConn.GetIntFrom()
  tStuffData = tConn.GetStrFrom()
  tExpireTime = tConn.GetIntFrom()
  if tExpireTime > -1 then
    tExpireTime = tExpireTime * 60 * 1000 + the milliSeconds
  end if
  tObj[#expire] = tExpireTime
  if tClassID < 0 then
    tObj[#class] = tConn.GetStrFrom()
    tObj[#colors] = "0"
    tObj[#dimensions] = [1, 1]
  end if
  tObj[#props] = [#runtimedata: EMPTY, #extra: tExtra, #stuffdata: tStuffData]
  if tError then
    return 0
  else
    return tObj
  end if
end

on handle_activeobjects me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tList = []
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    if tConn <> 0 then
      tObj = me.parseActiveObject(tConn)
      if listp(tObj) then
        tList.add(tObj)
      end if
    end if
  end repeat
  if count(tList) > 0 then
    repeat with tObj in tList
      me.getComponent().validateActiveObjects(tObj)
    end repeat
    executeMessage(#activeObjectsUpdated)
  else
    me.getComponent().validateActiveObjects(0)
  end if
end

on handle_activeobject_remove me, tMsg
  tConn = tMsg.connection
  tObjID = tConn.GetStrFrom()
  tExpired = tConn.GetIntFrom()
  if tExpired then
    executeMessage(#furniture_expired, tObjID)
  end if
  me.getComponent().removeActiveObject(tObjID, tExpired)
  executeMessage(#activeObjectRemoved)
  return 1
end

on handle_activeobject_add me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return 0
  end if
  me.getComponent().validateActiveObjects(tObj)
  executeMessage(#activeObjectsUpdated)
  return 1
end

on handle_activeobject_update me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return 0
  end if
  tComponent = me.getComponent()
  if tComponent.activeObjectExists(tObj[#id]) then
    tObj = getThread(#buffer).getComponent().processObject(tObj, "active")
    tActiveObj = tComponent.getActiveObject(tObj[#id])
    tActiveObj.define(tObj)
    tComponent.removeSlideObject(tObj[#id])
    call(#movingFinished, [tActiveObj])
    executeMessage(#activeObjectsUpdated)
  else
    return error(me, "Active object not found:" && tObj[#id], #handle_activeobject_update, #major)
  end if
end

on parse_itemlistitem me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return [:]
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tObj = [:]
  tObj[#id] = tConn.GetStrFrom()
  tClassID = tConn.GetIntFrom()
  tFurniData = pPersistentFurniData.getProps("i", tClassID)
  if voidp(tFurniData) then
    error(me, "Persistent properties missing for item classid " & tClassID, #handle_items, #major)
    tObj[#class] = EMPTY
  else
    tObj[#class] = tFurniData[#class]
    tObj[#owner] = EMPTY
    tLocLine = tConn.GetStrFrom()
    tObj[#type] = tConn.GetStrFrom()
    if not (tLocLine.char[1] = ":") then
      tObj[#direction] = tLocLine.word[1]
      if tObj[#direction] = "frontwall" then
        tObj[#direction] = "rightwall"
      end if
      tlocation = tLocLine.word[2..tLocLine.word.count]
      the itemDelimiter = ","
      tObj[#x] = 0
      tObj[#y] = tlocation.item[1]
      tObj[#h] = getLocalFloat(tlocation.item[2])
      tObj[#z] = integer(tlocation.item[3])
      tObj[#formatVersion] = #old
      tObj[#expire] = -1
    else
      tLocString = tLocLine
      tWallLoc = tLocString.word[1].char[4..length(tLocString.word[1])]
      the itemDelimiter = ","
      tObj[#wall_x] = integer(tWallLoc.item[1])
      tObj[#wall_y] = integer(tWallLoc.item[2])
      tLocalLoc = tLocString.word[2].char[3..length(tLocString.word[2])]
      tObj[#local_x] = integer(tLocalLoc.item[1])
      tObj[#local_y] = integer(tLocalLoc.item[2])
      tDirChar = tLocString.word[3]
      case tDirChar of
        "r":
          tObj[#direction] = "rightwall"
        "l":
          tObj[#direction] = "leftwall"
      end case
      tObj[#formatVersion] = #new
      tObj[#expire] = -1
    end if
  end if
  return tObj
end

on handle_itemlist me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    tObj = me.parse_itemlistitem(tMsg)
    me.getComponent().validateItemObjects(tObj)
  end repeat
  if tCount > 0 then
    executeMessage(#itemObjectsUpdated)
  else
    me.getComponent().validateItemObjects(0)
  end if
end

on handle_additem me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tObj = me.parse_itemlistitem(tMsg)
  if tObj.count > 0 then
    me.getComponent().validateItemObjects(tObj)
    executeMessage(#itemObjectsUpdated)
  else
    me.getComponent().validateItemObjects(0)
  end if
end

on handle_removeitem me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  me.getComponent().removeItemObject(tConn.GetStrFrom())
  executeMessage(#itemObjectRemoved)
  me.getInterface().stopObjectMover()
end

on handle_updateitem me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tObj = me.parse_itemlistitem(tMsg)
  if tObj.count > 0 then
    tItem = me.getComponent().getItemObject(tObj[#id])
    if objectp(tItem) then
      tItem.setState(the last word in tObj[#type])
    end if
  end if
end

on handle_stuffdataupdate me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tTarget = tConn.GetStrFrom()
  tValue = tConn.GetStrFrom()
  if me.getComponent().activeObjectExists(tTarget) then
    call(#updateStuffdata, [me.getComponent().getActiveObject(tTarget)], tValue)
  else
    return error(me, "Active object not found:" && tTarget, #handle_stuffdataupdate, #major)
  end if
end

on handle_presentopen me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  ttype = tConn.GetStrFrom()
  tClassID = tConn.GetIntFrom()
  tCode = tConn.GetStrFrom()
  tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
  if voidp(tFurniProps) then
    error(me, "Persistent properties missing for item classid " & tClassID, #handle_presentopen, #major)
    tFurniProps = [#class: EMPTY, #localizedName: EMPTY, #localizedDesc: EMPTY, #partColors: EMPTY]
  end if
  tClass = tFurniProps[#class]
  tColor = tFurniProps[#partColors]
  tName = tFurniProps[#localizedName]
  tCard = "PackageCardObj"
  if objectExists(tCard) then
    getObject(tCard).showContent([#type: tClass, #code: tCode, #color: tColor, #name: tName])
  else
    error(me, "Package card obj not found!", #handle_presentopen, #major)
  end if
end

on handle_flatproperty me, tMsg
  tKey = tMsg.connection.GetStrFrom()
  tVal = tMsg.connection.GetStrFrom()
  me.getComponent().setRoomProperty(tKey, tVal)
end

on handle_room_rights me, tMsg
  case tMsg.subject of
    42:
      getObject(#session).set("room_controller", 1)
    43:
      getObject(#session).set("room_controller", 0)
    47:
      getObject(#session).set("room_owner", 1)
  end case
end

on parse_stripinfoitem me, tConn
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tObj = [:]
  tObj[#stripId] = string(tConn.GetIntFrom())
  tObj[#objectPos] = tConn.GetIntFrom()
  tObj[#striptype] = tConn.GetStrFrom()
  tObj[#id] = string(tConn.GetIntFrom())
  tClassID = tConn.GetIntFrom()
  tObj[#category] = tConn.GetIntFrom()
  case tObj[#striptype] of
    "S":
      tFurniProps = pPersistentFurniData.getProps("s", tClassID)
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for furni classid " & tClassID, #handle_stripinfo, #major)
        tFurniProps = [#class: EMPTY, #localizedName: EMPTY, #localizedDesc: EMPTY, #partColors: EMPTY]
      end if
      tObj[#class] = tFurniProps[#class]
      tObj[#name] = tFurniProps[#localizedName]
      tObj[#custom] = tFurniProps[#localizedDesc]
      tObj[#dimensions] = [tFurniProps[#xdim], tFurniProps[#ydim]]
      tObj[#colors] = tFurniProps[#partColors]
      tObj[#striptype] = "active"
      tObj[#stuffdata] = tConn.GetStrFrom()
      tObj[#isRecyclable] = tConn.GetIntFrom()
      tObj[#isTradeable] = tConn.GetIntFrom()
      tObj[#isGroupable] = tConn.GetIntFrom()
      tExp = tConn.GetIntFrom()
      if tExp <> -1 then
        tObj[#expire] = tExp
      end if
      tSlotID = tConn.GetStrFrom()
      if tSlotID <> EMPTY then
        tObj[#slotID] = tSlotID
      end if
      tSongID = tConn.GetIntFrom()
      if tSongID <> -1 then
        tObj[#songID] = tSongID
      end if
      the itemDelimiter = ","
      if tObj[#colors].char[1] = "#" then
        if tObj[#colors].item.count > 1 then
          tObj[#stripColor] = rgb(tObj[#colors].item[tObj[#colors].item.count])
        else
          tObj[#stripColor] = rgb(tObj[#colors])
        end if
      else
        tObj[#stripColor] = 0
      end if
    "I":
      tFurniProps = pPersistentFurniData.getProps("i", tClassID)
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for item classid " & tClassID, #handle_items, #major)
        tFurniProps = [#class: EMPTY, #localizedName: EMPTY, #localizedDesc: EMPTY, #colors: EMPTY]
      end if
      tObj[#class] = tFurniProps[#class]
      tObj[#striptype] = "item"
      tObj[#props] = tConn.GetStrFrom()
      tObj[#isRecyclable] = tConn.GetIntFrom()
      tObj[#isTradeable] = tConn.GetIntFrom()
      tObj[#isGroupable] = tConn.GetIntFrom()
      tExp = tConn.GetIntFrom()
      if tExp <> -1 then
        tObj[#expire] = tExp
      end if
      case tObj[#class] of
        "poster":
          tObj[#name] = getText("poster_" & tObj[#props] & "_name", "poster_" & tObj[#props] & "_name")
        otherwise:
          tObj[#name] = tFurniProps[#localizedName]
      end case
  end case
  return tObj
end

on handle_stripinfo me, tMsg, tItemDeLim
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if tMsg.subject = 98 then
    tCount = 1
  else
    tCount = tConn.GetIntFrom()
  end if
  tStripMax = 0
  tTotalItemCount = 0
  tProps = [#objects: [], #count: tCount]
  repeat with i = 1 to tCount
    tObj = me.parse_stripinfoitem(tConn)
    tObjectPos = tObj[#objectPos]
    tObj.deleteProp(#objectPos)
    tProps[#objects].add(tObj)
    if tObjectPos > tStripMax then
      tStripMax = tObjectPos
    end if
  end repeat
  tTotalItemCount = tConn.GetIntFrom()
  tInventory = me.getInterface().getContainer()
  tInventory.setHandButton("next", tTotalItemCount - 1 > integer(tStripMax))
  tInventory.setHandButton("prev", integer(tStripMax) > 8)
  case tMsg.subject of
    140:
      tInventory.updateStripItems(tProps[#objects])
      tInventory.setStripItemCount(tProps[#count])
      tInventory.open(1)
      tInventory.Refresh()
    98:
      tConn.send("GETSTRIP", [#integer: 3])
  end case
end

on handle_stripupdated me, tMsg
  tMsg.connection.send("GETSTRIP", [#integer: 3])
end

on handle_removestripitem me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  me.getInterface().getContainer().removeStripItem(string(tConn.GetIntFrom()))
  me.getInterface().getContainer().Refresh()
end

on handle_youarenotallowed me
  executeMessage(#alert, [#Msg: "trade_youarenotallowed", #id: "youarenotallowed"])
end

on handle_othernotallowed me
  executeMessage(#alert, [#Msg: "trade_othernotallowed", #id: "othernotallowed"])
end

on handle_idata me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  tID = integer(tConn.GetStrFrom())
  tdata = tConn.GetStrFrom()
  ttype = tdata.line[1].item[1]
  tText = ttype & RETURN & tdata.line[2..tdata.line.count]
  the itemDelimiter = tDelim
  executeMessage(symbol("itemdata_received" & tID), [#id: tID, #text: tText, #type: ttype])
end

on handle_trade_items me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tMessage = [:]
  repeat with i = 1 to 2
    tUserID = tConn.GetIntFrom()
    tFurniList = []
    tFurniCount = tConn.GetIntFrom()
    repeat with j = 1 to tFurniCount
      tFurniInfo = [:]
      tFurniInfo.setaProp(#stripId, tConn.GetIntFrom())
      tFurniInfo.setaProp(#striptype, tConn.GetStrFrom())
      tFurniInfo.setaProp(#id, tConn.GetIntFrom())
      tFurniInfo.setaProp(#classID, tConn.GetIntFrom())
      tFurniInfo.setaProp(#category, tConn.GetIntFrom())
      tFurniInfo.setaProp(#isGroupable, tConn.GetIntFrom())
      tFurniInfo.setaProp(#data, tConn.GetStrFrom())
      tFurniInfo.setaProp(#day, tConn.GetIntFrom())
      tFurniInfo.setaProp(#month, tConn.GetIntFrom())
      tFurniInfo.setaProp(#year, tConn.GetIntFrom())
      if tFurniInfo[#striptype] = "s" then
        tFurniInfo.setaProp(#songID, tConn.GetIntFrom())
      end if
      tFurniProps = pPersistentFurniData.getProps(tFurniInfo[#striptype], tFurniInfo[#classID])
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for item classid " & tFurniInfo[#classID], #handle_items, #major)
        tFurniProps = [#class: EMPTY, #localizedName: EMPTY, #localizedDesc: EMPTY, #colors: EMPTY]
      end if
      tFurniInfo.setaProp(#class, tFurniProps[#class])
      if tFurniInfo[#class] = "poster" then
        tFurniInfo.setaProp(#name, getText("poster_" & tFurniInfo[#data] & "_name"))
      else
        tFurniInfo.setaProp(#name, tFurniProps[#localizedName])
      end if
      tFurniInfo.setaProp(#colors, tFurniProps[#partColors])
      tFurniInfo.setaProp(#dimensions, [tFurniProps[#xdim], tFurniProps[#ydim]])
      tFurniList.add(tFurniInfo)
    end repeat
    tMessage.setaProp(tUserID, tFurniList)
  end repeat
  tTrader = me.getInterface().getSafeTrader()
  if not tTrader then
    return 0
  end if
  return tTrader.Refresh(tMessage)
end

on handle_trade_close me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  if tUserID <> getObject(#session).GET("user_user_id") then
    executeMessage(#alert, [#id: #trade_cancelled, #Msg: getText("trading_closed")])
  end if
  tTrader = me.getInterface().getSafeTrader()
  if not tTrader then
    return 0
  end if
  tTrader.close()
  tHand = me.getInterface().getContainer()
  if not tHand then
    return 0
  end if
  if tHand.isOpen() then
    tConn.send("GETSTRIP", [#integer: 4])
  end if
end

on handle_trade_confirm me, tMsg
  tTrader = me.getInterface().getSafeTrader()
  if not tTrader then
    return 0
  end if
  tTrader.showConfirmationView()
end

on handle_trade_accept me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tStatus = tConn.GetIntFrom() > 0
  tTrader = me.getInterface().getSafeTrader()
  if not tTrader then
    return 0
  end if
  tTrader.accept(tUserID, tStatus)
end

on handle_trade_open me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tTrader = me.getInterface().getSafeTrader()
  if not tTrader then
    return 0
  end if
  tTrader.startTrade(tConn.GetIntFrom(), tConn.GetIntFrom(), tConn.GetIntFrom(), tConn.GetIntFrom())
end

on handle_trade_already_open me
  executeMessage(#alert, [#id: #trade_already_open, #Msg: getText("trading_already_open")])
end

on handle_trade_completed me, tMsg
  tTrader = me.getInterface().getSafeTrader()
  if not tTrader then
    return 0
  end if
  tTrader.complete()
end

on handle_doordeleted me, tMsg
end

on handle_dice_value me, tMsg
  tConn = tMsg.connection
  tID = string(tConn.GetIntFrom())
  tValue = tConn.GetIntFrom()
  if me.getComponent().activeObjectExists(tID) then
    call(#diceThrown, [me.getComponent().getActiveObject(tID)], tValue)
  end if
end

on handle_roomad me, tMsg
  tConn = tMsg.connection
  tSourceURL = tConn.GetStrFrom()
  if tSourceURL.length > 1 then
    tTargetURL = tConn.GetStrFrom()
    tLayoutID = me.getInterface().getRoomVisualizer().pLayout
    me.getComponent().getAd().Init(tSourceURL, tTargetURL, tLayoutID)
  else
    me.getComponent().getAd().Init(0)
  end if
end

on handle_petstat me, tMsg
  tPetObj = me.getComponent().getUserObject(tMsg.connection.GetIntFrom())
  if tPetObj = 0 then
    return error(me, "Pet object not found!", #handle_petstat, #major)
  end if
  tName = tPetObj.getName()
  tAge = tMsg.connection.GetIntFrom()
  tHungry = getText("pet_hung_" & tMsg.connection.GetIntFrom(), "???")
  tThirsty = getText("pet_thir_" & tMsg.connection.GetIntFrom(), "???")
  tHappiness = getText("pet_mood_" & tMsg.connection.GetIntFrom(), "???")
  tNature01 = getText("pet_enrg_" & tMsg.connection.GetIntFrom(), "???")
  tNature02 = getText("pet_frnd_" & tMsg.connection.GetIntFrom(), "???")
  if createWindow("pet_status_dialog") then
    tWndObj = getWindow("pet_status_dialog")
    tWndObj.moveTo(8, 8)
    tWndObj.setProperty(#title, tName)
    if not tWndObj.merge("habbo_full.window") then
      return tWndObj.close()
    end if
    if not tWndObj.merge("petstatus.window") then
      return tWndObj.close()
    end if
    tWndObj.getElement("age").setText(tAge)
    tWndObj.getElement("hungry").setText(tHungry)
    tWndObj.getElement("thirsty").setText(tThirsty)
    tWndObj.getElement("happiness").setText(tHappiness)
    tWndObj.getElement("nature").setText(tNature01 & "," && tNature02)
    tWndObj.getElement("picture").feedImage(tPetObj.getPicture())
    registerMessage(#leaveRoom, tWndObj.getID(), #close)
    registerMessage(#changeRoom, tWndObj.getID(), #close)
  end if
end

on handle_userbadge me, tMsg
  if voidp(tMsg.connection) then
    return 0
  end if
  tUserID = tMsg.connection.GetStrFrom()
  tChosenBadgeCount = tMsg.connection.GetIntFrom()
  tBadges = [:]
  repeat with i = 1 to tChosenBadgeCount
    tBadgeIndex = tMsg.connection.GetIntFrom()
    tBadgeID = tMsg.connection.GetStrFrom()
    tBadges.setaProp(tBadgeIndex, tBadgeID)
  end repeat
  tUserObj = me.getComponent().getUserObjectByWebID(tUserID)
  if not objectp(tUserObj) then
    return 0
  end if
  tUserObj.pBadges = tBadges
  me.getInterface().unignoreAdmin(tUserID, tBadges)
  executeMessage(#updateInfoStandBadge, tBadges, tUserID)
end

on handle_slideobjectbundle me, tMsg
  tConn = tMsg.getaProp(#connection)
  tComponent = me.getComponent()
  tTimeNow = the milliSeconds
  tObjList = []
  tContainsObjects = 0
  tFromX = tConn.GetIntFrom()
  tFromY = tConn.GetIntFrom()
  tToX = tConn.GetIntFrom()
  tToY = tConn.GetIntFrom()
  tStuffCount = tConn.GetIntFrom()
  repeat with tCount = 1 to tStuffCount
    tObj = []
    tItemID = tConn.GetIntFrom()
    tItemFromH = getLocalFloat(tConn.GetStrFrom())
    tItemToH = getLocalFloat(tConn.GetStrFrom())
    tFrom = [tFromX, tFromY, tItemFromH]
    tTo = [tToX, tToY, tItemToH]
    tObj = [tItemID, tFrom, tTo]
    tObjList.add(tObj)
    tContainsObjects = 1
  end repeat
  tTileID = tConn.GetIntFrom()
  tTileObj = tComponent.getActiveObject(tTileID)
  if tTileObj <> 0 then
    if tTileObj.handler(#setAnimation) then
      call(#setAnimation, tTileObj, 1)
    end if
  end if
  tMoveType = tConn.GetIntFrom()
  case tMoveType of
    0:
      tHasCharacter = 0
    1:
      tMoveType = "mv"
      tHasCharacter = 1
    2:
      tMoveType = "sld"
      tHasCharacter = 1
  end case
  return error(me, "Incompatible character movetype", #handle_slideobjectbundle, #minor)
  if tHasCharacter then
    tCharID = tConn.GetIntFrom()
    tFromH = getLocalFloat(tConn.GetStrFrom())
    tToH = getLocalFloat(tConn.GetStrFrom())
    tUserObj = me.getComponent().getUserObject(tCharID)
    if tUserObj <> 0 then
      tCommandStr = tMoveType && tToX & "," & tToY & "," & tToH && tContainsObjects.integer && tTimeNow
      call(symbol("action_" & tMoveType), [tUserObj], tCommandStr)
    end if
  end if
  repeat with tObj in tObjList
    tComponent.addSlideObject(tObj[1], tObj[2], tObj[3], tTimeNow, tHasCharacter)
  end repeat
end

on handle_interstitialdata me, tMsg
  tConn = tMsg.connection
  tSourceURL = tConn.GetStrFrom()
  if tSourceURL.length > 0 then
    tTargetURL = tConn.GetStrFrom()
    me.getComponent().getInterstitial().Init(tSourceURL, tTargetURL)
  else
    me.getComponent().getInterstitial().Init(0)
  end if
end

on handle_roomqueuedata me, tMsg
  tConn = tMsg.getaProp(#connection)
  tSetCount = tConn.GetIntFrom()
  tQueueCollection = []
  repeat with i = 1 to tSetCount
    tQueueSetName = tConn.GetStrFrom()
    tQueueTarget = tConn.GetIntFrom()
    tNumberOfQueues = tConn.GetIntFrom()
    tQueueData = [:]
    tQueueSet = [:]
    repeat with t = 1 to tNumberOfQueues
      tQueueID = tConn.GetStrFrom()
      tQueueLength = tConn.GetIntFrom()
      tQueueData[tQueueID] = tQueueLength
    end repeat
    tQueueSet["name"] = tQueueSetName
    tQueueSet["target"] = tQueueTarget
    tQueueSet["data"] = tQueueData
    tQueueCollection[i] = tQueueSet
  end repeat
  me.getInterface().updateQueueWindow(tQueueCollection)
end

on handle_youarespectator me
  return me.getComponent().setSpectatorMode(1)
end

on handle_removespecs me
  me.getInterface().showRemoveSpecsNotice()
end

on handle_figure_change me, tMsg
  tConn = tMsg.connection
  tUserID = tConn.GetIntFrom()
  tUserFigure = tConn.GetStrFrom()
  tUserSex = tConn.GetStrFrom()
  tUserCustomInfo = tConn.GetStrFrom()
  me.getComponent().updateCharacterFigure(tUserID, tUserFigure, tUserSex, tUserCustomInfo)
end

on handle_spectator_amount me, tMsg
  tConn = tMsg.connection
  tSpecCount = tConn.GetIntFrom()
  tSpecMax = tConn.GetIntFrom()
  me.getComponent().updateSpectatorCount(tSpecCount, tSpecMax)
end

on handle_group_badges me, tMsg
  tConn = tMsg.connection
  tNumberOfGroups = tConn.GetIntFrom()
  tGroupData = []
  repeat with tNo = 1 to tNumberOfGroups
    tGroup = [:]
    tGroup[#id] = tConn.GetIntFrom()
    tGroup[#logo] = tConn.GetStrFrom()
    tGroupData.add(tGroup)
  end repeat
  me.getComponent().getGroupInfoObject().updateGroupInformation(tGroupData)
end

on handle_group_details me, tMsg
  tConn = tMsg.connection
  tGroupData = []
  tGroup = [:]
  tGroup[#id] = tConn.GetIntFrom()
  if tGroup[#id] = -1 then
    return 0
  end if
  tGroup[#name] = tConn.GetStrFrom()
  tGroup[#desc] = tConn.GetStrFrom()
  tGroup[#roomid] = tConn.GetIntFrom()
  tGroup[#roomname] = tConn.GetStrFrom()
  tGroupData.add(tGroup)
  me.getComponent().getGroupInfoObject().updateGroupInformation(tGroupData)
  executeMessage(#groupInfoRetrieved, tGroup[#id])
end

on handle_group_membership_update me, tMsg
  tConn = tMsg.connection
  tUserIndex = tConn.GetIntFrom()
  tGroupId = tConn.GetIntFrom()
  tStatus = tConn.GetIntFrom()
  tuser = me.getComponent().getUserObject(tUserIndex)
  if not voidp(tuser) then
    if tuser <> 0 then
      tuser.setProperty(#groupID, tGroupId)
      tuser.setProperty(#groupstatus, tStatus)
    end if
  end if
end

on handle_room_rating me, tMsg
  tConn = tMsg.connection
  tRoomRating = tConn.GetIntFrom()
  tRoomRatingPercent = tConn.GetIntFrom()
  me.getComponent().setRoomRating(tRoomRating, tRoomRatingPercent)
  executeMessage(#roomRatingChanged)
end

on handle_user_tag_list me, tMsg
  tConn = tMsg.connection
  tUserID = tConn.GetIntFrom()
  tNumOfTags = tConn.GetIntFrom()
  tTagList = []
  repeat with tTagNum = 1 to tNumOfTags
    tTag = tConn.GetStrFrom()
    tTagList.add(tTag)
  end repeat
  executeMessage(#updateUserTags, tUserID, tTagList)
end

on handle_user_typing_status me, tMsg
  tConn = tMsg.connection
  tUserID = tConn.GetIntFrom()
  tstate = tConn.GetIntFrom()
  tUserID = string(tUserID)
  me.getComponent().setUserTypingStatus(tUserID, tstate)
end

on handle_highlight_user me, tMsg
  tConn = tMsg.getaProp(#connection)
  tUserID = string(tConn.GetIntFrom())
  pHighlightUser = tUserID
end

on handle_roomevent_permission me, tMsg
  tConn = tMsg.getaProp(#connection)
  tCanCreate = tConn.GetIntFrom()
  if tCanCreate then
    executeMessage(#allowRoomeventCreation)
  end if
end

on handle_roomevent_types me, tMsg
  tConn = tMsg.getaProp(#connection)
  tTypeCount = tConn.GetIntFrom()
  me.getComponent().setRoomEventTypeCount(tTypeCount)
end

on handle_roomevent_list me, tMsg
  tConn = tMsg.getaProp(#connection)
  tTypeID = tConn.GetIntFrom()
  tEventCount = tConn.GetIntFrom()
  tEvents = []
  repeat with tEventNum = 1 to tEventCount
    tEvent = [:]
    tEvent.setaProp(#flatId, tConn.GetStrFrom())
    tEvent.setaProp(#hostName, tConn.GetStrFrom())
    tEvent.setaProp(#name, tConn.GetStrFrom())
    tEvent.setaProp(#desc, tConn.GetStrFrom())
    tEvent.setaProp(#time, tConn.GetStrFrom())
    tEvents.add(tEvent)
  end repeat
  me.getComponent().setRoomEventList(tTypeID, tEvents)
end

on handle_roomevent_info me, tMsg
  tConn = tMsg.getaProp(#connection)
  tEventInfo = [:]
  tHostID = tConn.GetStrFrom()
  tEventInfo.setaProp(#hostID, tHostID)
  if tHostID > 0 then
    tEventInfo.setaProp(#hostName, tConn.GetStrFrom())
    tEventInfo.setaProp(#flatId, tConn.GetStrFrom())
    tEventInfo.setaProp(#typeID, tConn.GetIntFrom())
    tEventInfo.setaProp(#name, tConn.GetStrFrom())
    tEventInfo.setaProp(#desc, tConn.GetStrFrom())
    tEventInfo.setaProp(#time, tConn.GetStrFrom())
  end if
  me.getComponent().setRoomEvent(tEventInfo)
end

on handle_ignore_user_result me, tMsg
  tConn = tMsg.getaProp(#connection)
  tResult = tConn.GetIntFrom()
  return executeMessage(#ignore_user_result, tResult)
end

on handle_ignore_list me, tMsg
  tConn = tMsg.getaProp(#connection)
  tCount = tConn.GetIntFrom()
  tList = []
  repeat with i = 1 to tCount
    tList.append(tConn.GetStrFrom())
  end repeat
  return executeMessage(#save_ignore_list, tList)
end

on handle_user_dance me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tDanceStyle = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    call(symbol("action_dance"), [tUserObj], "dance " & tDanceStyle)
  end if
end

on handle_user_wave me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    call(symbol("action_wave"), [tUserObj], "wave")
  end if
end

on handle_user_carry_object me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tItemType = tConn.GetIntFrom()
  tItemName = tConn.GetStrFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    if tUserObj.validateCarryForCurrentState() then
      tUserObj.handle_user_carry_object(tItemType, tItemName)
    end if
  end if
end

on handle_user_joining_game me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tGameId = tConn.GetIntFrom()
  tGameType = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    call(symbol("action_joingame"), [tUserObj], "joingame" && tGameId && tGameType)
  end if
end

on handle_user_not_joining_game me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    call(symbol("action_joingame"), [tUserObj], "joingame")
  end if
end

on handle_user_avatar_effect me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tFxType = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    if tUserObj.validateFxForActionList([[#params: "fx " & tFxType, #name: "fx"]], ["fx"]) then
      call(#action_fx, [tUserObj], "fx " & tFxType)
    else
      call(#persist_fx, [tUserObj], tFxType)
    end if
  end if
end

on handle_user_sleep me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  tSleep = tConn.GetBoolFrom()
  if tUserObj <> 0 then
    call(symbol("action_sleep"), [tUserObj], tSleep)
  end if
end

on handle_user_use_object me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tUserID = tConn.GetIntFrom()
  tItemType = tConn.GetIntFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if tUserObj <> 0 then
    tUserObj.handle_user_use_object(tItemType)
  end if
end

on handle_judge_gui_status me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tstate = tConn.GetIntFrom()
  if tstate = 2 then
    tPerformerID = tConn.GetIntFrom()
  end if
  me.getInterface().setJudgeToolState(tstate, tPerformerID)
end

on handle_open_performer_gui me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tNumOfSongs = tConn.GetIntFrom()
  tSongList = [:]
  repeat with i = 1 to tNumOfSongs
    tSongList.setaProp(tConn.GetIntFrom(), tConn.GetStrFrom())
  end repeat
  me.getInterface().openSongSelector(tSongList)
end

on handle_close_performer_gui me, tMsg
  return executeMessage(#close_performer_song_selector)
end

on handle_start_playing_song me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  executeMessage(#listen_song, tConn.GetIntFrom())
end

on handle_stop_playing_song me, tMsg
  executeMessage(#do_not_listen_song)
end

on handle_item_not_tradeable me, tMsg
  executeMessage(#alert, [#Msg: "room_cant_trade"])
end

on handle_cannot_place_stuff_from_strip me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tError = tConn.GetIntFrom()
  case tError of
    1, 11:
      executeMessage(#alert, [#Msg: "room_cant_set_item"])
    12:
      executeMessage(#alert, [#Msg: "wallitem_post.it.limit"])
    20:
      executeMessage(#alert, [#Msg: "room_alert_furni_limit", #id: "roomfullfurni", #modal: 1])
    21:
      executeMessage(#alert, [#Msg: "room_max_pet_limit"])
    22:
      executeMessage(#alert, [#Msg: "queue_tile_limit"])
    23:
      executeMessage(#alert, [#Msg: "room_sound_furni_limit"])
  end case
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(-1, #handle_disconnect)
  tMsgs.setaProp(18, #handle_clc)
  tMsgs.setaProp(19, #handle_opc_ok)
  tMsgs.setaProp(28, #handle_users)
  tMsgs.setaProp(29, #handle_logout)
  tMsgs.setaProp(30, #handle_OBJECTS)
  tMsgs.setaProp(31, #handle_heightmap)
  tMsgs.setaProp(32, #handle_activeobjects)
  tMsgs.setaProp(33, #handle_error)
  tMsgs.setaProp(34, #handle_status)
  tMsgs.setaProp(41, #handle_flat_letin)
  tMsgs.setaProp(42, #handle_room_rights)
  tMsgs.setaProp(43, #handle_room_rights)
  tMsgs.setaProp(45, #handle_itemlist)
  tMsgs.setaProp(46, #handle_flatproperty)
  tMsgs.setaProp(47, #handle_room_rights)
  tMsgs.setaProp(48, #handle_idata)
  tMsgs.setaProp(63, #handle_doordeleted)
  tMsgs.setaProp(64, #handle_doordeleted)
  tMsgs.setaProp(69, #handle_room_ready)
  tMsgs.setaProp(70, #handle_youaremod)
  tMsgs.setaProp(71, #handle_showprogram)
  tMsgs.setaProp(76, #handle_no_user_for_gift)
  tMsgs.setaProp(83, #handle_additem)
  tMsgs.setaProp(84, #handle_removeitem)
  tMsgs.setaProp(85, #handle_updateitem)
  tMsgs.setaProp(88, #handle_stuffdataupdate)
  tMsgs.setaProp(90, #handle_dice_value)
  tMsgs.setaProp(91, #handle_doorbell_ringing)
  tMsgs.setaProp(93, #handle_activeobject_add)
  tMsgs.setaProp(94, #handle_activeobject_remove)
  tMsgs.setaProp(95, #handle_activeobject_update)
  tMsgs.setaProp(98, #handle_stripinfo)
  tMsgs.setaProp(99, #handle_removestripitem)
  tMsgs.setaProp(101, #handle_stripupdated)
  tMsgs.setaProp(102, #handle_youarenotallowed)
  tMsgs.setaProp(103, #handle_othernotallowed)
  tMsgs.setaProp(104, #handle_trade_open)
  tMsgs.setaProp(105, #handle_trade_already_open)
  tMsgs.setaProp(108, #handle_trade_items)
  tMsgs.setaProp(109, #handle_trade_accept)
  tMsgs.setaProp(110, #handle_trade_close)
  tMsgs.setaProp(111, #handle_trade_confirm)
  tMsgs.setaProp(112, #handle_trade_completed)
  tMsgs.setaProp(129, #handle_presentopen)
  tMsgs.setaProp(131, #handle_flatnotallowedtoenter)
  tMsgs.setaProp(140, #handle_stripinfo)
  tMsgs.setaProp(208, #handle_roomad)
  tMsgs.setaProp(210, #handle_petstat)
  tMsgs.setaProp(219, #handle_heightmapupdate)
  tMsgs.setaProp(228, #handle_userbadge)
  tMsgs.setaProp(230, #handle_slideobjectbundle)
  tMsgs.setaProp(258, #handle_interstitialdata)
  tMsgs.setaProp(259, #handle_roomqueuedata)
  tMsgs.setaProp(254, #handle_youarespectator)
  tMsgs.setaProp(283, #handle_removespecs)
  tMsgs.setaProp(266, #handle_figure_change)
  tMsgs.setaProp(298, #handle_spectator_amount)
  tMsgs.setaProp(309, #handle_group_badges)
  tMsgs.setaProp(310, #handle_group_membership_update)
  tMsgs.setaProp(311, #handle_group_details)
  tMsgs.setaProp(345, #handle_room_rating)
  tMsgs.setaProp(350, #handle_user_tag_list)
  tMsgs.setaProp(361, #handle_user_typing_status)
  tMsgs.setaProp(362, #handle_highlight_user)
  tMsgs.setaProp(367, #handle_roomevent_permission)
  tMsgs.setaProp(368, #handle_roomevent_types)
  tMsgs.setaProp(369, #handle_roomevent_list)
  tMsgs.setaProp(370, #handle_roomevent_info)
  tMsgs.setaProp(419, #handle_ignore_user_result)
  tMsgs.setaProp(420, #handle_ignore_list)
  tMsgs.setaProp(470, #handle_floor_map)
  tMsgs.setaProp(480, #handle_user_dance)
  tMsgs.setaProp(481, #handle_user_wave)
  tMsgs.setaProp(482, #handle_user_carry_object)
  tMsgs.setaProp(483, #handle_user_joining_game)
  tMsgs.setaProp(484, #handle_user_not_joining_game)
  tMsgs.setaProp(485, #handle_user_avatar_effect)
  tMsgs.setaProp(486, #handle_user_sleep)
  tMsgs.setaProp(488, #handle_user_use_object)
  tMsgs.setaProp(490, #handle_judge_gui_status)
  tMsgs.setaProp(491, #handle_open_performer_gui)
  tMsgs.setaProp(492, #handle_close_performer_gui)
  tMsgs.setaProp(493, #handle_start_playing_song)
  tMsgs.setaProp(494, #handle_stop_playing_song)
  tMsgs.setaProp(515, #handle_item_not_tradeable)
  tMsgs.setaProp(516, #handle_cannot_place_stuff_from_strip)
  tCmds = [:]
  tCmds.setaProp("ROOM_DIRECTORY", 2)
  tCmds.setaProp("GETDOORFLAT", 28)
  tCmds.setaProp("CHAT", 52)
  tCmds.setaProp("SHOUT", 55)
  tCmds.setaProp("WHISPER", 56)
  tCmds.setaProp("QUIT", 53)
  tCmds.setaProp("GOVIADOOR", 54)
  tCmds.setaProp("TRYFLAT", 57)
  tCmds.setaProp("GOTOFLAT", 59)
  tCmds.setaProp("G_HMAP", 60)
  tCmds.setaProp("G_USRS", 61)
  tCmds.setaProp("G_OBJS", 62)
  tCmds.setaProp("G_ITEMS", 63)
  tCmds.setaProp("G_STAT", 64)
  tCmds.setaProp("GETSTRIP", 65)
  tCmds.setaProp("FLATPROPBYITEM", 66)
  tCmds.setaProp("ADDSTRIPITEM", 67)
  tCmds.setaProp("TRADE_UNACCEPT", 68)
  tCmds.setaProp("TRADE_ACCEPT", 69)
  tCmds.setaProp("TRADE_CLOSE", 70)
  tCmds.setaProp("TRADE_OPEN", 71)
  tCmds.setaProp("TRADE_ADDITEM", 72)
  tCmds.setaProp("MOVESTUFF", 73)
  tCmds.setaProp("SETSTUFFDATA", 74)
  tCmds.setaProp("MOVE", 75)
  tCmds.setaProp("THROW_DICE", 76)
  tCmds.setaProp("DICE_OFF", 77)
  tCmds.setaProp("PRESENTOPEN", 78)
  tCmds.setaProp("LOOKTO", 79)
  tCmds.setaProp("CARRYOBJECT", 80)
  tCmds.setaProp("INTODOOR", 81)
  tCmds.setaProp("DOORGOIN", 82)
  tCmds.setaProp("G_IDATA", 83)
  tCmds.setaProp("SETITEMDATA", 84)
  tCmds.setaProp("REMOVEITEM", 85)
  tCmds.setaProp("USEOBJECT", 89)
  tCmds.setaProp("PLACESTUFF", 90)
  tCmds.setaProp("DANCE", 93)
  tCmds.setaProp("WAVE", 94)
  tCmds.setaProp("KICKUSER", 95)
  tCmds.setaProp("ASSIGNRIGHTS", 96)
  tCmds.setaProp("REMOVERIGHTS", 97)
  tCmds.setaProp("LETUSERIN", 98)
  tCmds.setaProp("REMOVESTUFF", 99)
  tCmds.setaProp("GOAWAY", 115)
  tCmds.setaProp("GETROOMAD", 126)
  tCmds.setaProp("GETPETSTAT", 128)
  tCmds.setaProp("SETBADGE", 158)
  tCmds.setaProp("GETINTERST", 182)
  tCmds.setaProp("CONVERT_FURNI_TO_CREDITS", 183)
  tCmds.setaProp("ROOM_QUEUE_CHANGE", 211)
  tCmds.setaProp("SETITEMSTATE", 214)
  tCmds.setaProp("GET_SPECTATOR_AMOUNT", 216)
  tCmds.setaProp("GET_GROUP_BADGES", 230)
  tCmds.setaProp("GET_GROUP_DETAILS", 231)
  tCmds.setaProp("SPIN_WHEEL_OF_FORTUNE", 247)
  tCmds.setaProp("RATEFLAT", 261)
  tCmds.setaProp("GET_USER_TAGS", 263)
  tCmds.setaProp("SET_RANDOM_STATE", 314)
  tCmds.setaProp("USER_START_TYPING", 317)
  tCmds.setaProp("USER_CANCEL_TYPING", 318)
  tCmds.setaProp("IGNOREUSER", 319)
  tCmds.setaProp("BANUSER", 320)
  tCmds.setaProp("GET_IGNORE_LIST", 321)
  tCmds.setaProp("UNIGNORE_USER", 322)
  tCmds.setaProp("CAN_CREATE_ROOMEVENT", 345)
  tCmds.setaProp("CREATE_ROOMEVENT", 346)
  tCmds.setaProp("QUIT_ROOMEVENT", 347)
  tCmds.setaProp("EDIT_ROOMEVENT", 348)
  tCmds.setaProp("GET_ROOMEVENT_TYPE_COUNT", 349)
  tCmds.setaProp("GET_ROOMEVENTS_BY_TYPE", 350)
  tCmds.setaProp("SET_AVATAR_EFFECT", 372)
  tCmds.setaProp("USEFURNITURE", 392)
  tCmds.setaProp("USEWALLITEM", 393)
  tCmds.setaProp("GET_FLOORMAP", 394)
  tCmds.setaProp("TRADE_CONFIRM_ACCEPT", 402)
  tCmds.setaProp("TRADE_CONFIRM_DECLINE", 403)
  tCmds.setaProp("TRADE_REMOVE_ITEM", 405)
  tCmds.setaProp("START_PERFORMANCE", 410)
  tCmds.setaProp("VOTE_PERFORMANCE", 411)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end
