property loginpw, loginpwshow, isLoginField
global loginButton, gChosenFlatId

on beginSprite me
  put EMPTY into field loginpw
  put EMPTY into field loginpwshow
end

on keyDown me
  global gFlatWaitStart, gFlatLetIn, gChosenFlatDoorMode
  if (field(loginpw)).length <> (field(loginpwshow)).length then
    put EMPTY into field loginpw
    put EMPTY into field loginpwshow
  end if
  put the key
  if the keyCode = 36 and isLoginField then
    doLogin()
    return 
  else
    if the keyCode = 36 and loginpw contains "flatpassword" then
      gFlatLetIn = 0
      member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
      gFlatWaitStart = the milliSeconds
      gChosenFlatDoorMode = "x"
      GoToFlatWithNavi(gChosenFlatId)
      return 
    end if
  end if
  if the keyCode = 48 then
    pass()
  end if
  if the keyCode = 51 then
    put EMPTY into field loginpwshow
    put EMPTY into field loginpw
  else
    if the keyCode <> 48 and the keyCode <> 49 then
      if (field(loginpw)).length >= 9 then
        return 
      end if
      k = the key
      put k after field loginpw
      put "*" after field loginpwshow
    end if
  end if
  put line 1 of field loginpwshow into field loginpwshow
  put line 1 of field loginpw into field loginpw
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #loginpw, [#comment: "Salasanakentt�", #format: #string, #default: "loginpw"])
  addProp(pList, #loginpwshow, [#comment: "N�kyv� kentt�", #format: #string, #default: "loginpwshow"])
  addProp(pList, #isLoginField, [#comment: "Is login field", #format: #boolean, #default: 0])
  return pList
end
