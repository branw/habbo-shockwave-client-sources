on doLogin
  global gLoginName, gLoginPw, gGoTo
  gLoginName = field("loginname")
  gLoginPw = field("loginpw")
  gGoTo = "login"
  gotoFrame("connectloop")
  EPLogon()
end

on list
  repeat with i = 136 to 202
    put i, sprite(i).member
  end repeat
end
