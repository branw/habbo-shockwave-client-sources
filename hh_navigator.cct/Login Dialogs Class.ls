property pConnectionId, pTempPassword

on construct me
  pConnectionId = getVariable("connection.info.id")
  pTempPassword = []
  return 1
end

on deconstruct me
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return 1
end

on showLogin me
  getObject(#session).set(#userName, EMPTY)
  getObject(#session).set(#password, EMPTY)
  pTempPassword = []
  if createWindow(#login_a, "habbo_simple.window", 444, 100) then
    tWndObj = getWindow(#login_a)
    tWndObj.merge("login_a.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
  end if
  if createWindow(#login_b, "habbo_simple.window", 444, 230) then
    tWndObj = getWindow(#login_b)
    tWndObj.merge("login_b.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #keyDown)
    tWndObj.getElement("login_username").setFocus(1)
  end if
  return 1
end

on hideLogin me
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return 1
end

on tryLogin me
  if not windowExists(#login_b) then
    return error(me, "Window not found:" && #login_b, #tryLogin)
  end if
  tWndObj = getWindow(#login_b)
  tUserName = tWndObj.getElement("login_username").getText()
  tPassword = EMPTY
  repeat with tChar in pTempPassword
    put tChar after tPassword
  end repeat
  if tUserName = EMPTY then
    return 0
  end if
  if tPassword = EMPTY then
    return 0
  end if
  getObject(#session).set(#userName, tUserName)
  getObject(#session).set(#password, tPassword)
  tWndObj.getElement("login_ok").hide()
  tWndObj.getElement("login_connecting").setProperty(#blend, 100)
  tElem = tWndObj.getElement("login_forgotten")
  tElem.setProperty(#blend, 99)
  tElem.setProperty(#cursor, 0)
  tElem = getWindow(#login_a).getElement("login_createUser")
  tElem.setProperty(#blend, 99)
  tElem.setProperty(#cursor, 0)
  me.blinkConnection()
  getThread(#navigator).getComponent().updateState("connection")
  return 1
end

on blinkConnection me
  if not windowExists(#login_b) then
    return 0
  end if
  if timeoutExists(#login_blinker) then
    return 0
  end if
  tElem = getWindow(#login_b).getElement("login_connecting")
  if not tElem then
    return 0
  end if
  if getWindow(#login_b).getElement("login_ok").getProperty(#visible) = 1 then
    return 0
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return createTimeout(#login_blinker, 500, #blinkConnection, me.getID(), VOID, 1)
end

on showUserFound me
  if windowExists(#login_b) then
    getWindow(#login_b).unmerge()
  else
    createWindow(#login_b, "habbo_simple.window", 444, 230)
  end if
  tWndObj = getWindow(#login_b)
  tWndObj.merge("login_c.window")
  tTxt = tWndObj.getElement("login_c_welcome").getText()
  tTxt = tTxt && getObject(#session).get("user_name")
  tWndObj.getElement("login_c_welcome").setText(tTxt)
  if threadExists(#registration) then
    tBuffer = getThread(#registration).getComponent().createTemplateHuman("h", 3, "wave")
    tWndObj.getElement("login_preview").setProperty(#buffer, tBuffer)
    me.delay(800, #myHabboSmile)
  else
    me.hideLogin()
  end if
  return 1
end

on myHabboSmile me
  if threadExists(#registration) then
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "gest", "temp sml")
  end if
  me.delay(1200, #stopWaving)
end

on stopWaving me
  if threadExists(#registration) then
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "reset")
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "gest", "temp sml")
  end if
  if threadExists(#registration) then
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "remove")
  end if
  me.delay(400, #hideLogin)
end

on forgottenpw me
  if not createWindow(#login_b, "habbo_simple.window", 444, 230) then
    return 0
  end if
  getWindow(#login_b).merge("habbo_forgottenpw.window")
  getWindow(#login_b).registerProcedure(#eventProcForgottenpw, me.getID(), #mouseUp)
  if not connectionExists(pConnectionId) then
    getThread(#navigator).getComponent().updateState("connection")
  end if
  getThread(#navigator).getComponent().updateState("forgottenPassWord")
  return 1
end

on eventProcLogin me, tEvent, tSprID, tParam
  case tEvent of
    #mouseUp:
      case tSprID of
        "login_ok":
          me.tryLogin()
          return 1
        "login_createUser":
          if getWindow(#login_a).getElement(tSprID).getProperty(#blend) = 100 then
            if windowExists(#login_a) then
              removeWindow(#login_a)
            end if
            if windowExists(#login_b) then
              removeWindow(#login_b)
            end if
            executeMessage(#show_registration)
            return 1
          end if
        "login_forgotten":
          if getWindow(#login_b).getElement(tSprID).getProperty(#blend) = 100 then
            return me.forgottenpw()
          end if
      end case
    #keyDown:
      if the keyCode = 36 then
        me.tryLogin()
        return 1
      end if
      case tSprID of
        "login_password":
          case the keyCode of
            48:
              return 0
            49:
              return 1
            51:
              if pTempPassword.count > 0 then
                pTempPassword.deleteAt(pTempPassword.count)
              end if
            117:
              pTempPassword = []
            otherwise:
              tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
              tASCII = charToNum(the key)
              if tASCII > 31 and tASCII < 128 then
                if tValidKeys contains the key or tValidKeys = EMPTY then
                  if pTempPassword.count < getIntVariable("pass.length.max", 36) then
                    pTempPassword.append(the key)
                  end if
                end if
              end if
          end case
          tStr = EMPTY
          repeat with tChar in pTempPassword
            put "*" after tStr
          end repeat
          getWindow(#login_b).getElement(tSprID).setText(tStr)
          set the selStart to pTempPassword.count
          set the selEnd to pTempPassword.count
          return 1
      end case
  end case
  return 0
end

on eventProcForgottenpw me, tEvent, tSprID, tParm
  if tEvent = #mouseUp then
    case tSprID of
      "forgottenpw_back":
        getThread(#navigator).getComponent().updateState("login")
      "forgottenpw_emailpw":
        tName = getWindow(#login_b).getElement("forgottenpw_name").getText()
        tMail = getWindow(#login_b).getElement("forgottenpw_email").getText()
        if connectionExists(pConnectionId) then
          getConnection(pConnectionId).send(#info, "SEND_USERPASS_TO_EMAIL" && tName && tMail)
          removeConnection(pConnectionId)
        else
          error(me, "Couldn't find connection:" && pConnectionId, #eventProcForgottenpw)
        end if
        if not createWindow(#login_b, "habbo_simple.window", 444, 230) then
          return 0
        end if
        getWindow(#login_b).merge("habbo_forgotten2.window")
        getWindow(#login_b).registerProcedure(#eventProcForgottenpw, me.getID(), #mouseUp)
      "forgottenpw_ok":
        getThread(#navigator).getComponent().updateState("login")
    end case
  end if
end
