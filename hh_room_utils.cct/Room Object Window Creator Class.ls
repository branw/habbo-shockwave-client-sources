on construct me
  return 1
end

on deconstruct me
  return 1
end

on createFurnitureWindow me, tClass, tName, tDesc, tMemName
  tID = "object.displayer.furni"
  createWindow(tID, "obj_disp_furni.window")
  tWndObj = getWindow(tID)
  tWndObj.getElement("room_obj_disp_name").setText(tName)
  tWndObj.getElement("room_obj_disp_desc").setText(tDesc)
  tImage = member(getmemnum(tMemName)).image
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return tID
end

on createHumanWindow me, tClass, tName, tPersMessage, tImage, tBadge, tGroupId
  tID = "object.displayer.human"
  createWindow(tID, "obj_disp_human.window")
  tWndObj = getWindow(tID)
  tWndObj.getElement("room_obj_disp_name").setText(tName)
  tWndObj.getElement("room_obj_disp_desc").setText(tPersMessage)
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return tID
end

on createPetWindow me, tPetID
end

on createActionsHumanWindow me, tTargetUserName
  tSessionObj = getObject(#session)
  tID = "object.displayer.actions"
  if tTargetUserName = tSessionObj.GET("user_name") then
    tWindowModel = "obj_disp_actions_own.window"
    tButtonList = [:]
    tButtonList["wave"] = #visible
    tButtonList["dance"] = #visible
    tButtonList["hcdance"] = #visible
    if tSessionObj.GET("hc") then
      tButtonList["dance"] = #hidden
    else
      tButtonList["hcdance"] = #hidden
    end if
  else
    tButtonList = [:]
    tButtonList["friend"] = #visible
    tButtonList["trade"] = #visible
    tButtonList["ignore"] = #visible
    tButtonList["unignore"] = #visible
    tButtonList["kick"] = #visible
    tButtonList["give_rights"] = #visible
    tButtonList["take_rights"] = #visible
    tWindowModel = "obj_disp_actions_peer.window"
    tRoomOwner = tSessionObj.GET("room_owner")
    tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
    if threadExists(#messenger) then
      tBuddyData = getThread(#messenger).getComponent().getBuddyData()
      if tBuddyData.online.getPos(tTargetUserName) > 0 then
        tButtonList["friend"] = #hidden
      end if
    end if
    tRoomComponent = getThread(#room).getComponent()
    tNotPrivateRoom = tRoomComponent.getRoomID() <> "private"
    tNoTrading = tRoomComponent.getRoomData()[#trading] = 0
    tTradeTimeout = 0
    tUserRights = getObject(#session).GET("user_rights")
    tTradeProhibited = not tUserRights.getOne("fuse_trade")
    if tTradeTimeout or tNotPrivateRoom or tNoTrading or tTradeProhibited then
      tButtonList["trade"] = #deactive
    end if
    tUserInfo = tRoomComponent.getUserObject().getInfo()
    tBadge = tUserInfo.getaProp(#badge)
    if not tRoomOwner and not tAnyRoomController then
      tButtonList["kick"] = #hidden
    end if
    if tRoomOwner then
    end if
  end if
  createWindow(tID, tWindowModel)
  tWndObj = getWindow(tID)
  tButtonVertMargins = 5
  tWndObj.lock()
  return tID
end

on createActionsFurniWindow me
  tButtonList = []
  tSessionObj = getObject(#session)
  tRoomController = tSessionObj.GET("room_controller")
  if tRoomController then
    tButtonList = ["move", "rotate"]
  end if
  tRoomOwner = tSessionObj.GET("room_owner")
  if tRoomOwner then
    tButtonList = ["move", "rotate", "pick"]
  end if
  tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
  if tAnyRoomController then
    tButtonList = ["move", "rotate", "pick", "delete"]
  end if
  tID = "object.displayer.actions"
  createWindow(tID, "obj_disp_actions_furni.window")
  tWndObj = getWindow(tID)
  tAllButtons = ["move", "rotate", "pick", "delete"]
  tRowHeight = 20
  repeat with tButtonID in tAllButtons
    if not tButtonList.getOne(tButtonID) then
      tElem = tWndObj.getElement(tButtonID & ".button")
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
    end if
  end repeat
  tDeletedRowCount = tAllButtons.count - tButtonList.count
  tWndObj.lock()
  createTimeout(#temp, 10, #resizeWindow, me.getID(), [#id: tID, #x: 0, #y: -1 * tDeletedRowCount * tRowHeight], 1)
  return tID
end

on createLinksWindow me, tFormat
  case tFormat of
    #own:
      tWindowModel = "obj_disp_links_own.window"
    #peer:
      tWindowModel = "obj_disp_links_peer.window"
    #furni:
      tWindowModel = "obj_disp_links_furni.window"
  end case
  tID = "object.displayer.links"
  createWindow(tID, tWindowModel)
  tWndObj = getWindow(tID)
  tWndObj.lock()
  return tID
end

on createBottomWindow me
  tID = "object.displayer.bottom"
  createWindow(tID, "obj_disp_bottom.window")
  tWndObj = getWindow(tID)
  tWndObj.lock()
  return tID
end

on resizeWindow me, tParams
  tWndObj = getWindow(tParams[#id])
  tX = tParams[#x]
  tY = tParams[#y]
  tWndObj.resizeBy(tX, tY)
end
