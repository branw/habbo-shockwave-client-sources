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
    sendSprite(pDropListSpr + value(pDropName.char[1..offset(".", pDropName) - 1]) + 0, #SwapMember)
    sprite(me.spriteNum).castNum = getmemnum(mname & "_hi")
    sprite(pDropListSpr).castNum = getmemnum(me.spriteNum - pDropListSpr & pDropName.char[offset(".", pDropName)..length(pDropName)])
  end if
end

on selectContinent me, num
  global gRegistrationManager, gCountryListSprite
  if gRegistrationManager = VOID then
    pCountryMan = new(script("Country Manager Class"))
  else
    pCountryMan = gRegistrationManager.pCountryMan
  end if
  if num < 5 then
    case num of
      1:
        countryNum = 340
      2:
        countryNum = 342
      3:
        countryNum = 424
      4:
        countryNum = 405
    end case
    s = pCountryMan.getRegionList(countryNum)
    sendSprite(gCountryListSprite, #refreshRegion, pCountryMan, countryNum)
  else
    s = pCountryMan.getCountryList(num - 4)
    sendSprite(gCountryListSprite, #refreshContinent, pCountryMan, num - 4)
  end if
end

on mouseUp me
  put "mouseup"
  if sprite(me.spriteNum).member.name.char[length(sprite(me.spriteNum).member.name) - 2..length(sprite(me.spriteNum).member.name)] = "_hi" then
    cName = sprite(pDropListSpr).member.name
    mname = me.spriteNum - pDropListSpr & cName.char[offset(".", cName)..length(cName)]
    gCountryDropMem = getmemnum(mname)
    repeat with f = pDropListSpr + 1 to pDropListSpr + 1000
      sendSprite(f, #SetMyLocVTo, 2000)
      updateStage()
    end repeat
    tName = member(gCountryDropMem).name
    the itemDelimiter = "."
    tNum = tName.item[1]
    the itemDelimiter = ","
    me.selectContinent(tNum)
  end if
end

on getPropertyDescriptionList me
  return [#pDropListSpr: [#comment: "pDropListSpr", #format: #integer, #default: 132]]
end
