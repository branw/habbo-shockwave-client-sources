property sex, isChange, OriginalSex, tmpEyes, isGirlEyes, allGirlEyes, isGirl

on beginSprite me
  if isChange = 1 and field("charactersex_field") <> "M" and field("charactersex_field") <> "F" and field("charactersex_field") <> "Male" and field("charactersex_field") <> "Female" then
    put "Hahmosi on liian vanha. Sukupuolta ei voitu m��ritt��. Tee hahmosi uudelleen."
    OldFigureNoSex(me)
  end if
  if field("charactersex_field") = "null" then
    member("charactersex_field").text = "Male"
  end if
  if field("charactersex_field") = "M" then
    member("charactersex_field").text = "Male"
  end if
  if field("charactersex_field") = "F" then
    member("charactersex_field").text = "Female"
  end if
  if field("charactersex_field") = "Male" then
    sendAllSprites(#mobileSexChange, "Male")
  end if
  if field("charactersex_field") = "Female" then
    sendAllSprites(#mobileSexChange, "Female")
  end if
  put field("charactersex_field")
  OriginalSex = field("charactersex_field")
end

on mouseDown me
  sendAllSprites(#mobileSexChange, sex)
  sendAllSprites(#changeMySex)
  if isChange = 1 then
    if OriginalSex = field("charactersex_field") then
      sendAllSprites(#initMeForChange)
    else
      sendAllSprites(#randomFigure)
    end if
  else
    sendAllSprites(#randomFigure)
  end if
end

on mobileSexChange me, tsex
  if tsex = sex then
    set the member of sprite the spriteNum of me to "radiobutton on"
  else
    set the member of sprite the spriteNum of me to "radiobutton off"
  end if
  put tsex into field "charactersex_field"
end

on OldFigureNoSex me
  global figurePartList
  isGirl = 0
  tmpEyes = figurePartList.ey
  the itemDelimiter = "="
  isGirlEyes = integer(tmpEyes.item[2])
  put "isGirlEyes" && isGirlEyes
  allGirlEyes = []
  the itemDelimiter = ","
  repeat with c = 1 to (field("hd_specs_female")).line.count
    allGirlEyes.add((field("hd_specs_female")).line[c].item[2])
  end repeat
  put allGirlEyes && "allGirlEyes"
  repeat with c = 1 to allGirlEyes.count
    if isGirlEyes = allGirlEyes[c] then
      isGirl = 1
    end if
  end repeat
  if isGirl then
    put "Female" into field "charactersex_field"
  else
    put "Male" into field "charactersex_field"
  end if
  put "is this silly character a girl" && isGirl
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #sex, [#comment: "Sex sex", #range: ["Male", "Female"], #format: #string, #default: "Female"])
  addProp(pList, #isChange, [#comment: "is this properties change frame", #format: #boolean, #default: 0])
  return pList
end
