property ancestor, msg, showName, showDescription
global gpObjects, gChosenStuffId, gChosenStuffSprite, gPresentCard, gPresentStuffId

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  the itemDelimiter = ":"
  s = getaProp(me.pData, "CUSTOM_VARIABLE")
  if stringp(s) then
    msg = item 4 to the number of items in s of s
  end if
  return me
end

on mouseDown me
  setaProp(ancestor, #showName, showName)
  setaProp(ancestor, #showDescription, showDescription)
  callAncestor(#mouseDown, ancestor)
  if the doubleClick and not (me.id contains "place") then
    if objectp(gPresentCard) then
      close(gPresentCard)
    end if
    gPresentCard = new(script("PopUp Context Class"), 1300000000, 740, 747, point(200, 120))
    put msg into field "packetcard_field"
    displayFrame(gPresentCard, "xmas_packet_card")
    gPresentStuffId = me.id
  end if
end
