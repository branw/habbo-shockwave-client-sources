global gFlatQueryButtonSpr, gTop10SearchSprite

on keyDown me
  if gFlatQueryButtonSpr > 0 then
    if (field("flatquery")).length > 1 then
      sendSprite(gFlatQueryButtonSpr, #enable)
    else
      sendSprite(gFlatQueryButtonSpr, #disable)
    end if
  end if
  if the key = RETURN then
    sendSprite(gTop10SearchSprite, #disable)
    if (field("flatquery")).length > 1 then
      put field("flatquery")
      sendEPFuseMsg("SEARCHFLAT" && "/%" & field("flatquery") & "%")
      gotoFrame("private_places")
    end if
  else
    pass()
  end if
end

on beginSprite me
  if gFlatQueryButtonSpr > 0 then
    if (field("flatquery")).length > 1 then
      sendSprite(gFlatQueryButtonSpr, #enable)
    else
      sendSprite(gFlatQueryButtonSpr, #disable)
    end if
  end if
end
