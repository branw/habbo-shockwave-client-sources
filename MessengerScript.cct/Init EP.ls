on exitFrame me
  global gEPIp, gEPPort, gpUiButtons, gStartLoadingTime, gEndLoadingTime, gHabboRep, gCountryPrefix, gKusetus
  t1 = gStartLoadingTime
  t2 = gEndLoadingTime
  clearGlobals()
  startTimer()
  gKusetus = gKusetus & "fc=" & random(10) & "/"
  gKusetus = gKusetus & "hd=" & random(10) & "/"
  gKusetus = gKusetus & "sh=" & random(10) & "/"
  gKusetus = gKusetus & "sl=" & random(10) & "/"
  gKusetus = gKusetus & "sd=" & random(10) & "/"
  gKusetus = gKusetus & "rh=" & random(10) & "/"
  gKusetus = gKusetus & "rs=" & random(10) & "/"
  gKusetus = gKusetus & "bd=" & random(10) & "/"
  gKusetus = gKusetus & "hr=" & random(10) & "/"
  if the movieName contains "habbo_entry" then
    gCountryPrefix = "gf"
  else
    if the movieName contains "habbo_ch_entry" then
      gCountryPrefix = "ch"
    end if
  end if
  gStartLoadingTime = t1
  gEndLoadingTime = t2
  if the movieName contains "habbo_entry" then
    gEPIp = "fuse-sun2.kultakalaglobal.com"
    gEPPort = 37120
  else
    if the movieName contains "habbo_ch_entry" then
      gEPIp = "213.55.128.132"
      gEPPort = 37005
    end if
  end if
  gEPIp = "fuse.taivas.com"
  gEPPort = 37000
  if the runMode <> "Author" then
    gHabboRep = getNetText("http://habborep.magenta.net/serverid.txt")
    hostInfo = externalParamValue("swText")
    if not voidp(hostInfo) and length(hostInfo) > 8 then
      gEPIp = char 1 to offset(":", hostInfo) - 1 of hostInfo
      gEPPort = integer(char offset(":", hostInfo) + 1 to length(hostInfo) of hostInfo)
    else
    end if
  end if
  if the optionDown then
    the alertHook = 0
    alert(gEPIp & " --- " & gEPPort)
  end if
  tellStreamStatus(0)
  gpUiButtons = [:]
  put " " into field "character_info_name"
  put " " into field "character_info_desc"
  member("habbo_credits").text = "[Loading credits]"
  member("credits_amount_e").text = "[Loading credits]"
  ResetNavigationWindow()
end
