property ancestor, pLogoSpr

on new me
  return me
end

on construct me
  return 1
end

on deconstruct me
  return me.hideLogo()
end

on showLogo me
  if memberExists("Sulake Logo") then
    tMember = member(getmemnum("Sulake Logo"))
    pLogoSpr = sprite(reserveSprite(me.getID()))
    pLogoSpr.ink = 36
    pLogoSpr.blend = 60
    pLogoSpr.member = tMember
    pLogoSpr.locZ = -20000001
    pLogoSpr.loc = point((the stage).rect.width / 2, (the stage).rect.height / 2 - tMember.height)
  end if
  return 1
end

on hideLogo me
  if not voidp(pLogoSpr) then
    releaseSprite(pLogoSpr.spriteNum)
    pLogoSpr = VOID
  end if
  return 1
end
