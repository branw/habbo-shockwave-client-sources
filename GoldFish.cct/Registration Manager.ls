property pState, pMode, pCountryMan
global figurePartList, figureColorList, MyfigurePartList, MyfigureColorList

on new me, tMode, tState
  if tState = VOID then
    pState = 1
  else
    pState = tState
  end if
  pMode = tMode
  pCountryMan = new(script(getmemnum("Country Manager Class")))
  me.Init()
  return me
end

on Init me
  global figurePartList, figureColorList
  if pMode = #register then
    figurePartList = [:]
    figurePartList = [#sd: "sd=001", #hr: "hr=001", #hd: "hd=001", #ey: "ey=001", #fc: "fc=001", #bd: "bd=001", #lh: "lh=001", #rh: "rh=001", #ch: "ch=001", #ls: "ls=001", #rs: "rs=001", #lg: "lg=001", #sh: "sh=001"]
    figureColorList = [:]
    figureColorList = [#sd: "0", #hr: "0", #hd: "0", #ey: "0", #fc: "0", #bd: "0", #lh: "0", #rh: "0", #ch: "0", #ls: "0", #rs: "0", #lg: "0", #sh: "0"]
    go("regist1")
  else
    if pMode = #update then
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
  global gChosenCountry, gChosenRegion
  case pState of
    1:
      if tState <> 0 then
        if me.passwordCheck() = 0 then
          return 
        end if
        sendAllSprites(#getMyFigureData)
        me.getFigureResults()
      end if
    2:
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
        if gChosenCountry = VOID then
          ShowAlert("CountryRequired")
          return 
        end if
        if gChosenCountry = 342 or gChosenCountry = 424 or gChosenCountry = 405 then
          if gChosenRegion = VOID then
            ShowAlert("RegionRequired")
            return 
          end if
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

on getFigureResults me
  MyfigurePartList = [:]
  MyfigureColorList = [:]
  tmpStr = EMPTY
  put figurePartList
  put figureColorList
  repeat with c = 1 to figurePartList.count
    if c < figurePartList.count then
      tmpStr = tmpStr & figurePartList[c] & "/" & figureColorList[c] & "&"
    else
      tmpStr = tmpStr & figurePartList[c] & "/" & figureColorList[c]
    end if
    MyfigurePartList.addProp(getPropAt(figurePartList, c), figurePartList[c].char[length(figurePartList[c]) - 2..length(figurePartList[c])])
    if figureColorList[c] = "0" or figureColorList[c] = EMPTY or voidp(figureColorList[c]) then
      MyfigureColorList.addProp(getPropAt(figureColorList, c), paletteIndex(0))
      next repeat
    end if
    MyfigureColorList.addProp(getPropAt(figureColorList, c), value("color(#rgb," & figureColorList[c] & ")"))
  end repeat
  put tmpStr into field "figure_field"
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
  Birthday = "Birthday_field"
  emailfield = "email_field"
  BirthdayOK = 1
  if (field(Birthday)).length > 8 then
    if (field(Birthday)).char[(field(Birthday)).length - 3..(field(Birthday)).length - 2] = "19" or (field(Birthday)).char[(field(Birthday)).length - 3..(field(Birthday)).length - 2] = "20" then
      BirthdayOK = 1
    else
      BirthdayOK = 0
    end if
  else
    BirthdayOK = 0
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
