property ancestor, pHost, pPort, pProtocol, pXtraInstance, pConnectionOk, pConnectionSecured, pConnectionShouldBeKilled, pEncryptionOn, pDecoder, pDataCounter, pBeginTime, pLastContent, pContentChunk, pLogMode, pLogfield, pBinaryDataHandler

on new me
  return me
end

on construct me
  pConnectionShouldBeKilled = 0
  tLogMode = getIntVariable("connection.log.level", 0)
  me.setLogMode(tLogMode)
  return 1
end

on deconstruct me
  return me.disconnect(1)
end

on setProtocol me, tProtocol
  case tProtocol of
    #mus:
      pProtocol = #mus
    otherwise:
      pProtocol = #text
  end case
end

on connect me, tHost, tPort
  pHost = tHost
  pPort = tPort
  pBeginTime = the milliSeconds
  pDataCounter = 0
  pXtraInstance = new(xtra("Multiuser"))
  pXtraInstance.setNetBufferLimits(16 * 1024, 100 * 1024, 100)
  tErrCode = pXtraInstance.setNetMessageHandler(#xtraMessageHandler, me)
  if tErrCode = 0 then
    case pProtocol of
      #text:
        pXtraInstance.connectToNetServer("*", "*", pHost, pPort, "*", 1)
      #mus:
        pXtraInstance.connectToNetServer("*", "*", pHost, pPort, "*", 0)
    end case
  else
    return error(me, "Creation of callback failed" && tErrCode, #connect)
  end if
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return 1
end

on disconnect me, tByUser
  if tByUser <> 1 then
    me.handleMessage("DISCONNECT")
  end if
  me.send("QUIT")
  pConnectionShouldBeKilled = 1
  if objectp(pXtraInstance) then
    pXtraInstance.sendNetMessage(0, 0, numToChar(0))
    pXtraInstance.setNetMessageHandler(VOID, VOID)
  end if
  pXtraInstance = VOID
  if not tByUser then
    error(me, "Connection disconnected:" && me.getID(), #disconnect)
  end if
  return 1
end

on connectionReady me
  return pConnectionOk and (pConnectionSecured or pProtocol = #mus)
end

on setDecoder me, tDecoder
  if not objectp(tDecoder) then
    return error(me, "Object expected:" && tDecoder, #setDecoder)
  end if
  pDecoder = tDecoder
  return 1
end

on getDecoder me
  return pDecoder
end

on setLogMode me, tMode
  if not integerp(tMode) then
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

on send me, tMsg
  if pConnectionOk and objectp(pXtraInstance) then
    if pLogMode > 0 then
      me.log("<--" && tMsg)
    end if
    getObject(#session).set("con_lastsend", tMsg && "-" && the long time)
    tMsg = replaceChunks(tMsg, "Š", "&auml;")
    tMsg = replaceChunks(tMsg, "š", "&ouml;")
    tLength = EMPTY & tMsg.length
    repeat while tLength.length < 4
      tLength = tLength & " "
    end repeat
    if pEncryptionOn and objectp(pDecoder) then
      if pProtocol <> #mus then
        tMsg = pDecoder.encipher(tLength & tMsg)
      else
        tMsg = pDecoder.encipher(tMsg)
      end if
    else
      if pProtocol <> #mus then
        tMsg = tLength & tMsg
      else
        tMsg = tMsg
      end if
    end if
    case pProtocol of
      #text:
        pXtraInstance.sendNetMessage(0, 0, tMsg)
      #mus:
        pXtraInstance.sendNetMessage("*", tMsg.word[1], tMsg.word[2..tMsg.word.count])
    end case
  else
    return error(me, "Connection not ready:" && me.getID(), #send)
  end if
  return 1
end

on sendBinary me, tObject
  if pConnectionOk and objectp(pXtraInstance) then
    if pProtocol <> #mus then
      return error(me, "Can't send binary in text connection!", #sendBinary)
    else
      return pXtraInstance.sendNetMessage("*", "BINDATA", tObject)
    end if
  end if
end

on registerBinaryDataHandler me, tObject
  pBinaryDataHandler = tObject
  return 1
end

on getWaitingMessagesCount me
  return pXtraInstance.getNumberWaitingNetMessages()
end

on processWaitingMessages me, tCount
  if voidp(tCount) then
    tCount = 1
  end if
  return pXtraInstance.checkNetMessages(tCount)
end

on getProperty me, tProp
  case tProp of
    #host:
      return pHost
    #port:
      return pPort
    #protocol:
      return pProtocol
    #decoder:
      return me.getDecoder()
    #logmode:
      return me.getLogMode()
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #protocol:
      return me.setProtocol(tValue)
    #decoder:
      return me.setDecoder(tValue)
    #logmode:
      return me.setLogMode(tValue)
  end case
  return 0
end

on xtraMessageHandler me
  if pConnectionShouldBeKilled <> 0 then
    return 0
  end if
  pConnectionOk = 1
  tNewMessage = pXtraInstance.getNetMessage()
  tErrCode = getaProp(tNewMessage, #errorCode)
  tContent = getaProp(tNewMessage, #content)
  if tErrCode <> 0 then
    if pLogMode > 0 then
      me.log("Connection" && me.getID() && "was disconnected")
      me.log("host = " & pHost && ", port = " & pPort)
      me.log(tNewMessage)
    end if
    disconnect(me)
    return 0
  end if
  if stringp(tContent) and pProtocol = #text then
    if not (tContent contains "##") then
      if voidp(pLastContent) then
        pLastContent = EMPTY
      end if
      pLastContent = pLastContent & tContent
      return 0
    end if
    if not voidp(pLastContent) then
      tContent = pLastContent & tContent
    end if
    tDelim = the itemDelimiter
    pContentChunk = EMPTY
    tContentArray = []
    the itemDelimiter = "##"
    tBool = 0
    if not (tContent.char[tContent.length - 2..tContent.length] contains "##") then
      tBool = 1
    end if
    pLastContent = EMPTY
    tCount = tContent.items.count
    repeat with i = 1 to tCount
      if i < tCount or tBool = 0 then
        tContentArray.add(tContent.item[i])
        next repeat
      end if
      if tBool = 1 and i = tCount then
        pLastContent = tContent.item[i]
      end if
    end repeat
    the itemDelimiter = tDelim
    repeat with i = 1 to tContentArray.count
      if tContentArray[i].length > 1 then
        me.handleMessage(tContentArray[i])
      end if
    end repeat
  else
    if stringp(tContent) and pProtocol = #mus then
      me.handleMessage(tNewMessage.subject & RETURN & tNewMessage.content)
    else
      if tContent <> VOID then
        if pBinaryDataHandler <> VOID then
          call(#binaryDataReceived, getObject(pBinaryDataHandler), tContent)
        end if
      end if
    end if
  end if
end

on handleMessage me, tMsg
  if pConnectionShouldBeKilled <> 0 then
    return 0
  end if
  if pLogMode > 0 then
    me.log("-->" && tMsg)
  end if
  getObject(#session).set("con_lastreceived", tMsg.line[1] && "-" && the long time)
  tMsg = convertSpecialChars(tMsg)
  tCommand = tMsg.line[1].word[1]
  tMessage = [:]
  tParserData = getParserMethod(me.getID(), tCommand)
  if listp(tParserData) then
    tMessage = call(tParserData[1], getParser(tParserData[2]), tMsg)
  else
    tMessage = [#command: tCommand, #message: tMsg]
  end if
  tHandlerData = getHandlerMethod(me.getID(), tCommand)
  if listp(tHandlerData) then
    call(tHandlerData[1], getHandler(tHandlerData[2]), tMessage, me)
  else
    return error(me, "Handler not found:" && tCommand && "/" && me.getID(), #handleMessage)
  end if
  return 1
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
