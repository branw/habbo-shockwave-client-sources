property pSprite, areaWidth, areaHeight, V, vm, pMuutos, pMuutos2, pKeskipiste, pMaksimi, pFromLeft

on beginSprite me
  pSprite = sprite(me.spriteNum)
  areaWidth = 20
  areaHeight = 220
  pKeskipiste = pSprite.width + (random(areaWidth) - pSprite.width)
  V = random(areaHeight)
  vm = random(3)
  pMuutos = random(10)
  pMuutos2 = random(10)
  pMaksimi = (areaWidth - (areaWidth - pKeskipiste)) / 2
  pFromLeft = 310
end

on exitFrame me
  pMuutos = pMuutos + 7
  pSprite.locH = pFromLeft + pKeskipiste - pMaksimi * sin(pMuutos * PI / 180) * sin(pMuutos2 * PI / 180)
  pSprite.locV = V
  V = V - vm
  if V <= -pSprite.height then
    replace(me)
  end if
end

on replace me
  V = areaHeight
  vm = random(3)
  pKeskipiste = pSprite.width + (random(areaWidth) - pSprite.width)
  pMuutos = random(10)
  pMuutos2 = random(20)
  pMaksimi = (areaWidth - (areaWidth - pKeskipiste)) / 2
end
