property MyTop, MyHeight, myWidth, lineH, FirstVisiblePlace, VisibleLines, context, ClickLine, ClickLineNum, gChosenRoomName
global gProfileP, gProfileWindowsSpr, gProfileListsGraph, gUnits, gDoor, gChosenUnitIp, gChosenUnitPort

on beginSprite me
  FirstVisiblePlace = 0
  lineH = 14
  MyTop = lineH * FirstVisiblePlace
  myWidth = 179
  MyHeight = 8 * lineH
  gProfileWindowsSpr = me.spriteNum
  sendEPFuseMsg("UINFO_GETPROFILE")
  if voidp(gProfileP) then
    member("Profile").image.fill(rect(0, 0, myWidth, MyHeight), rgb(0, 0, 0))
  end if
  sprite(me.spriteNum).width = sprite(me.spriteNum).member.width
  sprite(me.spriteNum).height = sprite(me.spriteNum).member.height
  ClearProfilePicture(sprite(me.spriteNum).member.name, myWidth, MyHeight)
  VisibleLines = 0
end

on initProfileSpr me, mainlines
  ClearProfilePicture(sprite(gProfileWindowsSpr).member.name, myWidth, count(gProfileP))
  if mainlines <> VOID then
    VisibleLines = mainlines - 1
  end if
  put mainlines, VisibleLines
  gProfileListsGraph = image(member("Profile.items").width, member("Profile.items").height, 8)
  gProfileListsGraph = member("Profile.items").image.trimWhiteSpace().duplicate()
  UpdateProfileWindow()
  CropVisibleProfileWindow(me)
end

on mouseDown me
  global ScrollProfileBarLiftBtn
  click = (the mouseV - sprite(me.spriteNum).top) / lineH + FirstVisiblePlace
  click = click + 1
  NumberOfVisible = 0
  repeat with f = 1 to gProfileP.count
    if gProfileP.getaProp(gProfileP.getPropAt(f)).getaProp("Visible") = 1 then
      NumberOfVisible = NumberOfVisible + 1
    end if
    if NumberOfVisible = click then
      ClickLine = gProfileP.getaProp(gProfileP.getPropAt(f))
      ClickLineNum = f
      put gProfileP.getPropAt(f), ClickLine, click
      exit repeat
    end if
  end repeat
  if NumberOfVisible = click then
    if ClickLine.getaProp("Main") and value(ClickLine.getaProp("Multiroom")) > 1 and ClickLine.getaProp("Status") = "Closed" then
      ClickLine.setaProp("Status", "Open")
      openProfileHierarchy(ClickLineNum, value(ClickLine.getaProp("Multiroom")), gProfileP.getPropAt(ClickLineNum))
      UpdateProfileWindow()
      CropVisibleProfileWindow(me)
      sendSprite(ScrollProfileBarLiftBtn, #LiftPosiotion, FirstVisiblePlace, VisibleLines - (integer(MyHeight / lineH) - 1))
    else
      if ClickLine.getaProp("Main") and value(ClickLine.getaProp("Multiroom")) > 1 and ClickLine.getaProp("Status") = "Open" then
        ClickLine.setaProp("Status", "Closed")
        closeProfileHierarchy(ClickLineNum, value(ClickLine.getaProp("Multiroom")), gProfileP.getPropAt(ClickLineNum))
        UpdateProfileWindow()
        CropVisibleProfileWindow(me)
        sendSprite(ScrollProfileBarLiftBtn, #LiftPosiotion, FirstVisiblePlace, VisibleLines - (integer(MyHeight / lineH) - 1))
      end if
    end if
    if ClickLine.getaProp("Main") <> 1 or ClickLine.getaProp("Main") and value(ClickLine.getaProp("Multiroom")) = 1 then
      if gProfileP.getaProp(gProfileP.getPropAt(ClickLineNum)).getProp("Checked") = 1 then
        gProfileP.getaProp(gProfileP.getPropAt(ClickLineNum)).setaProp("Checked", 0)
      else
        gProfileP.getaProp(gProfileP.getPropAt(ClickLineNum)).setaProp("Checked", 1)
      end if
      put gProfileP.getPropAt(ClickLineNum), gProfileP.getaProp(gProfileP.getPropAt(ClickLineNum)).getProp("text"), gProfileP.getaProp(gProfileP.getPropAt(ClickLineNum)).getProp("Checked")
      sendEPFuseMsg("UINFO_SETPROFILEVALUE /" & gProfileP.getPropAt(ClickLineNum) & "/" & gProfileP.getaProp(gProfileP.getPropAt(ClickLineNum)).getProp("Checked"))
      UpdateProfileWindow()
      CropVisibleProfileWindow(me)
    end if
  end if
end

on openProfileHierarchy MainPlace, SubNum, PlaceName
  repeat with f = MainPlace + 1 to MainPlace + SubNum - 1
    if gProfileP.getaProp(gProfileP.getPropAt(f)).getaProp("Main") = PlaceName then
      gProfileP.getaProp(gProfileP.getPropAt(f)).setaProp("Visible", 1)
      VisibleLines = VisibleLines + 1
    end if
  end repeat
end

on closeProfileHierarchy MainPlace, SubNum, PlaceName
  repeat with f = MainPlace + 1 to MainPlace + SubNum - 1
    if gProfileP.getaProp(gProfileP.getPropAt(f)).getaProp("Main") = PlaceName then
      gProfileP.getaProp(gProfileP.getPropAt(f)).setaProp("Visible", 0)
      VisibleLines = VisibleLines - 1
    end if
  end repeat
end

on ScrollWhithLift me, percentNow
  global gProfileUpBtn, gProfileDownBtn, ScrollProfileBarLiftBtn
  if FirstVisiblePlace > 0 then
    sendAllSprites(#ActiveOrNotScrollUpBtn, 1)
  else
    sendSprite(gProfileUpBtn, #ActiveOrNotScrollUpBtn, 0)
  end if
  if VisibleLines - FirstVisiblePlace > integer(MyHeight / lineH) - 1 then
    sendAllSprites(#ActiveOrNotScrollDownBtn, 1)
  else
    sendSprite(gProfileDownBtn, #ActiveOrNotScrollDownBtn, 0)
  end if
  FirstVisiblePlace = integer((VisibleLines - (integer(MyHeight / lineH) - 1)) * percentNow)
  if FirstVisiblePlace <= 0 then
    FirstVisiblePlace = 0
  end if
  if FirstVisiblePlace >= VisibleLines - (integer(MyHeight / lineH) - 1) then
    FirstVisiblePlace = VisibleLines - (integer(MyHeight / lineH) - 1)
  end if
  MyTop = lineH * FirstVisiblePlace
  CropVisibleProfileWindow(me)
end

on EndOfScrollWhithLift me, pp
end

on ScrollProfilegatorWindow me, direction
  global gProfileUpBtn, gProfileDownBtn, ScrollProfileBarLiftBtn
  scroll = 1
  if direction = "Up" then
    repeat while scroll
      if FirstVisiblePlace > 0 then
        FirstVisiblePlace = FirstVisiblePlace - 1
      end if
      MyTop = lineH * FirstVisiblePlace
      CropVisibleProfileWindow(me)
      ScrollWaitTime(me, 7)
      if FirstVisiblePlace > 0 then
        sendAllSprites(#ActiveOrNotScrollUpBtn, 1)
      else
        sendSprite(gProfileUpBtn, #ActiveOrNotScrollUpBtn, 0)
      end if
      sendSprite(ScrollProfileBarLiftBtn, #LiftPosiotion, FirstVisiblePlace, VisibleLines - (integer(MyHeight / lineH) - 1))
      if the mouseDown = 0 or FirstVisiblePlace = 0 then
        scroll = 0
      end if
    end repeat
  else
    repeat while scroll
      if VisibleLines - FirstVisiblePlace > integer(MyHeight / lineH) - 1 then
        FirstVisiblePlace = FirstVisiblePlace + 1
      end if
      MyTop = lineH * FirstVisiblePlace
      CropVisibleProfileWindow(me)
      ScrollWaitTime(me, 7)
      if VisibleLines - FirstVisiblePlace > integer(MyHeight / lineH) - 1 then
        sendAllSprites(#ActiveOrNotScrollDownBtn, 1)
      else
        sendSprite(gProfileDownBtn, #ActiveOrNotScrollDownBtn, 0)
      end if
      sendSprite(ScrollProfileBarLiftBtn, #LiftPosiotion, FirstVisiblePlace, VisibleLines - (integer(MyHeight / lineH) - 1))
      if the mouseDown = 0 or VisibleLines - FirstVisiblePlace = integer(MyHeight / lineH) - 1 then
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

on CropVisibleProfileWindow me
  global Profilemg
  member(sprite(me.spriteNum).member).image = Profilemg.crop(rect(0, MyTop, myWidth, MyHeight + MyTop))
  sprite(me.spriteNum).width = sprite(me.spriteNum).member.width
  sprite(me.spriteNum).height = sprite(me.spriteNum).member.height
  updateStage()
end

on enterFrame me
  global gProfileUpBtn, gProfileDownBtn, ScrollProfileBarLiftBtn
  if FirstVisiblePlace > 0 then
    sendAllSprites(#ActiveOrNotScrollUpBtn, 1)
  else
    sendSprite(gProfileUpBtn, #ActiveOrNotScrollUpBtn, 0)
  end if
  if VisibleLines - FirstVisiblePlace > integer(MyHeight / lineH) - 1 then
    sendAllSprites(#ActiveOrNotScrollDownBtn, 1)
  else
    sendSprite(gProfileDownBtn, #ActiveOrNotScrollDownBtn, 0)
  end if
end
