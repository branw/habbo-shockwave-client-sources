property catName, pBlink, pBlinkStartTime, pClicked, pLastBlink
global gNoOfStuff, gIAmOwner

on beginSprite me
  pBlink = 0
  pClicked = 0
  pBlinkStartTime = the milliSeconds
end

on exitFrame me
  if voidp(gNoOfStuff) then
    return 
  else
    if gNoOfStuff = 0 and gIAmOwner = 1 then
      pBlink = 1
    else
      pBlink = 0
    end if
  end if
  if pClicked or the milliSeconds - pBlinkStartTime > 10000 then
    pBlink = 0
  end if
  if pBlink = 0 and sprite(me.spriteNum).member.name = "brochure_btn_hi" then
    sprite(me.spriteNum).castNum = getmemnum("brochure_btn")
  end if
  if pBlink and the milliSeconds - pLastBlink > 250 then
    if sprite(me.spriteNum).member.name = "brochure_btn_hi" then
      sprite(me.spriteNum).castNum = getmemnum("brochure_btn")
    else
      sprite(me.spriteNum).castNum = getmemnum("brochure_btn_hi")
    end if
    pLastBlink = the milliSeconds
  end if
end

on mouseDown me
  global whichIsFirstNow, MaxVisibleIndexButton, openCatalog
  if the movieName contains "private" then
    openCatalog = 1
    whichIsFirstNow = 1
    MaxVisibleIndexButton = 8
    openCatalog(catName)
    pClicked = 1
  else
    beep(1)
  end if
end

on getPropertyDescriptionList me
  return [#catName: [#comment: "catalog name", #format: #string, #default: "basicA"]]
end

on mouseEnter me
  if the movieName contains "private" then
    helpText_setText(AddTextToField("OpenCatalog"))
  else
    helpText_setText(AddTextToField("CatalogWorksOnlyYourOwnRoom"))
  end if
end

on mouseLeave me
  if the movieName contains "private" then
    helpText_empty(AddTextToField("OpenCatalog"))
  else
    helpText_empty(AddTextToField("CatalogWorksOnlyYourOwnRoom"))
  end if
end
