on exitFrame
  global gConnectionOk, gGoTo, gConnectionsSecured, gChosenFlat
  if gConnectionOk = 0 or gConnectionsSecured = 0 then
    go(#loop)
  else
    put gGoTo
    if gGoTo = "one_room" then
      fuseLogin(field("loginname"), field("loginpw"))
      sendFuseMsg("GOTOFLAT /" & gChosenFlat)
    end if
    gotoFrame(gGoTo)
  end if
end
