global gCountryPrefix

on beginSprite me
  if gCountryPrefix = "ch" then
    tName = sprite(me.spriteNum).member.name
    sprite(me.spriteNum).castNum = getmemnum(tName.word[1] && "ch")
  end if
end
