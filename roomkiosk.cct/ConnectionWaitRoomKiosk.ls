on exitFrame
  global gConnectionOk, gGoTo, oldPassword, gConnectionsSecured, gFlatLetIn, gLoginName, gLoginPw, gChosenFlatId, gFlatWaitStart, gConnectionInstance, gLogin, gPopUpContext2, gChosenFlatDoorMode
  if gConnectionOk = 0 or gConnectionsSecured = 0 then
    gLogin = 0
  else
    if gLogin = 0 then
      gLogin = 1
      fuseLogin(gLoginName, gLoginPw, 1)
      if gChosenFlatDoorMode <> "x" then
        put EMPTY into field "flatpassword.nav"
      end if
      put "TRYFLAT /" & gChosenFlatId & "/" & field("flatpassword.nav")
      sendFuseMsg("TRYFLAT /" & gChosenFlatId & "/" & field("flatpassword.nav"))
    end if
  end if
end
