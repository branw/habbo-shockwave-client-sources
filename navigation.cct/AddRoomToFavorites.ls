property spriteNum, pRequiredAction

on beginSprite me
  pRequiredAction = #add
end

on mouseDown me
  if pRequiredAction = #add then
    sprite(spriteNum).member = member(getmemnum("addtofavorites_btn_e_hi"))
  else
    if pRequiredAction = #remove then
      sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e_hi"))
    end if
  end if
end

on mouseUp me
  global gChosenFlatId, gMyName
  if pRequiredAction = #add then
    if not voidp(gChosenFlatId) then
      sendEPFuseMsg("ADD_FAVORITE_ROOM" && gChosenFlatId)
    end if
    sprite(spriteNum).member = member(getmemnum("addtofavorites_btn_e"))
    put "ADD" && gChosenFlatId
  else
    if pRequiredAction = #remove then
      if not voidp(gChosenFlatId) then
        sendEPFuseMsg("DEL_FAVORITE_ROOM" && gChosenFlatId)
        sendEPFuseMsg("GET_FAVORITE_ROOMS" && gMyName)
        sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e"))
      end if
      put "DEL" && gChosenFlatId
    end if
  end if
end

on mouseUpOutSide me
  if pRequiredAction = #add then
    sprite(spriteNum).member = member(getmemnum("addtofavorites_btn_e"))
  else
    if pRequiredAction = #remove then
      sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e"))
    end if
  end if
end

on exitFrame me
  global gPrivateDropMem
  if member(gPrivateDropMem).name = "3.item.DropList" and pRequiredAction = #add then
    pRequiredAction = #remove
    sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e"))
    sprite(spriteNum).width = member(getmemnum("removefromfavorites_btn_e")).width
    sprite(spriteNum).height = member(getmemnum("removefromfavorites_btn_e")).height
  else
    if member(gPrivateDropMem).name <> "3.item.DropList" and pRequiredAction = #remove then
      pRequiredAction = #add
      sprite(spriteNum).member = member(getmemnum("addtofavorites_btn_e"))
      sprite(spriteNum).width = member(getmemnum("addtofavorites_btn_e")).width
      sprite(spriteNum).height = member(getmemnum("addtofavorites_btn_e")).height
    end if
  end if
end
