global gPrivateDropStatus, gPrivateDropMem, NaviPrivateSearchSpr, gDropListSpr, UpdPopularTime

on beginSprite me
  if gPrivateDropStatus = VOID then
    gDropListSpr = me.spriteNum
    if gPrivateDropStatus = VOID then
      gPrivateDropMem = sprite(me.spriteNum).member.name
    end if
    DropListItemA = me.spriteNum + value(sprite(me.spriteNum).member.name.char[1..1]) + 1
    sprite(me.spriteNum).member = member(the number of member gPrivateDropMem)
    gPrivateDropStatus = 0
    member(getmemnum("flatquery")).text = EMPTY
    UpdPopularTime = the ticks + 10 * 60
  else
    sprite(me.spriteNum).member = gPrivateDropMem
  end if
end

on mouseDown me
  gPrivateDropStatus = 1
  DropListV = value(sprite(me.spriteNum).member.name.char[1..1]) * 17 + sprite(me.spriteNum).height / 2 + 1
  nextItemV = 0
  repeat with f = me.spriteNum + 1 to me.spriteNum + 5
    sendSprite(f, #ActivateDropListItem, integer(me.spriteNum + sprite(me.spriteNum).member.name.char[1..1] + 1))
    sendSprite(f, #SetMyLocVTo, sprite(me.spriteNum).locV - DropListV + nextItemV + value(sprite(me.spriteNum).member.name.char[1..1]))
    nextItemV = nextItemV + sprite(me.spriteNum + 1).height
  end repeat
  waitAmom = the timer + 10
  repeat while waitAmom > the timer
    nothing()
  end repeat
end

on enterFrame me
  if member(gPrivateDropMem).name = "0.item.DropList" and the ticks > UpdPopularTime then
    sendSprite(me.spriteNum + 1, #UpdateBusyFlats)
    UpdPopularTime = the ticks + 10 * 60
  end if
end
