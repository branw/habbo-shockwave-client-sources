property fontName, size

on beginSprite me
  member(sprite(me.spriteNum).member).font = fontName
  member(sprite(me.spriteNum).member).fontSize = size
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #fontName, [#comment: "FontName", #format: #string, #default: "Volter (goldfish)"])
  addProp(pList, #size, [#comment: "size", #format: #integer, #default: 9])
  return pList
end
