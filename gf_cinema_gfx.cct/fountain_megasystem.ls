property pSprite, freem, fraim

on beginSprite me
  pSprite = sprite(me.spriteNum)
  freem = random(10)
  lasta = random(10)
end

on exitFrame me
  fraim = fraim + 1
  if fraim = 2 then
    freem = random(10)
    pSprite.member = getmemnum("fount" & freem)
    fraim = 0
  end if
end
