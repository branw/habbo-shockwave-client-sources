property currPartNum, myParts, totalParts, myField, mySprs, mag, currColorNum, currColorRgb, allColors, myPreviewSprite, addParts, addSprs, sex, currPartNums, currColorNums
global figurePartList, figureColorList

on beginSprite me
  sex = field("charactersex_field")
  if sex = "F" then
    sex = "Female"
  end if
  if sex = "M" then
    sex = "Male"
  end if
  if sex = "null" then
    sex = "Male"
  end if
  totalParts = (field(myField & "_specs_" & sex)).line.count
  currPartNum = 1
  currColorNum = 1
  the itemDelimiter = "/"
  allColors = (field(myField & "_specs_" & sex)).line[currPartNum].item[2]
  the itemDelimiter = ","
  currPartNums = []
  the itemDelimiter = "/"
  currPartNumsTmp = (field(myField & "_specs_" & sex)).line[currPartNum].item[1]
  the itemDelimiter = ","
  repeat with c = 1 to currPartNumsTmp.item.count
    currPartNums.add(x_to(currPartNumsTmp.item[c]))
  end repeat
  the itemDelimiter = ","
  if allColors = EMPTY then
    allColors = "255,255,255"
  end if
  the itemDelimiter = "&"
  currColorRgb = x_to(allColors.item[currColorNum])
  the itemDelimiter = ","
end

on changeMySex me
  sex = member(getmemnum("charactersex_field")).text
  totalParts = (field(myField & "_specs_" & sex)).line.count
  currPartNum = 1
  currColorNum = 1
  the itemDelimiter = "/"
  allColors = (field(myField & "_specs_" & sex)).line[currPartNum].item[2]
  the itemDelimiter = ","
  currPartNums = []
  the itemDelimiter = "/"
  currPartNumsTmp = (field(myField & "_specs_" & sex)).line[currPartNum].item[1]
  the itemDelimiter = ","
  repeat with c = 1 to currPartNumsTmp.item.count
    currPartNums.add(x_to(currPartNumsTmp.item[c]))
  end repeat
  the itemDelimiter = ","
  if allColors = EMPTY then
    allColors = "255,255,255"
  end if
  the itemDelimiter = "&"
  currColorRgb = x_to(allColors.item[currColorNum])
  the itemDelimiter = ","
  updatespr(me)
end

on randomFigure me
  oldItemLimiter = the itemDelimiter
  randomPart = random(totalParts)
  currPartNum = randomPart
  currPartNums = []
  the itemDelimiter = "/"
  currPartNumsTmp = (field(myField & "_specs_" & sex)).line[currPartNum].item[1]
  the itemDelimiter = ","
  repeat with c = 1 to currPartNumsTmp.item.count
    currPartNums.add(x_to(currPartNumsTmp.item[c]))
  end repeat
  the itemDelimiter = "/"
  allColors = (field(myField & "_specs_" & sex)).line[randomPart].item[2]
  if allColors = EMPTY then
    allColors = "255,255,255"
  end if
  the itemDelimiter = oldItemLimiter
  oldItemLimiter = the itemDelimiter
  the itemDelimiter = "&"
  currColorNum = random(allColors.item.count)
  currColorRgb = x_to(allColors.item[currColorNum])
  the itemDelimiter = oldItemLimiter
  sendAllSprites(#UpdateMyRaodomizeSmallSpr, myField, currPartNums, currColorRgb, currPartNum, currColorNum, mySprs)
  updatespr(me)
end

on UpdateMyRaodomizeSmallSpr me, WhichPartNow, WhichParts, WhichPartColor, WhichPartNum, WhichColorNum, SpriS
  if myField = WhichPartNow and mySprs <> SpriS then
    currPartNums = WhichParts
    currColorRgb = WhichPartColor
    currPartNum = WhichPartNum
    currColorNum = WhichColorNum
  end if
end

on addExtraParts me, p, s
  addParts = p
  addSprs = s
end

on updatespr me
  repeat with c = 1 to myParts.item.count
    tmpNbr = EMPTY & x_from(currPartNums[c])
    repeat with t = 1 to 3
      if tmpNbr.length < 3 then
        tmpNbr = "0" & tmpNbr
      end if
    end repeat
    the itemDelimiter = ","
    s = "h_std_" & myParts.item[c] & "_" & tmpNbr & "_2_0"
    if getmemnum(s) > 1 then
      set the member of sprite integer(mySprs.item[c]) to s
      set the width of sprite integer(mySprs.item[c]) to member(s).width * (1 + mag)
      set the height of sprite integer(mySprs.item[c]) to member(s).height * (1 + mag)
      if mag and myParts.item[c] <> "ey" then
        tCurrColorRgb = x_from(currColorRgb)
        r = integer(tCurrColorRgb.item[1])
        g = integer(tCurrColorRgb.item[2])
        b = integer(tCurrColorRgb.item[3])
        sprite(integer(mySprs.item[c])).bgColor = rgb(r, g, b)
        sprite(myPreviewSprite).bgColor = rgb(r, g, b)
      end if
    end if
  end repeat
  if mag and addSprs <> VOID then
    repeat with c = 1 to addSprs.item.count
      sprite(integer(addSprs.item[c])).bgColor = rgb(r, g, b)
    end repeat
  end if
end

on changeColor me, d
  if d then
    currColorNum = currColorNum + 1
  else
    currColorNum = currColorNum - 1
  end if
  the itemDelimiter = "&"
  if currColorNum < 1 then
    currColorNum = allColors.item.count
  else
    if currColorNum > allColors.item.count then
      currColorNum = 1
    end if
  end if
  currColorRgb = x_to(allColors.item[currColorNum])
end

on changePart me, d
  if d = 1 then
    currPartNum = currPartNum + 1
  else
    currPartNum = currPartNum - 1
  end if
  if currPartNum < 1 then
    currPartNum = totalParts
  else
    if currPartNum > totalParts then
      currPartNum = 1
    end if
  end if
  currPartNums = []
  the itemDelimiter = "/"
  currPartNumsTmp = (field(myField & "_specs_" & sex)).line[currPartNum].item[1]
  the itemDelimiter = ","
  repeat with c = 1 to currPartNumsTmp.item.count
    currPartNums.add(x_to(currPartNumsTmp.item[c]))
  end repeat
  currColorNum = 1
  the itemDelimiter = "/"
  allColors = (field(myField & "_specs_" & sex)).line[currPartNum].item[2]
  if allColors = EMPTY then
    allColors = "255,255,255"
  end if
  currColorRgb = x_to(allColors.item[currColorNum])
  the itemDelimiter = ","
end

on initMeForChange me
  currPartNums = []
  tmpCurrPartNums = []
  tmpColor = rgb("#ffffff")
  the itemDelimiter = ","
  repeat with c = 1 to myParts.item.count
    tmpToAdd = getaProp(figurePartList, myParts.item[c])
    the itemDelimiter = "="
    tmpToAdd2 = integer(tmpToAdd.item[2])
    the itemDelimiter = ","
    tmpCurrPartNums.add(x_to(string(tmpToAdd2)))
    tmpToAdd = getaProp(figureColorList, myParts.item[c])
    the itemDelimiter = ","
    if tmpToAdd.item.count < 3 then
      if tmpToAdd.item.count = 1 and tmpToAdd.char[1] = "*" then
        tmpColor = rgb("#" & tmpToAdd.char[2..tmpToAdd.length])
        tmpToAdd = EMPTY
        tmpToAdd = tmpColor.red & "," & tmpColor.green & "," & tmpColor.blue
      else
        tmpColor = color(#paletteIndex, integer(tmpToAdd))
        tmpToAdd = tmpColor.red & "," & tmpColor.green & "," & tmpColor.blue
      end if
    end if
    currColorRgb = x_to(tmpToAdd)
  end repeat
  currPartNums = tmpCurrPartNums
end

on getMyFigureData me
  global MyfigurePartList, MyfigureColorList
  repeat with c = 1 to myParts.item.count
    tmpNbr = EMPTY & x_from(currPartNums[c])
    repeat with t = 1 to 3
      if tmpNbr.length < 3 then
        tmpNbr = "0" & tmpNbr
      end if
    end repeat
    figurePartList.setaProp(myParts.item[c], myParts.item[c] & "=" & tmpNbr)
    if mag and myParts.item[c] <> "ey" then
      tCurrColorRgb = x_from(currColorRgb)
      r = integer(tCurrColorRgb.item[1])
      g = integer(tCurrColorRgb.item[2])
      b = integer(tCurrColorRgb.item[3])
      figureColorList.setaProp(myParts.item[c], r & "," & g & "," & b)
    end if
  end repeat
  if mag and addSprs <> VOID then
    repeat with c = 1 to addSprs.item.count
      figureColorList.setaProp(addParts.item[c], r & "," & g & "," & b)
    end repeat
  end if
end

on exitFrame me
  updatespr(me)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #myField, [#comment: "my Field code, which is my part in next list.", #format: #string, #default: "hr"])
  addProp(pList, #myParts, [#comment: "my Parts(fc,hd,ey...)", #format: #string, #default: "hd,ey,fc"])
  addProp(pList, #mySprs, [#comment: "All Srites, which should change (same order than above)", #format: #string, #default: "0,0"])
  addProp(pList, #mag, [#comment: "am i magnified?", #format: #boolean, #default: 0])
  addProp(pList, #myPreviewSprite, [#comment: "my preview sprite", #format: #integer, #default: 0])
  return pList
end
