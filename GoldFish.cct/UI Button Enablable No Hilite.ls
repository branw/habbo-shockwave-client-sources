property enabled, buttonType, origmem, type
global gpUiButtons

on beginSprite me
  if voidp(gpUiButtons) then
    gpUiButtons = [:]
  end if
  setaProp(gpUiButtons, buttonType, me.spriteNum)
  if enabled then
    enable(me)
  else
    disable(me)
  end if
end

on enable me
  enabled = 1
  if type = "blend" or voidp(type) then
    sprite(me.spriteNum).blend = 100
  end if
  if type = "visible" then
    sprite(me.spriteNum).visible = 1
  end if
end

on disable me
  enabled = 0
  if type = "blend" or voidp(type) then
    sprite(me.spriteNum).blend = 30
  end if
  if type = "visible" then
    sprite(me.spriteNum).visible = 0
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #enabled, [#format: #boolean, #default: 0, #comment: "Default enabled"])
  addProp(pList, #buttonType, [#format: #string, #default: "rotate", #comment: "Type"])
  addProp(pList, #type, [#format: #string, #default: "blend", #range: ["blend", "visible"], #comment: "Enable type"])
  return pList
end
