property pLastStatusOK, pStatusPeriod

on construct me
  pLastStatusOK = the milliSeconds
  pStatusPeriod = getIntVariable("room.status.period", 45000)
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on parse_opc_ok me, tMsg
  if me.getComponent().getRoomID() = "private" then
    me.getComponent().roomConnected(VOID, tMsg.subject)
  end if
end

on parse_clc me
  me.getComponent().roomDisconnected()
end

on parse_youaremod me, tMsg
  getObject(#session).set("moderator", tMsg.message.line[2])
end

on parse_flat_letin me, tMsg
  executeMessage("flat_letin")
  me.getComponent().roomConnected(VOID, tMsg.subject)
end

on parse_room_ready me, tMsg
  me.getComponent().roomConnected(tMsg.content.word[1], tMsg.subject)
end

on parse_logout me, tMsg
  tuser = tMsg.content.word[1]
  if tuser <> getObject(#session).get("user_name") then
    me.getComponent().removeUserObject(tuser)
  end if
end

on parse_disconnect me
  me.getComponent().roomDisconnected()
end

on parse_error me, tMsg
  me.getHandler().handle_error(tMsg.content, tMsg.connection)
end

on parse_doorbell_ringing me, tMsg
  me.getInterface().showDoorBell(tMsg.content)
end

on parse_status me, tMsg
  tList = []
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  repeat with i = 1 to tCount
    tLine = tMsg.content.line[i]
    if length(tLine) > 5 then
      tuser = [:]
      tuser[#id] = tLine.item[1].word[1]
      tloc = tLine.item[1].word[2]
      the itemDelimiter = ","
      tuser[#x] = integer(tloc.item[1])
      tuser[#y] = integer(tloc.item[2])
      tuser[#h] = integer(tloc.item[3])
      tuser[#dirHead] = integer(tloc.item[4]) mod 8
      tuser[#dirBody] = integer(tloc.item[5]) mod 8
      tActions = []
      the itemDelimiter = "/"
      repeat with j = 2 to tLine.item.count
        if length(tLine.item[j]) > 1 then
          tActions.add([#name: tLine.item[j].word[1], #params: tLine.item[j]])
        end if
      end repeat
      tuser[#actions] = tActions
      tList.add(tuser)
    end if
  end repeat
  the itemDelimiter = tDelim
  repeat with tuser in tList
    tUserObj = me.getComponent().getUserObject(tuser[#id])
    if tUserObj <> 0 then
      tUserObj.refresh(tuser[#x], tuser[#y], tuser[#h], tuser[#dirHead], tuser[#dirBody])
      repeat with tAction in tuser[#actions]
        call(symbol("action_" & tAction[#name]), [tUserObj], tAction[#params])
      end repeat
    end if
  end repeat
  if the milliSeconds - pLastStatusOK > pStatusPeriod then
    getConnection(tMsg.connection).send(#room, "STATUSOK")
    pLastStatusOK = the milliSeconds
  end if
end

on parse_chat me, tMsg
  tuser = tMsg.content.word[1]
  tChat = tMsg.content.word[2..tMsg.content.word.count]
  tProp = [#command: tMsg.subject, #id: tuser, #message: tChat]
  if me.getComponent().userObjectExists(tuser) then
    me.getComponent().getBalloon().createBalloon(tProp)
  end if
end

on parse_users me, tMsg
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  tList = [:]
  tuser = EMPTY
  if not threadExists(#registration) then
    error(me, "Registration thread not found!", #parse_users)
    return 0
  end if
  repeat with f = 1 to tCount
    tLine = tMsg.content.line[f]
    tProp = tLine.char[1]
    tdata = tLine.char[3..length(tLine)]
    case tProp of
      "n":
        tuser = tdata
        tList[tuser] = [:]
        tList[tuser][#id] = tuser
        tList[tuser][#direction] = [0, 0]
        tList[tuser][#class] = "user"
      "f":
        tList[tuser][#figure] = tdata
      "l":
        tList[tuser][#x] = integer(tdata.word[1])
        tList[tuser][#y] = integer(tdata.word[2])
        tList[tuser][#h] = integer(tdata.word[3])
      "c":
        tList[tuser][#Custom] = tdata
      "s":
        if tdata.char[1] = "F" or tdata.char[1] = "f" then
          tList[tuser][#sex] = "F"
        else
          tList[tuser][#sex] = "M"
        end if
      "p":
        if tdata contains "ch=s" then
          the itemDelimiter = "/"
          tmodel = tdata.char[4..6]
          tColor = tdata.item[2]
          the itemDelimiter = ","
          if tColor.item.count = 3 then
            tColor = value("rgb(" & tColor & ")")
          else
            tColor = rgb(#EEEEEE)
          end if
          tList[tuser][#phfigure] = ["model": tmodel, "color": tColor]
          tList[tuser][#class] = "pelle"
        end if
      otherwise:
        if tLine.word[1] = "[bot]" then
          tList[tuser][#class] = "bot"
        end if
    end case
  end repeat
  tFigureParser = getThread(#registration).getComponent()
  repeat with tuser in tList
    tuser[#figure] = tFigureParser.parseFigure(tuser[#figure], tuser[#sex], tuser[#class])
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_users(tList)
end

on parse_showprogram me, tMsg
  tLine = tMsg.content
  tDst = tLine.word[1]
  tCmd = tLine.word[2]
  tArg = tLine.word[3..tLine.word.count]
  tList = [#command: tMsg.subject, #show_dest: tDst, #show_command: tCmd, #show_params: tArg]
  tObj = me.getComponent().getRoomPrg()
  if objectp(tObj) then
    call(#showprogram, [tObj], tList)
  end if
end

on parse_heightmap me, tMsg
  me.getComponent().validateHeightMap(tMsg.content)
end

on parse_objects me, tMsg
  tList = []
  tCount = tMsg.message.line.count
  repeat with i = 2 to tCount
    tLine = tMsg.content.line[i]
    if length(tLine) > 5 then
      tObj = [:]
      tObj[#id] = tLine.word[1]
      tObj[#class] = tLine.word[2]
      tObj[#x] = integer(tLine.word[3])
      tObj[#y] = integer(tLine.word[4])
      tObj[#h] = integer(tLine.word[5])
      if tLine.word.count = 6 then
        tdir = integer(tLine.word[6]) mod 8
        tObj[#direction] = [tdir, tdir, tdir]
        tObj[#dimensions] = 0
      else
        tObj[#width] = integer(tLine.word[6])
        tObj[#height] = integer(tLine.word[7])
        tObj[#dimensions] = [tObj[#width], tObj[#height]]
        tObj[#x] = tObj[#x] + tObj[#width] - 1
        tObj[#y] = tObj[#y] + tObj[#height] - 1
      end if
      if tObj[#id] <> EMPTY then
        tList.add(tObj)
      end if
    end if
  end repeat
  me.getHandler().handle_OBJECTS(tList)
end

on parse_active_objects me, tMsg
  tList = []
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  repeat with i = 1 to tCount
    tLine = tMsg.content.line[i]
    if tLine = EMPTY then
      exit repeat
    end if
    the itemDelimiter = "/"
    tstate = tLine.item[1]
    the itemDelimiter = ","
    tObj = [:]
    tObj[#id] = tstate.item[1]
    tOther = tstate.char[offset(",", tstate) + 1..length(tstate)]
    tObj[#class] = tOther.word[1]
    tObj[#x] = integer(tOther.word[2])
    tObj[#y] = integer(tOther.word[3])
    tObj[#width] = integer(tOther.word[4])
    tObj[#height] = integer(tOther.word[5])
    tDirection = integer(tOther.word[6]) mod 8
    tObj[#direction] = [tDirection, tDirection, tDirection]
    tObj[#dimensions] = [tObj.width, tObj.height]
    tObj[#altitude] = float(tOther.word[7])
    tObj[#colors] = tOther.word[8]
    the itemDelimiter = "/"
    tObj[#props] = [:]
    tObj[#name] = tLine.item[2]
    tObj[#Custom] = tLine.item[3]
    tBool = 1
    j = 4
    repeat while tBool
      tKey = tLine.item[j]
      tdata = tLine.item[j + 1]
      if length(tKey) = 0 then
        tBool = 0
      else
        tObj[#props][tKey] = tdata
      end if
      j = j + 2
    end repeat
    if tObj[#id] <> EMPTY then
      tList.add(tObj)
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_active_objects(tList)
end

on parse_activeobject_remove me, tMsg
  me.getComponent().removeActiveObject(tMsg.content.word[1])
end

on parse_activeobject_update me, tMsg
  tLine = tMsg.content.line[1]
  if tLine = EMPTY then
    return 0
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tstate = tLine.item[1]
  the itemDelimiter = ","
  tObj = [:]
  tObj[#id] = tstate.item[1]
  tOther = tstate.char[offset(",", tstate) + 1..length(tstate)]
  tObj[#class] = tOther.word[1]
  tObj[#x] = integer(tOther.word[2])
  tObj[#y] = integer(tOther.word[3])
  tObj[#width] = integer(tOther.word[4])
  tObj[#height] = integer(tOther.word[5])
  tDirection = integer(tOther.word[6]) mod 8
  tObj[#direction] = [tDirection, tDirection, tDirection]
  tObj[#dimensions] = [tObj.width, tObj.height]
  tObj[#altitude] = float(tOther.word[7])
  tObj[#colors] = tOther.word[8]
  the itemDelimiter = "/"
  tObj[#props] = [:]
  tObj[#name] = tLine.item[2]
  tObj[#Custom] = tLine.item[3]
  tBool = 1
  j = 4
  repeat while tBool
    tKey = tLine.item[j]
    tdata = tLine.item[j + 1]
    if length(tKey) = 0 then
      tBool = 0
    else
      tObj[#props][tKey] = tdata
    end if
    j = j + 2
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_activeobject_update(tObj)
end

on parse_items me, tMsg
  tList = []
  tDelim = the itemDelimiter
  repeat with i = 1 to tMsg.content.line.count
    the itemDelimiter = TAB
    tLine = tMsg.content.line[i]
    if tLine <> EMPTY then
      tObj = [:]
      tObj[#id] = tLine.item[1]
      tObj[#class] = tLine.item[2]
      tObj[#owner] = tLine.item[3]
      tObj[#type] = tLine.item[5]
      if not (tLine.item[4].char[1] = ":") then
        tObj[#direction] = tLine.item[4].word[1]
        if tObj[#direction] = "frontwall" then
          tObj[#direction] = "rightwall"
        end if
        tlocation = tLine.item[4].word[2..tLine.item[4].word.count]
        the itemDelimiter = ","
        tObj[#x] = 0
        tObj[#y] = float(tlocation.item[1])
        tObj[#h] = float(tlocation.item[2])
        tObj[#z] = integer(tlocation.item[3])
        tObj[#formatVersion] = #old
      else
        tLocString = tLine.item[4]
        tWallLoc = tLocString.word[1].char[4..length(tLocString.word[1])]
        the itemDelimiter = ","
        tObj[#wall_x] = value(tWallLoc.item[1])
        tObj[#wall_y] = value(tWallLoc.item[2])
        tLocalLoc = tLocString.word[2].char[3..length(tLocString.word[2])]
        tObj[#local_x] = value(tLocalLoc.item[1])
        tObj[#local_y] = value(tLocalLoc.item[2])
        tDirChar = tLocString.word[3]
        case tDirChar of
          "r":
            tObj[#direction] = "rightwall"
          "l":
            tObj[#direction] = "leftwall"
        end case
        tObj[#formatVersion] = #new
      end if
      tList.add(tObj)
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_items(tList)
end

on parse_removeitem me, tMsg
  me.getComponent().removeItemObject(tMsg.content)
end

on parse_updateitem me
  error(me, "Unfinished method!!!", #parse_updateitem)
end

on parse_stuffdataupdate me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.content.line[1]
  tProps = [#target: tLine.item[1], #key: tLine.item[3], #value: tLine.item[4]]
  the itemDelimiter = tDelim
  me.getHandler().handle_stuffdataupdate(tProps)
end

on parse_presentopen me, tMsg
  ttype = tMsg.message.line[2]
  tCode = tMsg.message.line[3]
  me.getHandler().handle_presentopen([#type: ttype, #code: tCode])
end

on parse_present_nottimeyet me, tMsg
  put "Hands off! Christmas presents can't be opened until December 24th (6pm GMT)."
end

on parse_flatproperty me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.content
  tdata = [#key: tLine.item[1], #value: tLine.item[2]]
  the itemDelimiter = tDelim
  tRoomPrg = me.getComponent().getRoomPrg()
  if tRoomPrg <> 0 then
    tRoomPrg.setProperty(tdata[#key], tdata[#value])
  else
    error(me, "Private room program not found!", #handle_flatproperty)
  end if
end

on parse_room_rights me, tMsg
  case tMsg.subject of
    "YOUARECONTROLLER":
      getObject(#session).set("room_controller", 1)
    "YOUNOTCONTROLLER":
      getObject(#session).set("room_controller", 0)
    "YOUAREOWNER":
      getObject(#session).set("room_owner", 1)
  end case
end

on parse_stripinfo me, tMsg
  tProps = [#objects: [], #count: 0]
  tDelim = the itemDelimiter
  tProps[#count] = integer(tMsg.content.line[tMsg.content.line.count])
  the itemDelimiter = "/"
  tCount = tMsg.content.item.count
  repeat with i = 1 to tCount
    the itemDelimiter = "/"
    tItem = tMsg.content.item[i]
    if tItem = EMPTY then
      exit repeat
    end if
    the itemDelimiter = "|"
    if tItem.item.count < 2 then
      exit repeat
    end if
    tObj = [:]
    tObj[#stripId] = tItem.item[2]
    tObj[#striptype] = tItem.item[4]
    tObj[#id] = tItem.item[5]
    tObj[#class] = tItem.item[6]
    tObj[#name] = tItem.item[7]
    case tObj[#striptype] of
      "S":
        tObj[#striptype] = "active"
        tObj[#Custom] = tItem.item[8]
        tObj[#dimensions] = [integer(tItem.item[9]), integer(tItem.item[10])]
        tObj[#colors] = tItem.item[11]
        the itemDelimiter = ","
        if tObj[#colors].char[1] = "*" then
          if tObj[#colors].item.count > 1 then
            tObj[#stripColor] = rgb(tObj[#colors].item[tObj[#colors].item.count].char[2..7])
          else
            tObj[#stripColor] = rgb(tObj[#colors].char[2..7])
          end if
        else
          tObj[#stripColor] = 0
        end if
      "I":
        tObj[#striptype] = "item"
        tObj[#props] = tItem.item[8]
        tObj[#Custom] = tItem.item[9]
    end case
    tProps[#objects].add(tObj)
  end repeat
  the itemDelimiter = tDelim
  case tMsg.subject of
    "STRIPINFO":
      me.getHandler().handle_stripinfo(tProps)
    "ADDSTRIPITEM":
      me.getHandler().handle_addstripitem(tProps)
    "TRADE_ITEMS":
      return tProps
  end case
end

on parse_stripupdated me, tMsg
  getConnection(tMsg.connection).send(#room, "GETSTRIP new")
end

on parse_removestripitem me, tMsg
  me.getInterface().getContainer().removeStripItem(tMsg.content.word[1])
end

on parse_youarenotallowed me
  executeMessage(#alert, [#msg: "trade_youarenotallowed", #id: "youarenotallowed"])
end

on parse_othernotallowed me
  executeMessage(#alert, [#msg: "trade_othernotallowed", #id: "othernotallowed"])
end

on parse_idata me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  tid = integer(tMsg.content.line[1].item[1])
  tText = tMsg.content.line[1].item[2] & RETURN & tMsg.content.line[2..tMsg.content.line.count]
  the itemDelimiter = tDelim
  tProps = [#id: tid, #text: tText]
  executeMessage(symbol("itemdata_received" & tid), tProps)
end

on parse_trade_items me, tMsg
  tMessage = [:]
  repeat with i = 1 to 2
    tLine = tMsg.content.line[i]
    tdata = [:]
    tdata[#accept] = tLine.word[2]
    tItemStr = "Kludgetus" & RETURN & tLine.word[3..tLine.word.count] & RETURN & 1
    tdata[#items] = me.parse_stripinfo([#subject: "TRADE_ITEMS", #content: tItemStr]).getaProp(#objects)
    tMessage[tLine.word[1]] = tdata
  end repeat
  me.getInterface().getSafeTrader().refresh(tMessage)
end

on parse_trade_close me, tMsg
  me.getInterface().getSafeTrader().close()
  getConnection(tMsg.connection).send(#room, "GETSTRIP new")
end

on parse_trade_accept me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tuser = tMsg.content.item[1]
  tValue = tMsg.content.item[2]
  if tValue = "true" then
    tValue = 1
  else
    if tValue = "false" then
      tValue = 0
    end if
  end if
  the itemDelimiter = tDelim
  me.getInterface().getSafeTrader().accept(tuser, tValue)
end

on parse_trade_completed me, tMsg
  me.getInterface().getSafeTrader().complete()
end

on parse_door_in me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = tMsg.content.item[1]
  tuser = tMsg.content.item[2]
  tParam = tMsg.content.item[3]
  the itemDelimiter = tDelim
  tProps = [#door: tDoor, #user: tuser, #param: tParam]
  me.getHandler().handle_door_in(tProps)
end

on parse_door_out me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = tMsg.content.item[1]
  tuser = tMsg.content.item[2]
  tParam = tMsg.content.item[3]
  the itemDelimiter = tDelim
  tProps = [#door: tDoor, #user: tuser, #param: tParam]
  me.getHandler().handle_door_out(tProps)
end

on parse_doorflat me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tStr = tMsg.content
  tDoorID = tStr.line[1].word[1]
  tFlatID = tStr.line[2].item[1]
  tName = tStr.line[2].item[2]
  towner = tStr.line[2].item[3]
  tOpen = tStr.line[2].item[4]
  tFloorA = tStr.line[2].item[5]
  tFloorB = tStr.line[2].item[6]
  tHost = tStr.line[2].item[7]
  tip = tStr.line[2].item[8]
  tPort = tStr.line[2].item[9]
  tDesc = tStr.line[2].item[12]
  the itemDelimiter = tDelim
  tMsg = [#name: tName, #owner: towner, #door: "open", #id: tFlatID, #ip: tip, #port: tPort, #teleport: tDoorID]
  me.getHandler().handle_doorflat(tMsg)
end

on parse_doordeleted me, tMsg
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).get("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if tDoorObj <> 0 then
      tDoorObj.kickOut()
    end if
  end if
end

on parse_dice_value me, tMsg
  tid = tMsg.message.word[2]
  tValue = integer(tMsg.message.word[3] - tid * 38)
  if me.getComponent().activeObjectExists(tid) then
    me.getComponent().getActiveObject(tid).diceThrown(tValue)
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs["OPC_OK"] = #parse_opc_ok
  tMsgs["CLC"] = #parse_clc
  tMsgs["YOUAREMOD"] = #parse_youaremod
  tMsgs["FLAT_LETIN"] = #parse_flat_letin
  tMsgs["ROOM_READY"] = #parse_room_ready
  tMsgs["LOGOUT"] = #parse_logout
  tMsgs["DISCONNECT"] = #parse_disconnect
  tMsgs["ERROR"] = #parse_error
  tMsgs["DOORBELL_RINGING"] = #parse_doorbell_ringing
  tMsgs["STATUS"] = #parse_status
  tMsgs["CHAT"] = #parse_chat
  tMsgs["SHOUT"] = #parse_chat
  tMsgs["WHISPER"] = #parse_chat
  tMsgs["USERS"] = #parse_users
  tMsgs["SHOWPROGRAM"] = #parse_showprogram
  tMsgs["HEIGHTMAP"] = #parse_heightmap
  tMsgs["OBJECTS"] = #parse_objects
  tMsgs["ACTIVE_OBJECTS"] = #parse_active_objects
  tMsgs["ACTIVEOBJECT_ADD"] = #parse_active_objects
  tMsgs["ACTIVEOBJECT_REMOVE"] = #parse_activeobject_remove
  tMsgs["ITEMS"] = #parse_items
  tMsgs["ADDITEM"] = #parse_items
  tMsgs["REMOVEITEM"] = #parse_removeitem
  tMsgs["UPDATEITEM"] = #parse_updateitem
  tMsgs["ACTIVEOBJECT_UPDATE"] = #parse_activeobject_update
  tMsgs["STUFFDATAUPDATE"] = #parse_stuffdataupdate
  tMsgs["PRESENTOPEN"] = #parse_presentopen
  tMsgs["PRESENT_NOTTIMEYET"] = #parse_present_nottimeyet
  tMsgs["FLATPROPERTY"] = #parse_flatproperty
  tMsgs["YOUARECONTROLLER"] = #parse_room_rights
  tMsgs["YOUNOTCONTROLLER"] = #parse_room_rights
  tMsgs["YOUAREOWNER"] = #parse_room_rights
  tMsgs["STRIPINFO"] = #parse_stripinfo
  tMsgs["ADDSTRIPITEM"] = #parse_stripinfo
  tMsgs["STRIPUPDATED"] = #parse_stripupdated
  tMsgs["REMOVESTRIPITEM"] = #parse_removestripitem
  tMsgs["TRADE_ITEMS"] = #parse_trade_items
  tMsgs["TRADE_ACCEPT"] = #parse_trade_accept
  tMsgs["TRADE_CLOSE"] = #parse_trade_close
  tMsgs["TRADE_COMPLETED"] = #parse_trade_completed
  tMsgs["TRADE_ALREADYOPEN"] = #parse_trade_completed
  tMsgs["TRADE_YOUARENOTALLOWED"] = #parse_youarenotallowed
  tMsgs["TRADE_OTHERNOTALLOWED"] = #parse_othernotallowed
  tMsgs["IDATA"] = #parse_idata
  tMsgs["DOOR_IN"] = #parse_door_in
  tMsgs["DOOR_OUT"] = #parse_door_out
  tMsgs["DICE_VALUE"] = #parse_dice_value
  tCmds = [:]
  tCmds[#room_directory] = numToChar(128) & numToChar(130)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  tMsgs = [:]
  tMsgs["DOORFLAT"] = #parse_doorflat
  tMsgs["DOORDELETED"] = #parse_doordeleted
  tMsgs["DOORNOTINSTALLED"] = #parse_doordeleted
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
  end if
  return 1
end
