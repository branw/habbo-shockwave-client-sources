property startPointX, pSprite, animFrame, pSpeed

on beginSprite me
  pSprite = me.spriteNum
  rndm = random(startPointX)
  if rndm mod 2 <> 0 then
    rndm = rndm - 1
  end if
  sprite(pSprite).locH = rndm
  sprite(pSprite).locV = (startPointX - rndm) / 2
  pSpeed = random(3) - 1
  rnd = random(5)
  sprite(pSprite).member = "pilvi" & rnd
end

on enterFrame me
  animFrame = animFrame + 1
  if animFrame mod pSpeed = 0 then
    sprite(pSprite).locH = sprite(pSprite).locH - 1
    if sprite(pSprite).locH mod 2 = 0 then
      sprite(pSprite).locV = sprite(pSprite).locV + 1
    end if
    if sprite(pSprite).locH < -45 then
      initCloud(me)
    end if
  end if
end

on initCloud me
  sprite(pSprite).locH = startPointX
  sprite(pSprite).locV = -34
  rnd = random(5)
  sprite(pSprite).member = "pilvi" & rnd
  pSpeed = random(3) - 1
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #startPointX, [#format: #integer, #default: "332", #comment: "startPointX"])
  return pList
end
