property pHost, pPort, pXtra, pMsgStruct, pConnectionOk, pConnectionSecured, pConnectionShouldBeKilled, pEncryptionOn, pDecoder, pLastContent, pContentChunk, pLogMode, pLogfield, pCommandsPntr, pListenersPntr

on construct me
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me.getID())
  pDecoder = 0
  pLastContent = EMPTY
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  return 1
end

on deconstruct me
  return me.disconnect(1)
end

on connect me, tHost, tPort
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if tErrCode = 0 then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return error(me, "Creation of callback failed:" && tErrCode, #connect)
  end if
  pLastContent = EMPTY
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return 1
end

on disconnect me, tControlled
  if tControlled <> 1 then
    me.forwardMsg("DISCONNECT")
  else
    me.send(#info, "QUIT")
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(VOID, VOID)
  end if
  pXtra = VOID
  if not tControlled then
    error(me, "Connection disconnected:" && me.getID(), #disconnect)
  end if
  return 1
end

on connectionReady me
  return pConnectionOk and pConnectionSecured
end

on setDecoder me, tDecoder
  if not objectp(tDecoder) then
    return error(me, "Decoder object expected:" && tDecoder, #setDecoder)
  else
    pDecoder = tDecoder
    return 1
  end if
end

on getDecoder me
  return pDecoder
end

on setLogMode me, tMode
  if tMode.ilk <> #integer then
    return error(me, "Invalid argument:" && tMode, #setLogMode)
  end if
  pLogMode = tMode
  if pLogMode = 2 then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = VOID
      pLogMode = 1
    end if
  end if
  return 1
end

on getLogMode me
  return pLogMode
end

on setEncryption me, tBoolean
  pEncryptionOn = tBoolean
  pConnectionSecured = 1
  return 1
end

on send me, tCmd, tMsg
  if not (pConnectionOk and objectp(pXtra)) then
    return error(me, "Connection not ready:" && me.getID(), #send)
  end if
  if tMsg.ilk <> #string then
    tMsg = string(tMsg)
  end if
  if pLogMode > 0 then
    me.log("<--" && tCmd && tMsg)
  end if
  getObject(#session).set("con_lastsend", tCmd && tMsg && "-" && the long time)
  if tCmd.ilk <> #integer then
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tCmd)
  end if
  if tCmd.ilk = #void then
    return error(me, "Unrecognized command!", #send)
  end if
  if pEncryptionOn and objectp(pDecoder) then
    tMsg = pDecoder.encipher(tMsg)
  else
  end if
  tLength = 0
  repeat with tChar = 1 to length(tMsg)
    tCharNum = charToNum(char tChar of tMsg)
    tLength = tLength + 1 + (tCharNum > 255)
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 127), 128))
  tL2 = numToChar(bitOr(bitAnd(tLength / 128, 127), 128))
  tL3 = numToChar(bitOr(bitAnd(tLength / 16384, 127), 128))
  tMsg = tCmd & tL3 & tL2 & tL1 & tMsg
  pXtra.sendNetMessage(0, 0, tMsg)
  return 1
end

on getWaitingMessagesCount me
  return pXtra.getNumberWaitingNetMessages()
end

on processWaitingMessages me, tCount
  if voidp(tCount) then
    tCount = 1
  end if
  return pXtra.checkNetMessages(tCount)
end

on getProperty me, tProp
  case tProp of
    #xtra:
      return pXtra
    #host:
      return pHost
    #port:
      return pPort
    #decoder:
      return me.getDecoder()
    #logmode:
      return me.getLogMode()
    #listener:
      return pListenersPntr
    #commands:
      return pCommandsPntr
    #message:
      return pMsgStruct
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #decoder:
      return me.setDecoder(tValue)
    #logmode:
      return me.setLogMode(tValue)
    #listener:
      if tValue.ilk = #struct then
        pListenersPntr = tValue
        return 1
      else
        return 0
      end if
    #commands:
      if tValue.ilk = #struct then
        pCommandsPntr = tValue
        return 1
      else
        return 0
      end if
  end case
  return 0
end

on print me
  tStr = EMPTY
  if symbolp(me.getID()) then
    put "#" after tStr
  end if
  put me.getID() & RETURN after tStr
  put "-- -- -- -- -- -- -- --" & RETURN after tStr
  tMsgsList = pListenersPntr.getaProp(#value)
  if listp(tMsgsList) then
    repeat with i = 1 to count(tMsgsList)
      put TAB & tMsgsList.getPropAt(i) & RETURN after tStr
      tCallbackList = tMsgsList[i]
      repeat with tCallback in tCallbackList
        put TAB & TAB & tCallback[1] && "->" && tCallback[2] & RETURN after tStr
      end repeat
      put RETURN after tStr
    end repeat
  end if
  put tStr & RETURN
  return 1
end

on xtraMsgHandler me
  if pConnectionShouldBeKilled <> 0 then
    return 0
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  if tErrCode <> 0 then
    if pLogMode > 0 then
      me.log("Connection" && me.getID() && "was disconnected")
      me.log("host = " & pHost && ", port = " & pPort)
      me.log(tNewMsg)
    end if
    me.disconnect()
    return 0
  end if
  if tContent.ilk = #string then
    if not (tContent contains "##") then
      pLastContent = pLastContent & tContent
      return 0
    end if
    if pLastContent <> EMPTY then
      tContent = pLastContent & tContent
    end if
    tDelim = the itemDelimiter
    pContentChunk = EMPTY
    tContentArray = []
    the itemDelimiter = "##"
    tLength = length(tContent)
    tBool = not (chars(tContent, tLength - 1, tLength) = "##")
    tCount = tContent.items.count
    pLastContent = EMPTY
    repeat with i = 1 to tCount
      tMsgStr = tContent.item[i]
      if i < tCount or tBool = 0 then
        if length(tMsgStr) > 1 then
          tContentArray.add(tMsgStr)
        end if
        next repeat
      end if
      if tBool = 1 and i = tCount then
        pLastContent = tMsgStr
      end if
    end repeat
    the itemDelimiter = tDelim
    repeat with i = 1 to tContentArray.count
      me.forwardMsg(tContentArray[i])
    end repeat
  end if
end

on forwardMsg me, tMessage
  if pConnectionShouldBeKilled = 1 then
    return 0
  end if
  if pLogMode > 0 then
    me.log("-->" && tMessage)
  end if
  getObject(#session).set("con_lastreceived", tMessage.line[1] && "-" && the long time)
  tSubject = tMessage.word[1]
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if pMsgStruct.ilk <> #struct then
    pMsgStruct = getStructVariable("struct.message")
    pMsgStruct.setaProp(#connection, me.getID())
    error(me, "Connection instance had problems...", #forwardMsg)
  end if
  if listp(tCallbackList) then
    tObjMngr = getObjectManager()
    repeat with i = 1 to count(tCallbackList)
      tCallback = tCallbackList[i]
      tObject = tObjMngr.get(tCallback[1])
      if tObject <> 0 then
        pMsgStruct.setaProp(#message, tMessage)
        pMsgStruct.setaProp(#subject, tSubject)
        pMsgStruct.setaProp(#content, tMessage.word[2..tMessage.word.count])
        call(tCallback[2], tObject, pMsgStruct)
        next repeat
      end if
      error(me, "Listening obj not found, removed:" && tCallback[1], #forwardMsg)
      tCallbackList.deleteAt(1)
      i = i - 1
    end repeat
  else
    error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg)
  end if
end

on log me, tMsg
  case pLogMode of
    1:
      put "[Connection" && me.getID() & "] :" && tMsg
    2:
      if ilk(pLogfield, #member) then
        put RETURN & "[Connection" && me.getID() & "] :" && tMsg after pLogfield
      end if
  end case
end
