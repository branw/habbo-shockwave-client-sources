property context
global gpSplashForm, gpSplashOk, gpSplashSubmitted

on mouseUp me
  gpSplashForm = [:]
  gpSplashOk = 1
  sendAllSprites(#checkValue)
  if gpSplashOk = 0 then
    goContext("sp_error", context)
    return 
  else
    RET = "&"
    s = RET & EMPTY
    gpSplashSubmitted = 1
    repeat with i = 1 to count(gpSplashForm)
      s = s & getPropAt(gpSplashForm, i) & "=" & getAt(gpSplashForm, i)
      s = s & RET
    end repeat
    repeat with i = 1 to s.length
      if charToNum(char i of s) > 128 then
        put "*" into char i of s
      end if
    end repeat
    put s
    s = s & "country=UK" & RET
    s = s & "referrer=Habbo" & RET
    sendEPFuseMsg("SPLASH_POST" & RETURN & s)
    put s
    goContext("sp_thanks", context)
  end if
end
