property part, pieceName, shadowed
global gWallsAndFloor

on beginSprite me
  iSpr = me.spriteNum
  if gWallsAndFloor = VOID then
    gWallsAndFloor = [#wallPattern: 1, #wallColor: 1, #floorPattern: 1, #floorColor: 1, #wallSprites: [], #floorSprites: []]
  end if
  put getaProp(gWallsAndFloor, symbol(part & "Sprites"))
  add(getaProp(gWallsAndFloor, symbol(part & "Sprites")), me.spriteNum)
  pieceNameWhole = (the member of sprite iSpr).name
  save = the itemDelimiter
  the itemDelimiter = "_"
  pieceName = item 2 of pieceNameWhole
  the itemDelimiter = save
  update(me)
end

on update me
  iSpr = me.spriteNum
  save = the itemDelimiter
  the itemDelimiter = ","
  dataFieldName = line getaProp(gWallsAndFloor, symbol(part & "Pattern")) of the text of member(part & "pattern_patterns")
  fieldData = member(dataFieldName).text
  patternName = item 1 of line getaProp(gWallsAndFloor, symbol(part & "Color")) of fieldData
  colorR = integer(item 3 of line getaProp(gWallsAndFloor, symbol(part & "Color")) of fieldData)
  colorG = integer(item 4 of line getaProp(gWallsAndFloor, symbol(part & "Color")) of fieldData)
  colorB = integer(item 5 of line getaProp(gWallsAndFloor, symbol(part & "Color")) of fieldData)
  if shadowed = 1 then
    colorR = colorR * 0.90000000000000002
    colorG = colorG * 0.90000000000000002
    colorB = colorB * 0.90000000000000002
    sprite(iSpr).bgColor = rgb(colorR, colorG, colorB)
  else
    sprite(iSpr).bgColor = rgb(colorR, colorG, colorB)
  end if
  set the member of sprite iSpr to patternName & "_" & pieceName
  set the width of sprite iSpr to member(patternName & "_" & pieceName).width
  set the height of sprite iSpr to member(patternName & "_" & pieceName).height
  paletteName = item 2 of line getaProp(gWallsAndFloor, symbol(part & "Color")) of fieldData
  member(patternName & "_" & pieceName).palette = member(paletteName)
  the itemDelimiter = save
end

on getPropertyDescriptionList me
  return [#part: [#comment: "Part", #format: #string, #default: "wall"], #shadowed: [#comment: "shadowed?", #format: #boolean, #default: "false"]]
end
