property maxnum

on beginSprite me
end

on keyDown me
  if the keyCode = 48 then
    pass()
  end if
  if checkKey(me, the key) = 1 then
    pass()
  else
  end if
end

on checkKey me, x
  fname = member(the member of sprite me.spriteNum).name
  if x = BACKSPACE or charToNum(x) = 29 or charToNum(x) = 28 then
    return 1
  end if
  if x = "0" and length(field(fname)) = 0 then
    return 0
  end if
  if charToNum(x) >= 48 and charToNum(x) <= 57 and integer(field(fname) & x) <= maxnum then
    return 1
  end if
  return 0
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #maxnum, [#comment: "Max number", #format: #integer, #default: 100])
  return pList
end
