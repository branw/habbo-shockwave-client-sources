property pState, pMode, pCountryMan, pWarningShown
global figurePartList, figureColorList, MyfigurePartList, MyfigureColorList

on new me, tMode, tState
  if tState = VOID then
    pState = 1
  else
    pState = tState
  end if
  pMode = tMode
  pCountryMan = new(script(getmemnum("Country Manager Class")))
  me.init()
  put EMPTY into field getmemnum("password_field")
  put EMPTY into field getmemnum("passwordShow_field")
  put EMPTY into field getmemnum("password_field2")
  put EMPTY into field getmemnum("passwordcheck_field")
  return me
end

on init me
  global figurePartList, figureColorList, canSpam
  if pMode = #register then
    figurePartList = [:]
    figurePartList = [#sd: "sd=001", #hr: "hr=001", #hd: "hd=001", #ey: "ey=001", #fc: "fc=001", #bd: "bd=001", #lh: "lh=001", #rh: "rh=001", #ch: "ch=001", #ls: "ls=001", #rs: "rs=001", #lg: "lg=001", #sh: "sh=001"]
    figureColorList = [:]
    figureColorList = [#sd: "0", #hr: "0", #hd: "0", #ey: "0", #fc: "0", #bd: "0", #lh: "0", #rh: "0", #ch: "0", #ls: "0", #rs: "0", #lg: "0", #sh: "0"]
    canSpam = 1
    put canSpam into field getmemnum("can_spam_field")
    go("regist1")
  else
    if pMode = #update then
      pWarningShown = 0
      tBirthday = field(getmemnum("birthday_field"))
      the itemDelimiter = "."
      tDay = value(tBirthday.item[1])
      tMonth = value(tBirthday.item[2])
      tYear = value(tBirthday.item[3])
      BirthdayOK = 1
      if tDay < 1 or tDay > 31 then
        BirthdayOK = 0
      end if
      if tMonth < 1 or tMonth > 12 then
        BirthdayOK = 0
      end if
      if tYear < 1910 or tYear > 1999 then
        BirthdayOK = 0
      end if
      if BirthdayOK then
        put tDay into field getmemnum("birthday_field.day")
        put tMonth into field getmemnum("birthday_field.month")
        put tYear into field getmemnum("birthday_field.year")
      end if
      if pState = 1 then
        go("change1")
        sendAllSprites(#initMeForChange)
        sendAllSprites(#mobileSexChange, member(getmemnum("charactersex_field")).text)
      else
        me.setState(pState)
      end if
    end if
  end if
end

on setState me, tState
  tOldState = pState
  case pState of
    1:
      if tState <> 0 then
        sendAllSprites(#getMyFigureData)
        me.getFigureResults()
      end if
    2:
      if not (pMode = #register and tState = 1) then
        if me.passwordCheck() = 0 then
          return 
        end if
      end if
      if tState > pState then
        if me.BirthdayANDemailcheck() = 0 then
          return 
        end if
        if me.agreementCheck() = 0 then
          return 
        end if
      end if
    3:
      if tState > pState then
        if me.countryCheck() = 0 then
          return 
        end if
      end if
  end case
  pState = tState
  if pState < 4 and pState > 0 then
    f = "regist" & pState
    if pState = 1 and pMode = #update then
      f = "change1"
    end if
    if label(f) > 0 then
      go(f)
      if pState = 1 then
        sendAllSprites(#initMeForChange)
      end if
    end if
    if pState = 2 then
      if pMode = #update and not pWarningShown then
        tDialog = new(script("PopUp Context Class"), 2130000000, 851, 865, point(0, 0))
        tDialog.displayFrame("password_alert")
        pWarningShown = 1
      end if
    end if
  else
    if pState = 0 then
      case pMode of
        #update:
          go("hotel")
        #register:
          go("loadloop")
      end case
    else
      if pState = 4 then
        if me.countryCheck() = 0 then
          pState = tOldState
          return 
        end if
        if me.BirthdayANDemailcheck() = 0 then
          pState = tOldState
          return 
        end if
        case pMode of
          #register:
            go("doregist")
          #update:
            go("doupdate")
        end case
      end if
    end if
  end if
end

on countryCheck me
  global gChosenCountry, gChosenRegion
  if gChosenCountry = VOID then
    ShowAlert("CountryRequired")
    return 0
  end if
  if gChosenCountry = 342 or gChosenCountry = 424 or gChosenCountry = 405 then
    if gChosenRegion = VOID then
      ShowAlert("RegionRequired")
      return 0
    end if
  end if
  return 1
end

on getFigureResults me
  MyfigurePartList = [:]
  MyfigureColorList = [:]
  tmpStr = EMPTY
  put figurePartList
  put figureColorList
  repeat with c = 1 to figurePartList.count
    tColor = figureColorList[c]
    tPartPrefix = figurePartList[c]
    if tColor.length < 4 and not (tPartPrefix contains "sd=" or tPartPrefix contains "ey=") then
      tColor = "255,255,255"
      put tPartPrefix & " NO COLOR WAS SET"
    end if
    if c < figurePartList.count then
      tmpStr = tmpStr & tPartPrefix & "/" & tColor & "&"
    else
      tmpStr = tmpStr & tPartPrefix & "/" & tColor
    end if
    MyfigurePartList.addProp(getPropAt(figurePartList, c), figurePartList[c].char[length(figurePartList[c]) - 2..length(figurePartList[c])])
    if figureColorList[c] = "0" or figureColorList[c] = EMPTY or voidp(figureColorList[c]) then
      MyfigureColorList.addProp(getPropAt(figureColorList, c), paletteIndex(0))
      next repeat
    end if
    MyfigureColorList.addProp(getPropAt(figureColorList, c), value("color(#rgb," & figureColorList[c] & ")"))
  end repeat
  put "FIGURE RESULTS:", tmpStr
  put x_to(tmpStr) into field "figure_field"
end

on passwordCheck me
  if (field("password_field")).length < 3 then
    ShowAlert("YourPasswordIstooShort")
    return 
  end if
  if field("password_field") <> field("password_field2") or field("password_field") = EMPTY or field("charactername_field") = EMPTY then
    if field("password_field") <> field("password_field2") or field("password_field") = EMPTY then
      ShowAlert("CheckPassword")
    end if
    return 0
  else
    put field("password_field") into field "loginpw"
    put field("charactername_field") into field "loginname"
    return 1
  end if
end

on agreementCheck me
  if field("Agreement_field") <> "1" then
    ShowAlert("YouMustAgree")
    return 0
  end if
  return 1
end

on BirthdayANDemailcheck me
  emailfield = getmemnum("email_field")
  BirthdayOK = 1
  sDay = field(getmemnum("birthday_field.day"))
  sMonth = field(getmemnum("birthday_field.month"))
  sYear = field(getmemnum("birthday_field.year"))
  tDay = value(sDay.char[1..2])
  tMonth = value(sMonth.char[1..2])
  tYear = value(sYear.char[1..4])
  if tDay < 1 or tDay > 31 then
    BirthdayOK = 0
  end if
  if tMonth < 1 or tMonth > 12 then
    BirthdayOK = 0
  end if
  if tYear < 1910 or tYear > 1999 then
    BirthdayOK = 0
  end if
  if BirthdayOK = 1 then
    put tDay & "." & tMonth & "." & tYear into field getmemnum("birthday_field")
  end if
  if (field(emailfield)).length > 6 and field(emailfield) contains "@" then
    emailOk = 0
    repeat with f = offset("@", field(emailfield)) + 1 to (field(emailfield)).length
      if (field(emailfield)).char[f] = "." then
        emailOk = 1
      end if
      if (field(emailfield)).char[f] = "@" then
        emailOk = 0
        exit repeat
      end if
    end repeat
    if emailOk = 0 and BirthdayOK = 1 then
      ShowAlert("emailNotCorrect")
    else
      if emailOk = 1 and BirthdayOK = 0 then
        ShowAlert("CheckBirthday")
      else
        if emailOk = 0 and BirthdayOK = 0 then
          ShowAlert("CheckEmailandBirthday")
        end if
      end if
    end if
  else
    if BirthdayOK = 0 then
      ShowAlert("CheckEmailandBirthday")
    else
      ShowAlert("emailNotCorrect")
    end if
  end if
  if emailOk = 0 or BirthdayOK = 0 then
    return 0
  else
    return 1
  end if
end
