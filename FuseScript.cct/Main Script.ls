global gConnectionInstance, gConnectionOk, gAvatarManager, gBalloonManager, lastContent, gpBalloons, gLastBalloon, gpShowSprites, gUserSprites, gUnits, gChosenUnit, gChosenUnitIp, gChosenUnitPort, gEnterpriseServerConnection, gConnectionsSecured, hiliter, gConnectionShouldBeKilled, glastSnowBall, gmemnamedb, gPhonenumberOk, gCountryPrefix

on stopMovie
  gmemnamedb = VOID
end

on idle
  if the ticks - gLastBalloon > 650 then
    gLastBalloon = the ticks
    balloonsUp()
  end if
end

on checkStatusOk
  global lastStatusOk
  if the ticks - lastStatusOk > 60 then
    sendEPFuseMsg("STATUSOK")
  end if
end

on LogonEnterpriseServer
  gConnectionsSecured = 0
  gConnectionShouldBeKilled = 0
  if objectp(gConnectionInstance) then
    errCode = SetNetMessageHandler(gConnectionInstance, 0, 0)
  end if
  gConnectionInstance = 0
  gConnectionInstance = new(xtra("Multiuser"))
  errCode = SetNetMessageHandler(gConnectionInstance, #EPDefaultMessageHandler, script("Main Script"))
  if errCode = 0 then
    gConnectionOk = 0
    hostname = the text of field "enterpriseServerHost"
    hostport = integer(the text of field "enterpriseServerPort")
    put hostname, hostport
    ConnectToNetServer(gConnectionInstance, "*", "*", hostname, hostport, "*", 1)
    put "Message"
  else
    ShowAlert("Creation of callback failed" & errCode)
  end if
end

on Logon
  gConnectionsSecured = 0
  gConnectionShouldBeKilled = 0
  if objectp(gConnectionInstance) then
    errCode = SetNetMessageHandler(gConnectionInstance, 0, 0)
  end if
  gConnectionInstance = 0
  lastContent = VOID
  gConnectionInstance = new(xtra("Multiuser"))
  put gConnectionInstance
  errCode = SetNetMessageHandler(gConnectionInstance, #DefaultMessageHandler, script("Main Script"))
  if errCode = 0 then
    gConnectionOk = 0
    hostname = gChosenUnitIp
    hostport = gChosenUnitPort
    put "Hos:" && hostname, hostport
    ConnectToNetServer(gConnectionInstance, "*", "*", hostname, hostport, "*", 1)
  else
    ShowAlert("Creation of callback failed" & errCode)
  end if
end

on sendFuseMsg s
  global gcatName, RC4, gKryptausOn
  if gConnectionOk = 1 and objectp(gConnectionInstance) then
    s = stringReplace(s, "Š", "&auml;")
    s = stringReplace(s, "š", "&ouml;")
    len = EMPTY & s.length
    repeat while len.length < 4
      len = len & " "
    end repeat
    if gKryptausOn = 1 and objectp(RC4) then
      tMsg = RC4.encipher(len & s)
    else
      tMsg = len & s
    end if
    SendNetMessage(gConnectionInstance, 0, 0, tMsg)
  else
    put "connection not ready!"
  end if
end

on fuseLogin user, password, noDoor
  global gDoor
  if voidp(gDoor) then
    gDoor = 0
  end if
  if noDoor <> 1 then
    sendFuseMsg("LOGIN" && user && password && gDoor)
  else
    sendFuseMsg("LOGIN" && user && password)
  end if
end

on fuseRegister update
  global gChosenRegion, gLoginPw, gMySex
  if (field("charactername_field")).length = 0 then
    ShowAlert("NoNameSet")
    gotoFrame("regist")
    return 
  end if
  phoneN = fieldOrEmpty("phonenumber")
  gPhonenumberOk = 0
  if phoneN > 7 then
    gPhonenumberOk = 1
  end if
  passwd = fieldOrEmpty("password_field")
  if passwd.length < 3 then
    passwd = gLoginPw
  end if
  s = EMPTY
  s = s & "name=" & field("charactername_field") & RETURN
  s = s & "password=" & passwd & RETURN
  s = s & "email=" & fieldOrEmpty("email_field") & RETURN
  s = s & "figure=" & toOneLine(fieldOrEmpty("figure_field")) & RETURN
  s = s & "directMail=" & fieldOrEmpty("can_spam_field") & RETURN
  s = s & "birthday=" & fieldOrEmpty("birthday_field") & RETURN
  s = s & "phonenumber=" & fieldOrEmpty("phonenumber") & RETURN
  s = s & "customData=" & fieldOrEmpty("persistantmessage_field") & RETURN
  s = s & "has_read_agreement=" & fieldOrEmpty("Agreement_field") & RETURN
  s = s & "sex=" & fieldOrEmpty("charactersex_field") & RETURN
  s = s & "country=" & fieldOrEmpty("countryname") & RETURN
  if gChosenRegion = VOID then
    s = s & "region=0"
  else
    s = s & "region=" & gChosenRegion
  end if
  gMySex = member("charactersex_field").text
  if the movieName contains "cr_entry" then
    s = s & "crossroads=1" & RETURN
  end if
  put field("charactername_field") into field "character_info_name"
  put field("persistantmessage_field") into field "character_info_desc"
  if voidp(update) or update = 0 then
    sendEPFuseMsg("REGISTER" && s)
  else
    sendEPFuseMsg("UPDATE" && s)
  end if
end

on toOneLine fcont
  put fcont && "<-- FCONT ORIGINAL"
  tmp = EMPTY
  put the number of lines in fcont && "<--- NUMBER OF LINES"
  repeat with c = 1 to the number of lines in fcont
    tmp = tmp & fcont.line[c]
  end repeat
  put fcont && "<--- FCONT"
  put tmp && "<--- TMP"
  return tmp
end

on fieldOrEmpty fname
  if getmemnum(fname) < 1 then
    return EMPTY
  else
    return field(getmemnum(fname))
  end if
end

on fuseRetrieveInfo user, password
  sendEPFuseMsg("INFORETRIEVE" && user && password)
end

on EnterpriseMessagehandler
  DefaultMessageHandler()
end

on DefaultMessageHandler
  global contentChunk, lastContent
  if gConnectionInstance = 0 then
    return 
  end if
  newMessage = GetNetMessage(gConnectionInstance)
  errCode = getaProp(newMessage, #errorCode)
  content = getaProp(newMessage, #content)
  gConnectionOk = 1
  if errCode <> 0 then
    goToHotel()
    return 
  end if
  if stringp(content) then
    if not (content contains "##") then
      if voidp(lastContent) then
        lastContent = EMPTY
      end if
      lastContent = lastContent & content
      return 
    end if
    if not voidp(lastContent) then
      content = lastContent & content
    end if
    contentChunk = EMPTY
    contentArray = []
    the itemDelimiter = "##"
    b = 0
    if not (char content.length - 2 to content.length of content contains "##") then
      b = 1
      put "last item not ##"
      put char content.length - 2 to content.length of content
    end if
    lastContent = EMPTY
    n = the number of items in content
    repeat with i = 1 to n
      if i < n or b = 0 then
        add(contentArray, item i of content)
        next repeat
      end if
      if b = 1 and i = n then
        lastContent = item i of content
      end if
    end repeat
    the itemDelimiter = ","
    repeat with i = 1 to count(contentArray)
      handleMessageContent(getAt(contentArray, i))
      if gConnectionShouldBeKilled = 1 then
        return 
      end if
    end repeat
  end if
end

on moveUser user, currentMobilX, currentMobilY, moveToMobilX, moveToMobilY
  sendSprite(getUserSprite(gAvatarManager, user), #updateposition, user, currentMobilX, currentMobilY, moveToMobilX, moveToMobilY)
end

on updateChatWindow user, message
  sendSprite(84, #addLine, user, message)
  createBalloon(user, message)
end

on createAvatar user, figure, locX, locY, locHeight, Custom, custom2
  createFuseObject(user, getPlayerClass(), figure, locX, locY, locHeight, [1, 1, 1], VOID, Custom, custom2)
end

on handleMessageContent content
  global gLastStatusOK, availablePuppetSpr, RC4, gKryptausOn, gUserSprites, gMyName, gpObjects, gGameFrame, gWorldType
  if not stringp(content) or content.length <= 1 then
    return 
  end if
  firstline = line 1 of content
  if the runMode = "author" then
    put content
  end if
  if firstline contains "STATUS" then
    st = the ticks
    if voidp(gLastStatusOK) or the ticks - gLastStatusOK > 25 * 60 then
      sendFuseMsg("STATUSOK")
      gLastStatusOK = the ticks
    end if
    repeat with i = 2 to the number of lines in content
      the itemDelimiter = "/"
      ln = line i of content
      if ln.length > 2 then
        if not (char 1 of ln = "*") then
          itemsCount = the number of items in ln
          user = doSpecialCharConversion(word 1 of item 1 of ln)
          locParam = word 2 of item 1 of ln
          the itemDelimiter = ","
          currentMobilX = integer(item 1 of locParam)
          currentMobilY = integer(item 2 of locParam)
          currentMobilHeight = integer(item 3 of locParam)
          dirHead = integer(item 4 of locParam)
          dirBody = integer(item 5 of locParam)
          moved = 0
          objectSpr = getObjectSprite(user)
          if objectSpr > 0 then
            sendSprite(objectSpr, #initiateForSync)
            if not voidp(currentMobilX) and not voidp(currentMobilY) then
              sendSprite(objectSpr, #setLocAndDir, currentMobilX, currentMobilY, currentMobilHeight, dirHead, dirBody)
            end if
            repeat with j = 2 to itemsCount
              the itemDelimiter = "/"
              parseItem = item j of ln
              sendSprite(objectSpr, symbol("fuseAction_" & word 1 of parseItem), parseItem)
              if gConnectionShouldBeKilled = 1 then
                return 
              end if
            end repeat
          else
            put "STATUS for nonexistent user!", user
          end if
          next repeat
        end if
        handleActiveObjects(ln)
      end if
    end repeat
    if objectp(hiliter) then
      hiliteExitframe(hiliter)
    end if
  else
    if firstline contains "CHAT" then
      user = word 1 of line 2 of content
      message = word 2 to the number of words in line 2 of content of line 2 of content
      createBalloon(user, message, #normal)
    else
      if firstline contains "SHOUT" then
        user = word 1 of line 2 of content
        message = word 2 to the number of words in line 2 of content of line 2 of content
        createBalloon(user, message, #shout)
      else
        if firstline contains "WHISPER" then
          user = word 1 of line 2 of content
          message = word 2 to the number of words in line 2 of content of line 2 of content
          createBalloon(user, message, #whisper)
        else
          if firstline contains "LOGOUT" then
            userName = doSpecialCharConversion(word 1 of line 2 of content)
            put "LOGOUT", userName, getObjectSprite(userName)
            put "before", availablePuppetSpr.count
            sendSprite(getObjectSprite(userName), #die)
            put "after", availablePuppetSpr.count
          else
            if firstline contains "HELLO" then
              put firstline
              gKryptausOn = 0
              sendFuseMsg("VERSIONCHECK" && field("versionid"))
              sendFuseMsg("CLIENTIP" && GetNetAddressCookie(gConnectionInstance, 1))
            else
              if firstline contains "ENCRYPTION_ON" then
                gKryptausOn = #waiting
              else
                if firstline contains "ENCRYPTION_OFF" then
                  gKryptausOn = 0
                else
                  if firstline contains "SECRET_KEY" then
                    decodedKey = secretDecode(line 2 of content)
                    RC4 = new(script("RC4"))
                    RC4.setKey(decodedKey)
                    if gKryptausOn = #waiting then
                      gKryptausOn = 1
                      put "Encryption enabled...!"
                    else
                      gKryptausOn = 0
                      put "Encryption disabled...!"
                    end if
                    sendFuseMsg("KEYENCRYPTED" && decodedKey)
                    gConnectionsSecured = 1
                  else
                    if firstline contains "ERROR" then
                      put content
                      if content contains "not move there" then
                      else
                        if content contains "inproper" and content contains "WARNING" = 0 then
                          ShowAlert(content.line[2])
                        else
                          if content contains "user already" then
                            ShowAlert("NameAlreadyUse")
                            repeat with e = 1 to 99
                              sprite(e).visible = 1
                            end repeat
                            go(1)
                          else
                            if content contains "incorrect flat password" or content contains "password required" then
                              flatPasswordIncorrect()
                            else
                              if content contains "login in" then
                                ShowAlert("WrongPassword")
                                repeat with e = 1 to 99
                                  sprite(e).visible = 1
                                end repeat
                                go(1)
                              else
                                if content contains "Version not correct" then
                                  ShowAlert("Old client version, please reload." & RETURN & "Clear browser's cache if necessary.")
                                else
                                  if content contains "the room owner" then
                                    ShowAlert(content.line[2])
                                  else
                                    put "Error message:" && content
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    else
                      if firstline contains "USERS" then
                        content = doSpecialCharConversion(content)
                        the itemDelimiter = TAB
                        repeat with i = 2 to the number of lines in content
                          ln = item 1 of line i of content
                          if the number of words in ln <> 0 then
                            user = word 1 of ln
                            figure = word 2 of ln
                            locX = integer(word 3 of ln)
                            locY = integer(word 4 of ln)
                            locHeight = integer(word 5 of ln)
                            if word ln.word.count of ln starts "ch=" then
                              Custom = doSpecialCharConversion(word 6 to ln.word.count - 1 of ln)
                              swimsuit = word ln.word.count of ln
                            else
                              Custom = doSpecialCharConversion(word 6 to the number of words in ln of ln)
                              swimsuit = EMPTY
                            end if
                            if item 2 of line i of content <> EMPTY then
                              score = word 1 of item 2 of line i of content
                              ranking = word 2 of item 2 of line i of content
                              Custom = Custom & RETURN & RETURN & "pisteet:" & score & " sijoitus:" & ranking & "."
                            end if
                            if not (the movieName contains "pellehyppy") then
                              createAvatar(user, figure, locX, locY, locHeight, Custom)
                              next repeat
                            end if
                            if gpObjects.findPos(user) then
                              sendSprite(gpObjects.getProp(user), #updateSwimSuit, figure, swimsuit)
                              next repeat
                            end if
                            createAvatar(user, figure, locX, locY, locHeight, Custom, swimsuit)
                          end if
                        end repeat
                        the itemDelimiter = ","
                      else
                        if firstline contains "USEROBJECT" then
                          the itemDelimiter = "="
                          content = doSpecialCharConversion(content)
                          repeat with i = 2 to the number of lines in content
                            ln = line i of content
                            sfield = item 1 of ln
                            sdata = item 2 of ln
                            put sfield, sdata
                            if sfield = "name" then
                              put sdata into field "loginname_locked"
                            end if
                            if the number of member sfield > 0 and sfield.length > 0 then
                              if sdata <> "null" then
                                put doSpecialCharConversion(sdata) into field sfield
                                next repeat
                              end if
                              put EMPTY into field sfield
                            end if
                          end repeat
                          the itemDelimiter = ","
                          gotoFrame("change1")
                        else
                          if firstline contains "SYSTEMBROADCAST" then
                            ShowAlert("MessageFromAdmin", line 2 of content)
                          else
                            if firstline contains "SHOWPROGRAM" then
                              commandLine = line 2 of content
                              spr = getaProp(gpShowSprites, word 1 of commandLine)
                              if spr > 0 then
                                sendSprite(spr, symbol("fuseShow_" & word 2 of commandLine), word 3 to the number of words in commandLine of commandLine)
                              end if
                            else
                              if firstline contains "TRIGGER" then
                                if content contains "openSplashKiosk" then
                                  openSplashKiosk()
                                end if
                              else
                                if firstline contains "DOOR_IN" then
                                  tItemDelim = the itemDelimiter
                                  the itemDelimiter = "/"
                                  tDoorID = content.line[2].item[1]
                                  tUsername = content.line[2].item[2]
                                  tDoorType = content.line[2].item[3]
                                  the itemDelimiter = tItemDelim
                                  tDoorObj = sprite(gpObjects[tDoorType & tDoorID]).scriptInstanceList[1]
                                  tDoorObj.animate(VOID, #in)
                                  if gMyName = tUsername then
                                    tDoorObj.prepareToKick(tUsername)
                                  end if
                                else
                                  if firstline contains "DOOR_OUT" then
                                    tItemDelim = the itemDelimiter
                                    the itemDelimiter = "/"
                                    tDoorID = content.line[2].item[1]
                                    tUsername = content.line[2].item[2]
                                    tDoorType = content.line[2].item[3]
                                    the itemDelimiter = tItemDelim
                                    tDoorObj = sprite(gpObjects[tDoorType & tDoorID]).scriptInstanceList[1]
                                    tDoorObj.animate(VOID, #out)
                                  else
                                    if firstline contains "HEIGHTMAP" then
                                      loadHeightMap(line 2 to the number of lines in content of content)
                                    else
                                      if firstline contains " OBJECTS" then
                                        content = doSpecialCharConversion(content)
                                        type = the last word in firstline
                                        AddStatistic(the movieName, type)
                                        if not (the movieName contains "private") and type contains "model_" then
                                          goMovie("gf_private", type)
                                          Init()
                                        end if
                                        sprMan_clearAll()
                                        gUserSprites = [:]
                                        gpObjects = [:]
                                        gWorldType = type
                                        gotoFrame(type)
                                        checkOffsets()
                                        clickedUrl = 0
                                        sprite(99).visible = 1
                                        repeat with i = 2 to the number of lines in content
                                          ln = line i of content
                                          name = word 1 of ln
                                          objectClass = word 2 of ln
                                          if not (objectClass contains "stair") and not (objectClass contains "ignore") then
                                            locX = integer(word 3 of ln)
                                            locY = integer(word 4 of ln)
                                            locHeight = integer(word 5 of ln)
                                            direction = VOID
                                            dimensions = VOID
                                            if the number of words in ln = 6 then
                                              dir = integer(word 6 of ln)
                                              direction = [dir, dir, dir]
                                            else
                                              width = integer(word 6 of ln)
                                              height = integer(word 7 of ln)
                                              locX = locX + width - 1
                                              locY = locY + height - 1
                                              dimensions = [width, height]
                                            end if
                                            createFuseObject(name, objectClass, "0,0,0", locX, locY, locHeight, direction, dimensions)
                                            if rollover(2) and the mouseDown and clickedUrl <> 1 then
                                              clickedUrl = 1
                                              sendSprite(2, #mouseDown)
                                            end if
                                          end if
                                          if i mod 10 = 0 then
                                            sendFuseMsg("STATUSOK")
                                          end if
                                        end repeat
                                        if getmemnum(gWorldType & ".firstAction") > 0 then
                                          sendFuseMsg(field(gWorldType & ".firstAction"))
                                        end if
                                        updateStage()
                                        sendEPFuseMsg("GETADFORME general")
                                      else
                                        handleSpecialMessages(content)
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on getZShift memberPrefix, partName, direction
  global gzShifts
  if voidp(gzShifts) or the runMode = "Author" then
    gzShifts = [:]
  end if
  if not listp(getaProp(gzShifts, memberPrefix & "_" & partName)) then
    if getmemnum(memberPrefix & "_" & partName & ".zshift") > 0 then
      shiftData = the text of field getmemnum(memberPrefix & "_" & partName & ".zshift")
    else
      return 0
    end if
    l = []
    repeat with i = 1 to the number of lines in shiftData
      add(l, integer(line i of shiftData))
    end repeat
    addProp(gzShifts, memberPrefix & "_" & partName, l)
  end if
  l = getaProp(gzShifts, memberPrefix & "_" & partName)
  if voidp(direction) then
    return getAt(l, 1)
  else
    if count(l) > direction then
      return getAt(l, direction + 1)
    else
      return getAt(l, 1)
    end if
  end if
end

on getObjectSprite name
  global gpObjects
  return getaProp(gpObjects, name)
end
