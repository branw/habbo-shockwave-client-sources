property pWallPatterns, pWallDefined, pWallModel, pFloorPatterns, pFloorDefined, pFloorModel

on construct me
  pWallPatterns = field("wallpattern_patterns")
  pFloorPatterns = field("floorpattern_patterns")
  pWallDefined = 0
  pFloorDefined = 0
  pWallModel = string(getVariable("room.default.wall", "201"))
  pFloorModel = string(getVariable("room.default.floor", "203"))
  return 1
end

on prepare me
  if not pWallDefined then
    me.setWallPaper(pWallModel)
  end if
  if not pFloorDefined then
    me.setFloorPattern(pFloorModel)
  end if
  return 1
end

on setProperty me, tKey, tValue
  case tKey of
    "wallpaper":
      return me.setWallPaper(tValue)
    "floor":
      return me.setFloorPattern(tValue)
  end case
end

on setWallPaper me, tIndex
  tField = pWallPatterns.line[integer(tIndex.char[1..length(tIndex) - 2])]
  if tField = EMPTY then
    return error(me, "Invalid wall color index:" && tIndex, #setWallPaper)
  end if
  if not memberExists(tField) then
    error(me, "Invalid wall color index:" && tIndex, #setWallPaper)
    return me.setWallPaper(string(getVariable("room.default.wall")))
  end if
  tmodel = field(tField)
  tPattern = tmodel.line[integer(tIndex.char[length(string(tIndex)) - 1..length(string(tIndex))])]
  if tPattern = EMPTY then
    return error(me, "Invalid wall color index:" && tIndex, #setWallPaper)
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.item[1]
  tPalette = tPattern.item[2]
  tR = integer(tPattern.item[3])
  tG = integer(tPattern.item[4])
  tB = integer(tPattern.item[5])
  tColor = rgb(tR, tG, tB)
  tColors = ["left": tColor - rgb(16, 16, 16), "right": tColor, "a": tColor - rgb(16, 16, 16), "b": tColor]
  the itemDelimiter = "_"
  tPieceList = getThread(#room).getComponent().getPassiveObject(#list)
  if tPieceList.count = 0 then
    pWallModel = tIndex
    pWallDefined = 0
    return 0
  end if
  repeat with tPiece in tPieceList
    tSprList = tPiece.getSprites()
    repeat with tSpr in tSprList
      tdir = tSpr.member.name.item[1]
      tName = tSpr.member.name.item[2]
      tdata = tSpr.member.name.char[length(tSpr.member.name) - 7..length(tSpr.member.name)]
      tColor = tdir
      if tColor = "corner" then
        if tdata.char[2] = "a" then
          tColor = "right"
        else
          tColor = "left"
        end if
      end if
      if memberExists(tdir & "_" & tName & "_" & ttype & tdata) then
        tSpr.member = member(getmemnum(tdir & "_" & tName & "_" & ttype & tdata))
        tSpr.bgColor = tColors[tColor]
        tSpr.member.paletteRef = member(getmemnum(tPalette))
        if pWallDefined = 0 then
          tSpr.locZ = tSpr.locZ - 975
        end if
        if tSpr.blend = 100 then
          tSpr.ink = 41
        end if
        next repeat
      end if
      error(me, "Wall member not found:" && tdir & "_" & tName & "_" & ttype & tdata, #setWallPaper)
    end repeat
  end repeat
  the itemDelimiter = tDelim
  pWallDefined = 1
  return 1
end

on setFloorPattern me, tIndex
  tField = pFloorPatterns.line[integer(tIndex.char[1..length(tIndex) - 2])]
  if tField = EMPTY then
    return error(me, "Invalid floor color index:" && tIndex, #setFloorPattern)
  end if
  if not memberExists(tField) then
    error(me, "Invalid floor color index:" && tIndex, #setFloorPatterns)
    return me.setFloorPattern(string(getVariable("room.default.floor")))
  end if
  tmodel = field(tField)
  tPattern = tmodel.line[integer(tIndex.char[length(string(tIndex)) - 1..length(string(tIndex))])]
  if tPattern = EMPTY then
    return error(me, "Invalid floor color index:" && tIndex, #setFloorPattern)
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.item[1]
  tPalette = tPattern.item[2]
  tR = integer(tPattern.item[3])
  tG = integer(tPattern.item[4])
  tB = integer(tPattern.item[5])
  tColor = rgb(tR, tG, tB)
  if not getThread(#room).getInterface().getRoomVisualizer() then
    pFloorModel = tIndex
    pFloorDefined = 0
    return 0
  end if
  tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
  tPieceId = 1
  tSpr = tVisualizer.getSprById("floor" & tPieceId)
  repeat while not (tSpr = 0)
    tMemNum = getmemnum("floor" & ttype & tSpr.member.name.char[7..tSpr.member.name.length])
    if tMemNum > 0 then
      tSpr.member = member(tMemNum)
    end if
    tSpr.bgColor = tColor
    tSpr.member.paletteRef = member(getmemnum(tPalette))
    tSpr.ink = 41
    tSpr.locZ = tSpr.locZ - 1000000
    tPieceId = tPieceId + 1
    tSpr = tVisualizer.getSprById("floor" & tPieceId)
  end repeat
  the itemDelimiter = tDelim
  pFloorDefined = 1
  return 1
end
