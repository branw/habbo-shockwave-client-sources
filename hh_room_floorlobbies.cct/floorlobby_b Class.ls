property pBubbleList

on construct me
  if not threadExists(#room) then
    return error(me, "Room thread not found!!!", #construct)
  end if
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return error(me, "Room visualizer not found!", #construct)
  end if
  tRoomVis.getSprById("floor").member.paletteRef = member(getmemnum("floorlobby_b palette"))
  i = 1
  repeat while 1
    tSpr = tRoomVis.getSprById("floor_" & i)
    if not tSpr then
      exit repeat
    end if
    tSpr.member.paletteRef = member(getmemnum("floorlobby_b palette"))
    i = i + 1
  end repeat
  tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("lobby_window")
  tLocH = tsprite.locH
  pBubbleList = []
  repeat with i = 1 to 8
    tObj = createObject(#temp, "Floor Bubble Win Class")
    tObj.define(tRoomVis.getSprById("bubble" & i), tLocH)
    pBubbleList.add(tObj)
  end repeat
  tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("lobby_pipe")
  tLocH = tsprite.locH
  repeat with i = 9 to 16
    tObj = createObject(#temp, "Floor Bubble Top Class")
    tObj.define(tRoomVis.getSprById("bubble" & i), tLocH)
    pBubbleList.add(tObj)
  end repeat
  repeat with i = 17 to 23
    tObj = createObject(#temp, "Floor Bubble Bottom Class")
    tObj.define(tRoomVis.getSprById("bubble" & i), tLocH)
    pBubbleList.add(tObj)
  end repeat
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  pBubbleList = []
  return 1
end

on update me
  call(#update, pBubbleList)
end
