on exitFrame
  global gEPConnectionOk, gEPConnectionsSecured, gGoTo, gLoginName, gLoginPw
  if gEPConnectionOk = 0 or gEPConnectionsSecured = 0 then
    go(marker(0))
  else
    if gGoTo = "login" then
      epLogin(gLoginName, gLoginPw)
      go(the frame + 1)
    else
      if gGoTo = "register" then
        startRegistration()
      else
        if gGoTo = "forgottenPassword" then
          gotoFrame("sendMyPassword")
        end if
      end if
    end if
  end if
end
