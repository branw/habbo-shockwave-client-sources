on exitFrame
  global gConnectionOk, gGoTo, oldPassword, gConnectionsSecured
  if gConnectionOk = 0 or gConnectionsSecured = 0 then
    go(#loop)
  else
    if gGoTo = "scene_transition" then
      Init()
      fuseLogin(field("loginname"), field("loginpw"))
      gotoFrame("scene")
    else
      if gGoTo = "maja" then
        Init()
        member("gameinfo_1").text = EMPTY
        member("gameinfo_2").text = EMPTY
        fuseLogin(field("loginname"), field("loginpw"))
        gotoFrame(gGoTo)
      else
        if gGoTo = "change1" then
          oldPassword = field("loginname")
          fuseRetrieveInfo(field("loginname"), field("loginpw"))
          gotoFrame("change1wait")
        else
          if gGoTo = "register" then
            fuseRegister()
            Init()
            fuseLogin(field("loginname"), field("loginpw"))
            gGoTo = "scene_transition"
            gotoFrame("connect_ok")
          else
            if gGoTo = "registerUpdate" then
              fuseRegister(1)
              gotoFrame(gGoTo)
            end if
          end if
        end if
      end if
    end if
  end if
end
