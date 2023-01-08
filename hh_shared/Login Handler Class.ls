on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handleDisconnect me, tMsg
  error(me, "Connection was disconnected:" && tMsg.connection.getID(), #handleMsg)
  return me.getInterface().showDisconnect()
end

on handleHello me, tMsg
  tPairsCount = tMsg.connection.GetIntFrom()
  if integerp(tPairsCount) then
    if tPairsCount > 0 then
      repeat with i = 1 to tPairsCount
        tid = tMsg.connection.GetIntFrom()
        tValue = tMsg.connection.GetIntFrom()
        tSession = getObject(#session)
        case tid of
          0:
            tSession.set("conf_coppa", tValue > 0)
          1:
            tSession.set("conf_voucher", tValue > 0)
          2:
            tSession.set("conf_parent_email_request", tValue > 0)
          3:
            tSession.set("conf_parent_email_request_reregistration", tValue > 0)
          4:
            tSession.set("conf_allow_direct_mail", tValue > 0)
        end case
      end repeat
    end if
  end if
  tMsg.connection.send("CHK_VERSION", [#short: getIntVariable("client.version.id")])
end

on handleSecretKey me, tMsg
  tKey = secretDecode(tMsg.content)
  tMsg.connection.setDecoder(createObject(#temp, getClassVariable("connection.decoder.class")))
  tMsg.connection.getDecoder().setKey(tKey)
  tMsg.connection.setEncryption(1)
  if objectExists("nav_problem_obj") then
    removeObject("nav_problem_obj")
  end if
  if me.getComponent().isOkToLogin() then
    tUserName = getObject(#session).get(#userName)
    tPassword = getObject(#session).get(#password)
    if not stringp(tUserName) or not stringp(tPassword) then
      return removeConnection(tMsg.connection.getID())
    end if
    if tUserName = EMPTY or tPassword = EMPTY then
      return removeConnection(tMsg.connection.getID())
    end if
    tMsg.connection.send("SET_UID", [#string: getMachineID()])
    tMsg.connection.send("TRY_LOGIN", [#string: tUserName, #string: tPassword])
  end if
end

on handleRegistrationOK me, tMsg
  tUserName = getObject(#session).get(#userName)
  tPassword = getObject(#session).get(#password)
  if not stringp(tUserName) or not stringp(tPassword) then
    return removeConnection(tMsg.connection.getID())
  end if
  if tUserName = EMPTY or tPassword = EMPTY then
    return removeConnection(tMsg.connection.getID())
  end if
  tMsg.connection.send("SET_UID", [#string: getMachineID()])
  tMsg.connection.send("TRY_LOGIN", [#string: tUserName, #string: tPassword])
end

on handleLoginOK me, tMsg
  tMsg.connection.send("GET_INFO")
  tMsg.connection.send("GET_CREDITS")
  tMsg.connection.send("GETAVAILABLEBADGES")
end

on handleUserObj me, tMsg
  tuser = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  repeat with i = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[i]
    tuser[tLine.item[1]] = tLine.item[2..tLine.item.count]
  end repeat
  if not voidp(tuser["sex"]) then
    if tuser["sex"] contains "F" or tuser["sex"] contains "f" then
      tuser["sex"] = "F"
    else
      tuser["sex"] = "M"
    end if
  end if
  if objectExists("Figure_System") then
    tuser["figure"] = getObject("Figure_System").parseFigure(tuser["figure"], tuser["sex"], "user", "USEROBJECT")
  end if
  the itemDelimiter = tDelim
  tSession = getObject(#session)
  repeat with i = 1 to tuser.count
    tSession.set("user_" & tuser.getPropAt(i), tuser[i])
  end repeat
  tSession.set(#userName, tSession.get("user_name"))
  tSession.set("user_password", tSession.get(#password))
  executeMessage(#updateFigureData)
  if getObject(#session).exists("user_logged") then
    return 
  else
    getObject(#session).set("user_logged", 1)
  end if
  if getIntVariable("quickLogin", 0) and the runMode contains "Author" then
    setPref(getVariable("fuse.project.id", "fusepref"), string([getObject(#session).get(#userName), getObject(#session).get(#password)]))
    me.getInterface().hideLogin()
  else
    me.getInterface().showUserFound()
  end if
  executeMessage(#userlogin, "userLogin")
end

on handleUserBanned me, tMsg
  tBanMsg = getText("Alert_YouAreBanned") & RETURN & tMsg.content
  executeMessage(#openGeneralDialog, #ban, [#id: "BannWarning", #title: "Alert_YouAreBanned_T", #msg: tBanMsg, #modal: 1])
  removeConnection(tMsg.connection.getID())
end

on handleEPSnotify me, tMsg
  ttype = EMPTY
  tdata = EMPTY
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  repeat with f = 1 to tMsg.content.line.count
    tProp = tMsg.content.line[f].item[1]
    tDesc = tMsg.content.line[f].item[2]
    case tProp of
      "t":
        ttype = integer(tDesc)
      "p":
        tdata = tDesc
    end case
  end repeat
  the itemDelimiter = tDelim
  case ttype of
    580:
      if not createObject("lang_test", "CLangTest") then
        return error(me, "Failed to init lang tester!", #handle_eps_notify)
      else
        return getObject("lang_test").setWord(tdata)
      end if
  end case
  executeMessage(#notify, ttype, tdata, tMsg.connection.getID())
end

on handleSystemBroadcast me, tMsg
  tMsg = tMsg[#content]
  tMsg = replaceChunks(tMsg, "\r", RETURN)
  tMsg = replaceChunks(tMsg, "<br>", RETURN)
  executeMessage(#alert, [#msg: tMsg])
  the keyboardFocusSprite = 0
end

on handleCheckSum me, tMsg
  getObject(#session).set("user_checksum", tMsg.content)
end

on handleAvailableBadges me, tMsg
  tBadgeList = []
  tNumber = tMsg.connection.GetIntFrom()
  repeat with i = 1 to tNumber
    tBadgeID = tMsg.connection.GetStrFrom()
    tBadgeList.add(tBadgeID)
  end repeat
  tChosenBadge = tMsg.connection.GetIntFrom()
  tVisible = tMsg.connection.GetIntFrom()
  tChosenBadge = tChosenBadge + 1
  if tChosenBadge < 1 then
    tChosenBadge = 1
  end if
  getObject("session").set("available_badges", tBadgeList)
  getObject("session").set("chosen_badge_index", tChosenBadge)
  getObject("session").set("badge_visible", tVisible)
end

on handleRights me, tMsg
  tSession = getObject(#session)
  tSession.set("user_rights", [])
  tRights = tSession.get("user_rights")
  tPrivilegeFound = 1
  repeat while tPrivilegeFound = 1
    tPrivilege = tMsg.connection.GetStrFrom()
    if tPrivilege = VOID or tPrivilege = EMPTY then
      tPrivilegeFound = 0
      next repeat
    end if
    tRights.add(tPrivilege)
  end repeat
  return 1
end

on handleErr me, tMsg
  error(me, "Error from server:" && tMsg.content, #handle_error)
  if tMsg.content contains "login incorrect" then
    removeConnection(tMsg.connection.getID())
    me.getComponent().setaProp(#pOkToLogin, 0)
    if getObject(#session).exists("failed_password") then
      openNetPage(getText("login_forgottenPassword_url"))
      me.getInterface().showLogin()
      return 0
    else
      getObject(#session).set("failed_password", 1)
      me.getInterface().showLogin()
      executeMessage(#alert, [#msg: "Alert_WrongNameOrPassword"])
    end if
  else
    if tMsg.content contains "mod_warn" then
      tDelim = the itemDelimiter
      the itemDelimiter = "/"
      tTextStr = tMsg.content.item[2..tMsg.content.item.count]
      the itemDelimiter = tDelim
      executeMessage(#alert, [#title: "alert_warning", #msg: tTextStr])
    else
      if tMsg.content contains "Version not correct" then
        executeMessage(#alert, [#msg: "Old client version!!!"])
      end if
    end if
  end if
  return 1
end

on handleModAlert me, tMsg
  if not voidp(tMsg.content) then
    executeMessage(#alert, [#title: "alert_moderator_warning", #msg: tMsg.content])
  else
    error(me, "Error in moderator alert:" && tMsg.content, #handleModAlert)
  end if
end

on handleAdv me, tMsg
  tStr = tMsg.content
  tTxt = replaceChunks(tStr.line[4], "<br>", RETURN)
  tTxt = replaceChunks(tTxt, "\r", RETURN)
  tid = tStr.line[1]
  tURL = tStr.line[2]
  tTyp = tStr.line[3]
  tLnk = tStr.line[5]
  if tURL = EMPTY then
    return 0
  end if
  tMemNum = queueDownload(tURL, "advertisement", #bitmap, 1)
  tSession = getObject(#session)
  tSession.set("ad_id", tid)
  tSession.set("ad_url", tURL)
  tSession.set("ad_text", tTxt)
  tSession.set("ad_type", tTyp)
  tSession.set("ad_memnum", tMemNum)
  if tLnk = EMPTY then
    tSession.set("ad_link", 0)
  else
    tSession.set("ad_link", tLnk)
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(-1, #handleDisconnect)
  tMsgs.setaProp(0, #handleHello)
  tMsgs.setaProp(1, #handleSecretKey)
  tMsgs.setaProp(2, #handleRights)
  tMsgs.setaProp(3, #handleLoginOK)
  tMsgs.setaProp(5, #handleUserObj)
  tMsgs.setaProp(11, #handleAdv)
  tMsgs.setaProp(33, #handleErr)
  tMsgs.setaProp(35, #handleUserBanned)
  tMsgs.setaProp(51, #handleRegistrationOK)
  tMsgs.setaProp(52, #handleEPSnotify)
  tMsgs.setaProp(139, #handleSystemBroadcast)
  tMsgs.setaProp(141, #handleCheckSum)
  tMsgs.setaProp(161, #handleModAlert)
  tMsgs.setaProp(229, #handleAvailableBadges)
  tCmds = [:]
  tCmds.setaProp("TRY_LOGIN", 4)
  tCmds.setaProp("CHK_VERSION", 5)
  tCmds.setaProp("SET_UID", 6)
  tCmds.setaProp("GET_INFO", 7)
  tCmds.setaProp("GET_CREDITS", 8)
  tCmds.setaProp("GETAVAILABLEBADGES", 157)
  tCmds.setaProp("GET_PASSWORD", 47)
  tCmds.setaProp("LANGCHECK", 58)
  tConn = getVariable("connection.info.id", #info)
  if tBool then
    registerListener(tConn, me.getID(), tMsgs)
    registerCommands(tConn, me.getID(), tCmds)
  else
    unregisterListener(tConn, me.getID(), tMsgs)
    unregisterCommands(tConn, me.getID(), tCmds)
  end if
  return 1
end
