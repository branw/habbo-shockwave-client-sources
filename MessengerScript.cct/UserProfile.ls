global Profilemg, gProfileP, gPlaceNamesGraph, gProfileWindowsSpr, gProfileListsGraph

on UpdateProfileWindow
  ClearProfilePicture("ProfileWindow", 179, gProfileP.count * 14 + 14)
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = "/"
  f = -1
  ProfileLines = gProfileP.count
  repeat with i = 1 to ProfileLines
    if gProfileP.getaProp(gProfileP.getPropAt(i)).getaProp("Visible") = 1 then
      f = f + 1
      if gProfileP.getaProp(gProfileP.getPropAt(i)).getaProp("Multiroom") >= 1 then
        Myhierarchy = 10
        if gProfileP.getaProp(gProfileP.getPropAt(i)).getaProp("Status") = "Closed" then
          triangle = "messanger_triangle_closed"
          MakeProfilePicture(triangle, point(Myhierarchy, f * 14 + 1), 36)
          imgLine = gProfileListsGraph.crop(0, (i - 1) * 10, 100, i * 10)
          MakeProfileImgToPic(imgLine, point(Myhierarchy + 15, f * 14 + 1))
        end if
        if gProfileP.getaProp(gProfileP.getPropAt(i)).getaProp("Status") = "Open" then
          triangle = "messanger_triangle_open"
          MakeProfilePicture(triangle, point(Myhierarchy, f * 14 + 1), 36)
          imgLine = gProfileListsGraph.crop(0, (i - 1) * 10, 100, i * 10)
          MakeProfileImgToPic(imgLine, point(Myhierarchy + 15, f * 14 + 1))
        end if
        next repeat
      end if
      Myhierarchy = 16
      if gProfileP.getaProp(gProfileP.getPropAt(i)).getaProp("Checked") = 1 then
        iconMember = "messenger_checkbox_checked"
      else
        iconMember = "messenger_checkbox_unchecked"
      end if
      MakeProfilePicture(iconMember, point(Myhierarchy + 10, f * 14), 36)
      imgLine = gProfileListsGraph.crop(0, (i - 1) * 10, 100, i * 10)
      MakeProfileImgToPic(imgLine, point(Myhierarchy + 28, f * 14 + 1))
    end if
  end repeat
  the itemDelimiter = oldItemDelimiter
end

on ResetProfileWindow
  member("Profile").image.fill(rect(0, 0, sprite(gProfileWindowsSpr).width, sprite(gProfileWindowsSpr).height), rgb(0, 0, 0))
  imMem = member(the number of member "ProfileLoading")
  suhde = point(65, 50)
  targetRect = imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV)
  sourseRect = imMem.rect
  member("Profile").image.copyPixels(imMem.image, targetRect, sourseRect)
end

on ClearProfilePicture WhichMember, myWidth, MyHeight
  Profilemg = image(myWidth, MyHeight, 8)
  Profilemg.fill(rect(0, 0, myWidth, MyHeight), rgb(0, 0, 0))
end

on CropProfileEmpty WhichMember, area
  member(WhichMember).image.fill(area, rgb(255, 255, 255))
end

on MakeProfileImgToPic imMem, StartPoint, Myink, imagForeColor, imagBackColor, MyBlendLevel
  suhde = StartPoint
  targetRect = imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV)
  sourseRect = imMem.rect
  if Myink = VOID then
    Myink = 0
  end if
  if imagBackColor = VOID then
    imagBackColor = rgb(255, 255, 255)
  end if
  if imagForeColor = VOID then
    imagForeColor = rgb(0, 0, 0)
  end if
  if MyBlendLevel = VOID then
    MyBlendLevel = 255
  end if
  Profilemg.copyPixels(imMem, targetRect, sourseRect, [#ink: Myink, #bgColor: imagBackColor, #color: imagForeColor, #blendLevel: MyBlendLevel])
end

on MakeProfilePicture WhichMember, StartPoint, Myink, imagForeColor, imagBackColor, MyBlendLevel
  imMem = member(the number of member WhichMember)
  suhde = StartPoint
  targetRect = imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV)
  sourseRect = imMem.rect
  if Myink = VOID then
    Myink = 0
  end if
  if imagBackColor = VOID then
    imagBackColor = rgb(255, 255, 255)
  end if
  if imagForeColor = VOID then
    imagForeColor = rgb(0, 0, 0)
  end if
  if MyBlendLevel = VOID then
    MyBlendLevel = 255
  end if
  Profilemg.copyPixels(imMem.image, targetRect, sourseRect, [#ink: Myink, #bgColor: imagBackColor, #color: imagForeColor, #blendLevel: MyBlendLevel])
end

on parseUserProfile data
  oldDelim = the itemDelimiter
  s = EMPTY
  sub = EMPTY
  main = EMPTY
  gProfileP = [:]
  oldMainId = 0
  oldMainName = EMPTY
  oldMainValue = 0
  mainlines = 0
  the itemDelimiter = TAB
  num = the number of lines in data
  repeat with i = 1 to num
    id = integer(data.line[i].item[1])
    parentid = integer(data.line[i].item[2])
    name = data.line[i].item[3]
    value = data.line[i].item[4]
    if id mod 100 = 0 then
      if sub.length > 0 then
        put main & RETURN & sub after oldDelim
        gProfileP.addProp(oldMainId, ["text": oldMainName, "Checked": oldMainValue, "Visible": 1, "Main": 1, "Status": "Closed", "Multiroom": the number of lines in sub])
        mainlines = mainlines + 1
      end if
      oldMainName = name
      oldMainValue = value
      parentid = id
      main = name
      sub = EMPTY
      next repeat
    end if
    oldMainId = parentid
    put name & RETURN after oldDelim
    gProfileP.addProp(id, ["text": name, "Checked": value, "Visible": 0, "Main": parentid, "Status": "Closed", "Multiroom": 0])
  end repeat
  sort(gProfileP)
  the itemDelimiter = oldDelim
  member("Profile.items").text = s
  put gProfileWindowsSpr, "gProfileWindowsSpr"
  if gProfileWindowsSpr <> VOID then
    sendSprite(gProfileWindowsSpr, #initProfileSpr, mainlines)
  end if
end
