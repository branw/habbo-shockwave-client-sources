property pCache

on new me
  return me
end

on construct me
  pCache = [:]
  return 1
end

on parse me, tFieldName
  if memberExists(tFieldName) then
    if listp(pCache[tFieldName]) then
      tdata = pCache[tFieldName]
    else
      if tFieldName contains ".window" then
        tdata = me.parse_window(tFieldName)
        pCache[tFieldName] = tdata
      else
        if tFieldName contains ".element" then
          tdata = me.parse_element(tFieldName)
          pCache[tFieldName] = tdata
        else
          if tFieldName contains ".room" then
            tdata = me.parse_room(tFieldName)
          else
            if tFieldName contains ".visual" then
              tdata = me.parse_room(tFieldName)
              pCache[tFieldName] = tdata
            end if
          end if
        end if
      end if
    end if
  else
    return error(me, "Member not found:" && tFieldName, #parse)
  end if
  return tdata.duplicate()
end

on parse_window me, tFieldName
  tdata = member(getResourceManager().getmemnum(tFieldName)).text
  tSupportedTags = [#elements: [#open: "<elements>", #close: "</elements>"], #rect: [#open: "<rect>", #close: "</rect>"], #border: [#open: "<border>", #close: "</border>"], #clientrect: [#open: "<clientrect>", #close: "</clientrect>"]]
  tLayDefinition = [:]
  tOpenTagFlag = 0
  tTag = EMPTY
  repeat with x = 1 to tSupportedTags.count
    tOpen = tSupportedTags[x].open
    tClose = tSupportedTags[x].close
    tTag = tSupportedTags.getPropAt(x)
    tList = []
    repeat with i = 1 to tdata.line.count
      if tdata.line[i].word[1] = tOpen then
        repeat with i = i + 1 to tdata.line.count
          tLine = tdata.line[i]
          if tLine.word[1] = tClose then
            exit repeat
          end if
          tList.add(value(tLine))
        end repeat
      end if
    end repeat
    tLayDefinition[tTag] = tList
  end repeat
  tElements = [:]
  repeat with tElem in tLayDefinition[#elements]
    if voidp(tElem[#id]) then
      tSymbol = "null"
    else
      tSymbol = tElem.id
    end if
    if voidp(tElements[tSymbol]) then
      tElements[tSymbol] = []
    end if
    tElements[tSymbol].add(tElem)
  end repeat
  repeat with tElem in tLayDefinition[#elements]
    if stringp(tElem[#txtColor]) then
      tElem[#txtColor] = rgb(tElem[#txtColor])
    end if
    if stringp(tElem[#txtBgColor]) then
      tElem[#txtBgColor] = rgb(tElem[#txtBgColor])
    end if
    if voidp(tElem[#color]) then
      tElem[#color] = "#000000"
    end if
    if voidp(tElem[#bgColor]) then
      tElem[#bgColor] = "#FFFFFF"
    end if
    tElem[#color] = rgb(tElem[#color])
    tElem[#bgColor] = rgb(tElem[#bgColor])
    tPalette = tElem[#palette]
    if stringp(tPalette) then
      if not getResourceManager().exists(tPalette && "Duplicate") then
        tPalMemNum = getResourceManager().getmemnum(tPalette)
        if tPalMemNum > 0 then
          member(tPalMemNum).duplicate(getResourceManager().createMember(tPalette && "Duplicate", #palette))
        else
          getResourceManager().createMember(tPalette && "Duplicate", #palette)
          error(me, "Palette member missing:" && tPalette, #parse_window)
        end if
      end if
      tElem[#palette] = tPalette && "Duplicate"
    end if
    if tElem[#type] = "text" then
      tFontStruct = getStructVariable("struct.font.plain")
      if voidp(tElem[#wordWrap]) then
        tElem[#wordWrap] = 1
      end if
      if voidp(tElem[#alignment]) then
        tElem[#alignment] = #left
      end if
      if voidp(tElem[#font]) then
        tElem[#font] = tFontStruct.getaProp(#font)
      end if
      if voidp(tElem[#fontSize]) then
        tElem[#fontSize] = tFontStruct.getaProp(#fontSize)
      end if
      if voidp(tElem[#fontStyle]) then
        tElem[#fontStyle] = tFontStruct.getaProp(#fontStyle)
      end if
      if voidp(tElem[#txtColor]) then
        tElem[#txtColor] = tFontStruct.getaProp(#color)
      end if
      if voidp(tElem[#txtBgColor]) then
        tElem[#txtBgColor] = rgb(255, 255, 255)
      end if
    end if
  end repeat
  if tLayDefinition[#rect].count = 0 then
    tRect = rect(10000, 10000, -10000, -10000)
    repeat with tElement in tElements
      repeat with tItem in tElement
        if tItem.locH < tRect[1] then
          tRect[1] = tItem.locH
        end if
        if tItem.locV < tRect[2] then
          tRect[2] = tItem.locV
        end if
        if tItem.locH + tItem.width > tRect[3] then
          tRect[3] = tItem.locH + tItem.width
        end if
        if tItem.locV + tItem.height > tRect[4] then
          tRect[4] = tItem.locV + tItem.height
        end if
      end repeat
    end repeat
    tLayDefinition[#rect].add(tRect)
    repeat with tElement in tElements
      repeat with tItem in tElement
        tItem.locH = tItem.locH - tRect[1]
        tItem.locV = tItem.locV - tRect[2]
      end repeat
    end repeat
  else
    tList = tLayDefinition[#rect][1]
    tLayDefinition[#rect][1] = rect(tList[1], tList[2], tList[3], tList[4])
  end if
  tOffX = tLayDefinition[#rect][1][1]
  tOffY = tLayDefinition[#rect][1][2]
  tLayDefinition[#rect][1] = tLayDefinition[#rect][1] - [tOffX, tOffY, tOffX, tOffY]
  if tLayDefinition[#border].count = 0 then
    if tLayDefinition[#clientrect].count > 0 then
      tClientRect = tLayDefinition[#clientrect][1]
      tWinWidth = tLayDefinition[#rect][1][3]
      tWinHeight = tLayDefinition[#rect][1][4]
      tBorder = [tClientRect[1], tClientRect[2], tWinWidth - tClientRect[3], tWinHeight - tClientRect[4]]
      tLayDefinition[#border].add(tBorder)
    else
      tLayDefinition[#border].add([0, 0, 0, 0])
    end if
  end if
  tLayDefinition[#elements] = tElements
  return tLayDefinition
end

on parse_element me, tFieldName
  tCasts = []
  tProps = [:]
  tdata = member(getResourceManager().getmemnum(tFieldName)).text
  repeat with f = 1 to tdata.line.count
    tLine = tdata.line[f]
    if tLine.char[1] <> "#" then
      if tLine.char[1] = ">" then
        tCasts.add(tLine.char[2..length(tLine)])
        next repeat
      end if
      if length(tLine) > 1 then
        tProps.addProp(value(tLine)[1], value(tLine))
      end if
    end if
  end repeat
  return [#casts: tCasts, #props: tProps]
end

on parse_room me, tFieldName
  tdata = member(getResourceManager().getmemnum(tFieldName)).text
  tSupportedTags = [#roomdata: [#open: "<roomdata>", #close: "</roomdata>"], #rect: [#open: "<rect>", #close: "</rect>"], #version: [#open: "<version>", #close: "</version>"], #elements: [#open: "<elements>", #close: "</elements>"]]
  tLayDefinition = [:]
  tOpenTagFlag = 0
  tTag = EMPTY
  repeat with x = 1 to tSupportedTags.count
    tOpen = tSupportedTags[x].open
    tClose = tSupportedTags[x].close
    tTag = tSupportedTags.getPropAt(x)
    tList = []
    repeat with i = 1 to tdata.line.count
      if tdata.line[i].word[1] = tOpen then
        repeat with i = i + 1 to tdata.line.count
          if tdata.line[i].word[1] = tClose then
            exit repeat
          end if
          if not voidp(value(tdata.line[i])) then
            tList.add(value(tdata.line[i]))
          end if
        end repeat
      end if
    end repeat
    if tList.count > 0 then
      tLayDefinition[tTag] = tList
    end if
  end repeat
  if voidp(tLayDefinition[#version]) then
    error(me, "Old visualizer definition:" && tFieldName, #parse_room)
    repeat with tElem in tLayDefinition[#elements]
      if tElem[#media] = #field or tElem[#media] = #text then
        tElem[#txtColor] = tElem[#color]
        tElem[#txtBgColor] = tElem[#bgColor]
        tElem[#color] = "#000000"
        tElem[#bgColor] = "#FFFFFF"
      end if
      tElem.deleteProp(#foreColor)
      tElem.deleteProp(#backColor)
    end repeat
  end if
  repeat with tElem in tLayDefinition[#elements]
    if voidp(tElem[#color]) then
      tElem[#color] = "#000000"
    end if
    if voidp(tElem[#bgColor]) then
      tElem[#bgColor] = "#FFFFFF"
    end if
    if tElem[#type] = "button" then
      tElem[#Active] = 1
    end if
  end repeat
  return [#name: tLayDefinition[#name], #roomdata: tLayDefinition[#roomdata], #rect: tLayDefinition[#rect], #elements: tLayDefinition[#elements]]
end
