property pDropListSpr
global gCountryDropMem

on beginSprite me
  sprite(me.spriteNum).locV = 2000
end

on SetMyLocVTo me, LocMyV
  sprite(me.spriteNum).locV = LocMyV
end

on SwapMember me
  if sprite(me.spriteNum).member.name contains "_hi" then
    sprite(me.spriteNum).member = sprite(me.spriteNum).member.name.char[1..length(sprite(me.spriteNum).member.name) - 3]
  end if
end

on ActivateDropListItem me, NowAct
  if me.spriteNum = NowAct then
    if sprite(me.spriteNum).member.name.char[length(sprite(me.spriteNum).member.name) - 2..length(sprite(me.spriteNum).member.name)] <> "_hi" then
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name & "_hi")
    end if
  else
    mname = sprite(me.spriteNum).member.name
    if mname contains "_hi" then
      sprite(me.spriteNum).castNum = getmemnum(mname.char[1..mname.length - 3])
    end if
  end if
end

on mouseWithin me
  mname = sprite(me.spriteNum).member.name
  pDropName = sprite(pDropListSpr).member.name
  if mname.char[length(mname) - 2..length(mname)] <> "_hi" then
    sendSprite(pDropListSpr + value(pDropName.char[1..1]) + 0, #SwapMember)
    sprite(me.spriteNum).castNum = getmemnum(mname & "_hi")
    sprite(pDropListSpr).castNum = getmemnum(me.spriteNum - pDropListSpr & pDropName.char[2..length(pDropName)])
  end if
end

on selectContinent me, num
  global gRegistrationManager, gCountryListSprite
  if gRegistrationManager = VOID then
    pCountryMan = new(script("Country Manager Class"))
  else
    pCountryMan = gRegistrationManager.pCountryMan
  end if
  if num < 4 then
    case num of
      1:
        countryNum = 342
      2:
        countryNum = 424
      3:
        countryNum = 405
    end case
    s = pCountryMan.getRegionList(countryNum)
    sendSprite(gCountryListSprite, #refreshRegion, pCountryMan, countryNum)
  else
    s = pCountryMan.getCountryList(num - 3)
    sendSprite(gCountryListSprite, #refreshContinent, pCountryMan, num - 3)
  end if
end

on mouseUp me
  put "mouseup"
  if sprite(me.spriteNum).member.name.char[length(sprite(me.spriteNum).member.name) - 2..length(sprite(me.spriteNum).member.name)] = "_hi" then
    gCountryDropMem = the number of member (the spriteNum of me - pDropListSpr & the name of the member of sprite(pDropListSpr).char[2..length(the name of the member of sprite(pDropListSpr))])
    repeat with f = pDropListSpr + 1 to pDropListSpr + 9
      sendSprite(f, #SetMyLocVTo, 2000)
      updateStage()
    end repeat
    me.selectContinent(member(gCountryDropMem).name.char[1])
  end if
end

on getPropertyDescriptionList me
  return [#pDropListSpr: [#comment: "pDropListSpr", #format: #integer, #default: 132]]
end
