property spriteNum
global Mytop_navi, MyHeight_navi, MyWidth_navi, lineH_navi, FirstVisiblePlace_navi, VisibleLines_navi, gPopUpContext2, gNaviP, gNaviWindowsSpr, NeedUpdatetime, UnitIsUpdated, gPlaceNamesGraph, gUnits, gDoor, gChosenUnitIp, gChosenUnitPort, ClickPlace, ClickPlaceNum, gChosenRoomName, gNumGraph, gPalaceInsideNowGraph, gRefreshNavi

on beginSprite me
  if voidp(gRefreshNavi) then
    gRefreshNavi = 1
  end if
  if gRefreshNavi then
    gRefreshNavi = 0
    FirstVisiblePlace_navi = 1
    lineH_navi = 14
    Mytop_navi = lineH_navi * FirstVisiblePlace_navi
    MyWidth_navi = 251
    MyHeight_navi = 12 * lineH_navi
    sprite(me.spriteNum).width = sprite(me.spriteNum).member.width
    sprite(me.spriteNum).height = sprite(me.spriteNum).member.height
    ClearPicture(sprite(me.spriteNum).member.name, MyWidth_navi, lineH_navi * member("public_place.hierarchy").line.count)
    VisibleLines_navi = 0
    initNavigator()
    gNaviWindowsSpr = me.spriteNum
    SetAllUnitUsers()
    UnitIsUpdated = 1
    NeedUpdatetime = the timer + 5
    put "Navigator updated!"
  end if
end

on initNavigator me
  gNaviP = [:]
  gPlaceNamesGraph = [:]
  gPalaceInsideNowGraph = [:]
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = ":"
  TempImg = image(44, 7, 8)
  s = member("public_place.hierarchy").text
  tExceptList = member("unitMovies multiple rooms exception list").text
  tExceptions = [:]
  repeat with i = 1 to tExceptList.line.count
    tLine = tExceptList.line[i]
    if tLine <> EMPTY and tLine.char[1..2] <> "--" then
      tExceptions[tLine.item[1].word[1..tLine.item[1].word.count]] = tLine.item[2].word[1..tLine.item[2].word.count]
    end if
  end repeat
  repeat with f = 1 to s.line.count
    if value(s.line[f].item[2]) > 0 then
      VisibleLines_navi = VisibleLines_navi + 1
      if tExceptions[s.line[f].item[1]] <> "hide" then
        gNaviP.addProp(s.line[f].item[1], ["Visible": 1, "Main": 1, "Status": "Closed", "Multiroom": s.line[f].item[2]])
      else
        gNaviP.addProp(s.line[f].item[1], ["Visible": 1, "Main": 1, "Status": "Closed", "Multiroom": "1"])
      end if
      MainPlace = s.line[f].item[1]
    else
      visib = s.line[f].item[2]
      gNaviP.addProp(s.line[f].item[1], ["Visible": 0, "Main": MainPlace])
    end if
    member("public_place.nameToGraph").text = s.line[f].item[1]
    gPlaceNamesGraph.addProp(gNaviP.getPropAt(f), member(the number of member "public_place.nameToGraph").image.trimWhiteSpace().duplicate())
    gPalaceInsideNowGraph.addProp(gNaviP.getPropAt(f), TempImg)
  end repeat
  the itemDelimiter = oldItemDelimiter
  gNumGraph = []
  repeat with f = 0 to 40
    member(the number of member "NumbersWannabeGraph").text = string(f)
    gNumGraph.add(member(the number of member "NumbersWannabeGraph").image.extractAlpha().trimWhiteSpace().duplicate())
  end repeat
end

on mouseUp me
  global ScrollBarLiftBtn
  if FirstVisiblePlace_navi < 1 then
    FirstVisiblePlace_navi = 1
  end if
  timee = the timer
  click = (the mouseV - sprite(me.spriteNum).top) / lineH_navi + (FirstVisiblePlace_navi - 1)
  ClickPoint = the mouseLoc
  if click = 0 or click < FirstVisiblePlace_navi then
    if the movieName contains "entry" or the mouseH < sprite(me.spriteNum).right - 30 then
      exit
    else
      sendFuseMsg("GOAWAY")
      gNaviWindowsSpr = 0
      closeNavigator()
    end if
    exit
  end if
  NumberOfVisible = 0
  repeat with f = 1 to gNaviP.count
    if gNaviP.getaProp(gNaviP.getPropAt(f)).getaProp("Visible") = 1 then
      NumberOfVisible = NumberOfVisible + 1
    end if
    if NumberOfVisible = click then
      ClickPlace = gNaviP.getaProp(gNaviP.getPropAt(f))
      ClickPlaceNum = f
      exit repeat
    end if
  end repeat
  if NumberOfVisible = click then
    if ClickPoint.locH <= sprite(me.spriteNum).right - 30 and ClickPlace.getaProp("Main") and value(ClickPlace.getaProp("Multiroom")) > 1 and ClickPlace.getaProp("Status") = "Closed" then
      ClickPlace.setaProp("Status", "Open")
      openhierarchy(ClickPlaceNum, value(ClickPlace.getaProp("Multiroom")), gNaviP.getPropAt(ClickPlaceNum))
      redraw(me)
      sendSprite(ScrollBarLiftBtn, #NaviLiftPosiotion, FirstVisiblePlace_navi, VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1))
    else
      if ClickPoint.locH <= sprite(me.spriteNum).right - 30 and ClickPlace.getaProp("Main") and value(ClickPlace.getaProp("Multiroom")) > 1 and ClickPlace.getaProp("Status") = "Open" then
        ClickPlace.setaProp("Status", "Closed")
        CloseHierarchy(ClickPlaceNum, value(ClickPlace.getaProp("Multiroom")), gNaviP.getPropAt(ClickPlaceNum))
        if VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1) < 0 then
          Mytop_navi = 0
          FirstVisiblePlace_navi = 0
        end if
        redraw(me)
        sendSprite(ScrollBarLiftBtn, #NaviLiftPosiotion, FirstVisiblePlace_navi, VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1))
      end if
    end if
    showInfo(me, gNaviP.getPropAt(ClickPlaceNum))
    if ClickPoint.locH > sprite(me.spriteNum).right - 30 and ClickPlace.getaProp("Main") <> 1 or ClickPoint.locH > sprite(me.spriteNum).right - 30 and ClickPlace.getaProp("Main") and value(ClickPlace.getaProp("Multiroom")) = 1 then
      if voidp(gUnits) then
        return 
      end if
      if ClickPlace.getaProp("Main") = 1 and ClickPlace.getaProp("Multiroom") = 1 then
        unitName = gNaviP.getPropAt(ClickPlaceNum)
        gDoor = 0
      else
        unitName = ClickPlace.getaProp("Main")
        gDoor = gNaviP.findPos(gNaviP.getPropAt(ClickPlaceNum)) - gNaviP.findPos(unitName) - 1
        if gDoor < 0 then
          gDoor = 0
        end if
      end if
      unit = gUnits.getaProp(unitName)
      put "NavigatorGO" && "UnitName" && unitName, gDoor
      if unit <> VOID then
        host = gUnits.getaProp(unitName).getaProp("host")
        gChosenUnitIp = char offset("/", host) + 1 to host.length of host
        gChosenUnitPort = gUnits.getaProp(unitName).getaProp("port")
        gNaviWindowsSpr = 0
        member("LoadPublicRoom").text = AddTextToField("LoadingPublicRoom") & RETURN & unitName
        sFrame = "loading_public"
        goContext(sFrame, gPopUpContext2)
        updateStage()
        gPopUpContext2 = VOID
        goUnit(gUnits.getaProp(unitName).getaProp("name"), gDoor)
        exit
      end if
    end if
    if ClickPlace.getaProp("Main") <> 1 or ClickPlace.getaProp("Main") = 1 then
      unitName = gNaviP.getPropAt(ClickPlaceNum)
      main = getaProp(ClickPlace, "Main")
      if main = 1 then
        roomName = VOID
      else
        roomName = unitName
        unitName = main
      end if
      member("publicroom_peoplelist").text = EMPTY
      sFrame = "public_room_info"
      gChosenRoomName = unitName
      if not voidp(roomName) then
        sendEPFuseMsg("GETUNITUSERS /" & unitName & "/" & roomName)
      else
        sendEPFuseMsg("GETUNITUSERS /" & unitName)
      end if
      goContext(sFrame, gPopUpContext2)
      exit
    end if
  end if
end

on showInfo me, unitName
  main = getaProp(ClickPlace, "Main")
  if main = 1 then
    unitKey = unitName
  else
    unitKey = main & "." & unitName
  end if
  p = gUnits.getaProp(unitName)
  if voidp(p) then
    put unitName into field "room_name_n_load"
  else
    put unitName && "(" & getaProp(p, "activeUsers") & "/" & getaProp(p, "maxUsers") & ")" into field "room_name_n_load"
  end if
  put AddTextToField(unitKey, "unit infotexts") into field "room_infotext"
end

on openhierarchy MainPlace, SubNum, PlaceName
  repeat with f = MainPlace + 1 to MainPlace + SubNum - 1
    if gNaviP.getaProp(gNaviP.getPropAt(f)).getaProp("Main") = PlaceName then
      gNaviP.getaProp(gNaviP.getPropAt(f)).setaProp("Visible", 1)
      VisibleLines_navi = VisibleLines_navi + 1
    end if
  end repeat
end

on CloseHierarchy MainPlace, SubNum, PlaceName
  repeat with f = MainPlace + 1 to MainPlace + SubNum - 1
    if gNaviP.getaProp(gNaviP.getPropAt(f)).getaProp("Main") = PlaceName then
      gNaviP.getaProp(gNaviP.getPropAt(f)).setaProp("Visible", 0)
      VisibleLines_navi = VisibleLines_navi - 1
    end if
  end repeat
end

on NaviScrollWhithLift me, percentNow
  global gNaviUpBtn, gNaviDownBtn, ScrollBarLiftBtn
  if FirstVisiblePlace_navi > 1 then
    sendAllSprites(#ActiveOrNotScrollUpBtn, 1)
  else
    sendSprite(gNaviUpBtn, #ActiveOrNotScrollUpBtn, 0)
  end if
  if VisibleLines_navi - FirstVisiblePlace_navi > integer(MyHeight_navi / lineH_navi) - 1 then
    sendAllSprites(#ActiveOrNotScrollDownBtn, 1)
  else
    sendSprite(gNaviDownBtn, #ActiveOrNotScrollDownBtn, 0)
  end if
  FirstVisiblePlace_navi = integer((VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1)) * percentNow)
  if FirstVisiblePlace_navi <= 0 then
    FirstVisiblePlace_navi = 1
  end if
  if FirstVisiblePlace_navi >= VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1) then
    FirstVisiblePlace_navi = VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1)
  end if
  Mytop_navi = lineH_navi * FirstVisiblePlace_navi
  if Mytop_navi < 0 then
    Mytop_navi = 0
  end if
  redraw(me)
end

on ScrollNavigatorWindow me, direction
  global gNaviUpBtn, gNaviDownBtn, ScrollBarLiftBtn
  scroll = 1
  if direction = "Up" then
    repeat while scroll
      if FirstVisiblePlace_navi > 1 then
        FirstVisiblePlace_navi = FirstVisiblePlace_navi - 1
      end if
      Mytop_navi = lineH_navi * FirstVisiblePlace_navi
      if Mytop_navi < 0 then
        Mytop_navi = 0
      end if
      redraw(me)
      ScrollWaitTime(me, 7)
      if FirstVisiblePlace_navi > 1 then
        sendAllSprites(#ActiveOrNotScrollUpBtn, 1)
      else
        sendSprite(gNaviUpBtn, #ActiveOrNotScrollUpBtn, 0)
      end if
      sendSprite(ScrollBarLiftBtn, #NaviLiftPosiotion, FirstVisiblePlace_navi, VisibleLines_navi - (integer(MyHeight_navi / lineH_navi) - 1))
      if the mouseDown = 0 or FirstVisiblePlace_navi = 0 then
        scroll = 0
      end if
    end repeat
  else
    repeat while scroll
      if VisibleLines_navi - FirstVisiblePlace_navi > integer(MyHeight_navi / lineH_navi) - 1 then
        FirstVisiblePlace_navi = FirstVisiblePlace_navi + 1
      end if
      Mytop_navi = lineH_navi * FirstVisiblePlace_navi
      if Mytop_navi < 0 then
        Mytop_navi = 0
      end if
      redraw(me)
      ScrollWaitTime(me, 7)
      if VisibleLines_navi - FirstVisiblePlace_navi > integer(MyHeight_navi / lineH_navi) - 1 then
        sendAllSprites(#ActiveOrNotScrollDownBtn, 1)
      else
        sendSprite(gNaviDownBtn, #ActiveOrNotScrollDownBtn, 0)
      end if
      sendSprite(ScrollBarLiftBtn, #NaviLiftPosiotion, FirstVisiblePlace_navi, VisibleLines_navi - integer(MyHeight_navi / lineH_navi))
      if the mouseDown = 0 or VisibleLines_navi - FirstVisiblePlace_navi = integer(MyHeight_navi / lineH_navi) - 1 then
        scroll = 0
      end if
    end repeat
  end if
end

on ScrollWaitTime me, ScrollWait
  ScrollWait = ScrollWait + the timer
  repeat while the timer < ScrollWait
    nothing()
  end repeat
end

on redraw me
  global NavImg
  UpdateNaviWindow(me)
  sprite(spriteNum).member.image = NavImg
  updateStage()
end

on CropVisibleNavWindow me
  global NavImg
  return 
  member(sprite(me.spriteNum).member).image = NavImg.crop(rect(0, Mytop_navi, MyWidth_navi, MyHeight_navi + Mytop_navi))
  sprite(me.spriteNum).width = sprite(me.spriteNum).member.width
  sprite(me.spriteNum).height = sprite(me.spriteNum).member.height
  updateStage()
end

on exitFrame me
  global gNaviUpBtn, gNaviDownBtn, ScrollBarLiftBtn
  if FirstVisiblePlace_navi > 1 then
    sendAllSprites(#ActiveOrNotScrollUpBtn, 1)
  else
    sendSprite(gNaviUpBtn, #ActiveOrNotScrollUpBtn, 0)
  end if
  if VisibleLines_navi - FirstVisiblePlace_navi > integer(MyHeight_navi / lineH_navi) - 1 then
    sendAllSprites(#ActiveOrNotScrollDownBtn, 1)
  else
    sendSprite(gNaviDownBtn, #ActiveOrNotScrollDownBtn, 0)
  end if
  if UnitIsUpdated = 1 and NeedUpdatetime < the timer then
    redraw(me)
    put "Navigator Update Units"
    UnitIsUpdated = 0
    NeedUpdatetime = the timer + 10
  end if
end
