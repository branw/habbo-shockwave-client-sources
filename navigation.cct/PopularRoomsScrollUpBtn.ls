property Active
global FirstPlaceNow, SrollDirection

on beginSprite me
  Active = 1
end

on mouseDown me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_Up_active_hi"
  end if
end

on mouseUp me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_Up_active"
    FirstPlaceNow = FirstPlaceNow - 11
    put FirstPlaceNow
    if FirstPlaceNow < 0 then
      FirstPlaceNow = 0
    end if
    sendEPFuseMsg("SEARCHBUSYFLATS /" & FirstPlaceNow & ",11")
  else
    sprite(me.spriteNum).member = "scroll_Up_inactive"
  end if
end
