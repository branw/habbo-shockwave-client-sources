property pContinentList, pCountryList, pWriterObj, pWriterObjID, pWriterObjUnderLine, pWriterObjUnderLineID, pLineHeight, pSelection, pImgBuffer

on construct me
  pContinentList = [:]
  pCountryList = [:]
  pLineHeight = getStructVariable("struct.font.plain").getaProp(#lineHeight)
  pSelection = [#number: 0, #name: VOID, #continent: VOID]
  pImgBuffer = VOID
  tDelim = the itemDelimiter
  the itemDelimiter = ":"
  if memberExists("char_continent_list") then
    tStr = member(getmemnum("char_continent_list")).text
    repeat with i = 1 to tStr.line.count
      tLine = tStr.line[i]
      if tLine <> EMPTY then
        if tLine.char[1] <> "#" then
          pContinentList.addProp(tLine.item[2], [#number: integer(tLine.item[1]), #type: symbol(tLine.item[3])])
        end if
      end if
    end repeat
  else
    error(me, "Continent list not found!", #construct)
  end if
  if memberExists("char_country_list") then
    tStr = member(getmemnum("char_country_list")).text
    repeat with i = 1 to tStr.line.count
      tLine = tStr.line[i]
      if tLine <> EMPTY then
        if tLine.char[1] <> "#" then
          tNumber = integer(tLine.item[1])
          tContID = integer(tLine.item[2])
          tName = tLine.item[3]
          tStruct = pCountryList.getaProp(tContID)
          if voidp(tStruct) then
            tStruct = []
            pCountryList.setaProp(tContID, tStruct)
          end if
          tStruct.add([#number: tNumber, #name: tName])
        end if
      end if
    end repeat
  else
    error(me, "Country list not found!", #construct)
  end if
  the itemDelimiter = tDelim
  repeat with i = 1 to pContinentList.count
    createText("char_cont_" & i, pContinentList.getPropAt(i))
  end repeat
  pWriterObjID = me.getID() && the milliSeconds
  tMetrics = getStructVariable("struct.font.plain")
  createWriter(pWriterObjID, tMetrics)
  pWriterObj = getWriter(pWriterObjID)
  pWriterObjUnderLineID = me.getID() && "underline" && the milliSeconds
  tMetrics = getStructVariable("struct.font.link")
  createWriter(pWriterObjUnderLineID, tMetrics)
  pWriterObjUnderLine = getWriter(pWriterObjUnderLineID)
  return 1
end

on deconstruct me
  pContinentList = [:]
  pCountryList = [:]
  if objectp(pWriterObj) then
    removeWriter(pWriterObjID)
    pWriterObj = VOID
  end if
  if objectp(pWriterObjUnderLine) then
    removeWriter(pWriterObjUnderLineID)
    pWriterObjUnderLine = VOID
  end if
  return 1
end

on getContinentData me, tContinent
  return pContinentList[tContinent]
end

on getSelectedCountryID me
  return pSelection[#number]
end

on getCountryList me, tContinentKey
  tContinent = getText(tContinentKey)
  if stringp(tContinent) then
    if voidp(pContinentList[tContinent]) then
      return []
    end if
    tContNum = pContinentList[tContinent].number
  else
    if voidp(pCountryList.getaProp(tContinent)) then
      return []
    end if
    tContNum = tContinent
  end if
  tStr = EMPTY
  tList = pCountryList.getaProp(tContNum)
  if voidp(tList) then
    return [:]
  else
    return tList
  end if
end

on getCountryListStr me, tContinentKey
  tContinent = getText(tContinentKey)
  if stringp(tContinent) then
    if voidp(pContinentList[tContinent]) then
      return EMPTY
    end if
    tContNum = pContinentList[tContinent].number
  else
    if voidp(pCountryList.getaProp(tContinent)) then
      return EMPTY
    end if
    tContNum = tContinent
  end if
  tStr = EMPTY
  tList = pCountryList.getaProp(tContNum)
  if voidp(tList) then
    return EMPTY
  end if
  repeat with tItem in tList
    if length(tStr) > 0 then
      tStr = tStr & RETURN
    end if
    tStr = tStr & tItem.name
  end repeat
  return tStr
end

on getCountryListImg me, tContinentKey
  tContinent = getText(tContinentKey)
  if pSelection[#continent] <> tContinent or voidp(pImgBuffer) then
    pImgBuffer = pWriterObj.render(me.getCountryListStr(tContinentKey)).duplicate()
    pSelection = [#number: 0, #name: VOID, #continent: VOID]
  end if
  return pImgBuffer
end

on getNthCountryNum me, tNth, tContinentKey
  tContinent = getText(tContinentKey)
  if stringp(tContinent) then
    tContNum = pContinentList[tContinent].number
  else
    tContNum = tContinent
  end if
  if tNth > pCountryList.getaProp(tContNum).count then
    return 0
  end if
  return pCountryList.getaProp(tContNum)[tNth].number
end

on getNthCountryName me, tNth, tContinentKey
  tContinent = getText(tContinentKey)
  if voidp(pContinentList[tContinent]) then
    return 0
  end if
  if stringp(tContinent) then
    tContNum = pContinentList[tContinent].number
  else
    tContNum = tContinent
  end if
  if tNth > pCountryList.getaProp(tContNum).count then
    return 0
  end if
  return pCountryList.getaProp(tContNum)[tNth].name
end

on getCountryOrderNum me, tCountry, tContinentKey
  tContinent = getText(tContinentKey)
  if voidp(pContinentList[tContinent]) then
    return 0
  end if
  if stringp(tContinent) then
    tContNum = pContinentList[tContinent].number
  else
    tContNum = tContinent
  end if
  tCountryList = pCountryList.getaProp(tContNum)
  if listp(tCountryList) then
    repeat with i = 1 to tCountryList.count
      if tCountryList[i].name = tCountry then
        return i
      end if
    end repeat
  end if
end

on getClickedLineNum me, tpoint
  tLine = tpoint.locV / pLineHeight
  if tpoint.locV mod pLineHeight > 0 then
    tLine = tLine + 1
  end if
  if tLine < 1 then
    tLine = 1
  end if
  return tLine
end

on selectCountry me, tCountryName, tContinentKey
  tContinent = getText(tContinentKey)
  if not voidp(pSelection[#name]) then
    me.unselectCountry(pSelection[#name], tContinentKey)
  end if
  tImg = pWriterObjUnderLine.render(tCountryName)
  tPos = me.getCountryOrderNum(tCountryName, tContinentKey)
  pSelection = [#number: me.getNthCountryNum(tPos, tContinentKey), #name: tCountryName, #continent: tContinent]
  tY = tPos * pLineHeight - pLineHeight
  pImgBuffer.copyPixels(tImg, rect(0, tY, tImg.width, tY + tImg.height), tImg.rect)
  return 1
end

on unselectCountry me, tCountryName, tContinentKey
  tContinent = getText(tContinentKey)
  if tContinent <> pSelection[#continent] then
    return 0
  end if
  tImg = pWriterObj.render(tCountryName)
  tPos = me.getCountryOrderNum(tCountryName, tContinentKey)
  pSelection[#name] = VOID
  pSelection[#number] = VOID
  tY = tPos * pLineHeight - pLineHeight
  pImgBuffer.copyPixels(tImg, rect(0, tY, tImg.width, tY + tImg.height), tImg.rect)
  return 1
end
