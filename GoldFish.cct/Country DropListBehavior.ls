property pCountryDropStatus, UpdPopularTime
global gCountryDropMem, gChosenCountry, gChosenContinent

on beginSprite me
  if gChosenCountry <> VOID then
    sel = integer(gChosenContinent + 3)
    case gChosenCountry of
      342:
        sel = 1
      424:
        sel = 2
      405:
        sel = 3
    end case
    gCountryDropMem = getmemnum(sel & ".item.DropList.Country")
    pCountryDropStatus = 1
  end if
  if pCountryDropStatus = VOID then
    if pCountryDropStatus = VOID then
      gCountryDropMem = sprite(me.spriteNum).member.name
    end if
    DropListItemA = me.spriteNum + value(sprite(me.spriteNum).member.name.char[1..1]) + 1
    sprite(me.spriteNum).member = member(the number of member gCountryDropMem)
    pCountryDropStatus = 0
  else
    sprite(me.spriteNum).member = gCountryDropMem
  end if
end

on mouseDown me
  pCountryDropStatus = 1
  DropListV = value(sprite(me.spriteNum).member.name.char[1..1]) * 17 + sprite(me.spriteNum).height / 2 + 1
  nextItemV = 0
  repeat with f = me.spriteNum + 1 to me.spriteNum + 9
    sendSprite(f, #ActivateDropListItem, integer(me.spriteNum + sprite(me.spriteNum).member.name.char[1..1] + 0))
    sendSprite(f, #SetMyLocVTo, sprite(me.spriteNum).locV - DropListV + nextItemV + value(sprite(me.spriteNum).member.name.char[1..1]))
    nextItemV = nextItemV + sprite(me.spriteNum + 1).height
  end repeat
  waitAmom = the timer + 10
  repeat while waitAmom > the timer
    nothing()
  end repeat
end
