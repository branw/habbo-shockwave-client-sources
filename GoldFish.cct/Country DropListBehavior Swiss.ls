property pCountryDropStatus, UpdPopularTime
global gCountryDropMem, gChosenCountry, gChosenContinent

on beginSprite me
  if gChosenCountry <> VOID then
    sel = integer(gChosenContinent + 4)
    case gChosenCountry of
      340:
        sel = 1
      342:
        sel = 2
      424:
        sel = 3
      405:
        sel = 4
    end case
    gCountryDropMem = getmemnum(sel & ".item.DropList.Country")
    pCountryDropStatus = 1
  end if
  if pCountryDropStatus = VOID then
    if pCountryDropStatus = VOID then
      gCountryDropMem = sprite(me.spriteNum).member.name
    end if
    the itemDelimiter = "."
    num = sprite(me.spriteNum).member.name.item[1]
    the itemDelimiter = ","
    DropListItemA = me.spriteNum + value(num) + 1
    sprite(me.spriteNum).member = member(the number of member gCountryDropMem)
    pCountryDropStatus = 0
  else
    sprite(me.spriteNum).member = gCountryDropMem
  end if
end

on mouseDown me
  pCountryDropStatus = 1
  the itemDelimiter = "."
  num = sprite(me.spriteNum).member.name.item[1]
  the itemDelimiter = ","
  DropListV = value(num) * 17 + sprite(me.spriteNum).height / 2 + 1
  nextItemV = 0
  repeat with f = me.spriteNum + 1 to me.spriteNum + 10
    sendSprite(f, #ActivateDropListItem, integer(me.spriteNum + (num + 0)))
    sendSprite(f, #SetMyLocVTo, sprite(me.spriteNum).locV - DropListV + nextItemV + value(num))
    nextItemV = nextItemV + sprite(me.spriteNum + 1).height
  end repeat
  waitAmom = the timer + 10
  repeat while waitAmom > the timer
    nothing()
  end repeat
end
