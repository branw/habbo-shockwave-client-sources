property lastSearch

on beginSprite me
  the keyboardFocusSprite = me.spriteNum
end

on exitFrame me
  if voidp(lastSearch) then
    lastSearch = EMPTY
  end if
  if the keyboardFocusSprite <> me.spriteNum then
    if (field("charactername_field")).length < 3 then
      lastSearch = EMPTY
      ShowAlert("YourNameIstooShort")
      member("charactername_field").text = EMPTY
      the keyboardFocusSprite = me.spriteNum
      return 
    end if
    if field("charactername_field") <> lastSearch and (field("charactername_field")).length > 0 then
      sendEPFuseMsg("FINDUSER" && field("charactername_field"))
      sendEPFuseMsg("APPROVENAME" && field("charactername_field"))
      lastSearch = field("charactername_field")
    end if
  else
    lastSearch = EMPTY
  end if
end

on endSprite me
  sendEPFuseMsg("FINDUSER" && field("charactername_field"))
end

on keyDown me
  s = member("permittedNameChars").text
  repeat with f = 1 to s.line.count
    if the key = s.line[f].char[1..1] then
      pass()
      exit repeat
    end if
  end repeat
  if the key = BACKSPACE or the key = TAB and (field("charactername_field")).length > 0 then
    pass()
  end if
  put the key
end
