global gFlatQueryButtonSpr, gTop10SearchSprite

on beginSprite me
  gFlatQueryButtonSpr = me.spriteNum
end

on mouseUp
  if (field("flatquery")).length > 1 then
    put field("flatquery")
    sendSprite(gTop10SearchSprite, #disable)
    sendEPFuseMsg("SEARCHFLAT" && "/%" & line 1 of field "flatquery" & "%")
  end if
end

on disable me
  sprite(me.spriteNum).blend = 30
end

on enable me
  sprite(me.spriteNum).blend = 100
end
