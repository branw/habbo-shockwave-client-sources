property pSprite, pRandom, pFrameCount, pCount, pAdd

on define me, tSprite
  pSprite = tSprite
  me.reset()
  return 1
end

on reset me
  pRandom = random(30)
  pSprite.member = getmemnum("twinkle_0")
  pFrameCount = 1
  pCount = 0
  pAdd = 15
  sprite(pSprite).blend = pCount
end

on update me
  pCount = pCount + pAdd
  if pRandom = 1 then
    case 1 of
      pCount >= 0 and pCount <= 100:
        sprite(pSprite).blend = pCount
      pCount > 100:
        pAdd = pAdd * -1
      pCount < 0:
        me.reset()
    end case
  else
    me.reset()
  end if
end
