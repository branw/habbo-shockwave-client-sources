on mouseUp me
  global gChosenFlatId
  if not voidp(gChosenFlatId) then
    sendEPFuseMsg("ADD_FAVORITE_ROOM" && gChosenFlatId)
  end if
  put "Room" && gChosenFlatId && "added to favourites...!"
end
