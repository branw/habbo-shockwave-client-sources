property pWaitTime, pPaletteNum, pMaxPaletteNum

on beginSprite me
  pWaitTime = 10000 + the milliSeconds
  pPaletteNum = 1
end

on exitFrame me
  if the milliSeconds > pWaitTime then
    pPaletteNum = pPaletteNum + 1
    if pPaletteNum > 2 then
      pPaletteNum = 1
    end if
    pWaitTime = random(2500) + the milliSeconds
    sprite(me.spriteNum).member.paletteRef = member(getmemnum("Main_Palette_flicker_" & pPaletteNum))
  end if
end
