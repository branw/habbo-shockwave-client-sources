property command
global MeDancing

on beginSprite me
  MeDancing = 0
end

on mouseUp me
  if not MeDancing then
    sendFuseMsg("STOP CarryDrink")
    sendFuseMsg("STOP CarryFood")
    sendFuseMsg("Dance")
    set the member of sprite the spriteNum of me to "stopdance_btn active"
    MeDancing = 1
  else
    sendFuseMsg("STOP Dance")
    set the member of sprite the spriteNum of me to "dance_btn active"
    MeDancing = 0
  end if
end

on exitFrame me
  global gMyName, gUserSprites, gpObjects
  if objectp(getaProp(gUserSprites, getaProp(gpObjects, gMyName))) then
    if getaProp(gUserSprites, getaProp(gpObjects, gMyName)).dancing then
      set the member of sprite the spriteNum of me to "stopdance_btn active"
      MeDancing = 1
    else
      set the member of sprite the spriteNum of me to "dance_btn active"
      MeDancing = 0
    end if
  end if
end

on mouseWithin me
  if the mouseDown and word 2 of the name of the member of sprite(the spriteNum of me) = "active" then
    if word 2 of the name of the member of sprite(the spriteNum of me) = "active" then
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "hi")
    end if
  end if
end

on mouseLeave me
  if word 2 of the name of the member of sprite(the spriteNum of me) = "hi" then
    sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "active")
  end if
end
