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
  getConnection(getVariable("connection.info.id")).send("PICK_CRYFORHELP", tCryID)
  if tGoHelp then
    tdata = pCryDataBase[tCryID]
    if voidp(tdata) then
      return 0
    end if
    tOk = 1
    tOk = tdata[#picker].ilk = #string and tOk
    tOk = tdata[#url].ilk = #string and tOk
    tOk = tdata[#name].ilk = #string and tOk
    tOk = tdata[#id].ilk = #string and tOk
    tOk = tdata[#type].ilk = #symbol and tOk
    tOk = tdata[#msg].ilk = #string and tOk
    if not tOk then
      return error(me, "Invalid or missing data in saved help cry!", #send_cryPick)
    end if
    if tdata[#type] = #private then
      tdata[#casts] = getVariableValue("room.cast.private")
    else
      if ilk(tdata[#casts]) = #string then
        tCasts = tdata[#casts]
        tdata[#casts] = []
        tDelim = the itemDelimiter
        the itemDelimiter = ","
        repeat with c = 1 to tCasts.item.count
          tdata[#casts].add(tCasts.item[c])
        end repeat
        the itemDelimiter = tDelim
      end if
    end if
    executeMessage(#executeRoomEntry, tdata[#id], tdata)
  end if
  return 1
end

on send_cryForHelp me, tMsg
  tRoomData = getObject(#session).get("lastroom")
  if not (tRoomData.ilk = #propList) then
    return 0
  end if
  tMsg = replaceChars(tMsg, "/", SPACE)
  tMsg = replaceChunks(tMsg, RETURN, "<br>")
  tMsg = convertSpecialChars(tMsg, 1)
  if tRoomData[#type] = #private then
    tPropList = [#string: tMsg, #string: tRoomData[#marker]]
  else
    tCasts = string(tRoomData[#casts])
    tCasts = replaceChars(tCasts, QUOTE, EMPTY)
    tCasts = replaceChars(tCasts, " ", EMPTY)
    tCasts = replaceChars(tCasts, "[", EMPTY)
    tCasts = replaceChars(tCasts, "]", EMPTY)
    tPropList = [#string: tMsg, #string: tCasts]
  end if
  if connectionExists(getVariable("connection.room.id")) then
    return getConnection(getVariable("connection.room.id")).send("CRYFORHELP", tPropList)
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
