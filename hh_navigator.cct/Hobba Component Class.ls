property pCryDataBase

on construct me
  pCryDataBase = [:]
  registerMessage(#sendCallForHelp, me.getID(), #send_cryForHelp)
  return 1
end

on deconstruct me
  pCryDataBase = [:]
  unregisterMessage(#sendCallForHelp, me.getID())
  return 1
end

on receive_cryforhelp me, tMsg
  pCryDataBase[tMsg[#url]] = tMsg
  me.getInterface().ShowAlert()
  me.getInterface().updateCryWnd()
  return 1
end

on receive_pickedCry me, tMsg
  if voidp(pCryDataBase[tMsg[#url]]) then
    return 0
  end if
  pCryDataBase[tMsg[#url]].picker = tMsg[#picker]
  me.getInterface().updateCryWnd()
  return 1
end

on send_cryPick me, tCryID, tGoHelp
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  getConnection(getVariable("connection.info.id")).send(#info, "PICK_CRYFORHELP" && tCryID)
  if tGoHelp then
    me.getInterface().hideCryWnd()
    tdata = pCryDataBase[tCryID]
    if voidp(tdata) then
      return 0
    end if
    tOk = 1
    tOk = tdata[#picker].ilk = #string and tOk
    tOk = tdata[#url].ilk = #string and tOk
    tOk = tdata[#name].ilk = #string and tOk
    tOk = tdata[#id].ilk = #string and tOk
    tOk = tdata[#port].ilk = #string and tOk
    tOk = tdata[#type].ilk = #symbol and tOk
    tOk = tdata[#msg].ilk = #string and tOk
    if not tOk then
      return error(me, "Invalid or missing data in saved help cry!", #send_cryPick)
    end if
    if tdata[#type] = #private then
      getThread(#navigator).getInterface().pFlatInfoAction = #enterflat
      getThread(#navigator).getComponent().getFlatInfo(tdata[#id])
    else
      getThread(#navigator).getComponent().updateState("enterUnit", tdata[#id])
    end if
  end if
  return 1
end

on send_cryForHelp me, tMsg
  tRoomData = getObject(#session).get("lastroom")
  if tRoomData.ilk = #propList then
    tid = tRoomData[#id]
    tName = tRoomData[#name]
    tPort = tRoomData[#port]
    ttype = tRoomData[#type]
    tMarker = tRoomData[#marker]
  else
    tid = "unknown"
    tName = "unknown"
    tPort = "unknown"
    ttype = "unknown"
    tMarker = "unknown"
  end if
  tMsg = replaceChars(tMsg, "/", SPACE)
  tMsg = replaceChunks(tMsg, RETURN, "<br>")
  tStr = RETURN
  tStr = tStr & "name:" & tName & RETURN
  tStr = tStr & "id:" & tid & RETURN
  tStr = tStr & "port:" & tPort & RETURN
  tStr = tStr & "type:" & ttype & RETURN
  tStr = tStr & "marker:" & tMarker & RETURN
  tStr = tStr & "text:" & tMsg
  if connectionExists(getVariable("connection.room.id")) then
    return getConnection(getVariable("connection.room.id")).send(#room, "CRYFORHELP /" & tStr)
  else
    return error(me, "Failed to access room connection!", #send_cryForHelp)
  end if
end

on getCryDataBase me
  return pCryDataBase
end

on clearCryDataBase me
  pCryDataBase = [:]
  return 1
end
