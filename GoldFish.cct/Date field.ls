on keyDown me
  s = "0123456789"
  t = the key
  if offset(t, s) > 0 or t = BACKSPACE or t = TAB then
    if sprite(me.spriteNum).member.name contains "year" then
      if sprite(me.spriteNum).member.text.length <= 4 or t = BACKSPACE then
        pass()
      end if
    else
      if sprite(me.spriteNum).member.text.length <= 2 or t = BACKSPACE then
        pass()
      end if
    end if
  end if
end
