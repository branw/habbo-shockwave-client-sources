property pModBadgeList, pExtensionClosedID

on construct me
  pModBadgeList = getVariableValue("moderator.badgelist")
  pExtensionClosedID = "roomnfo_ext_right"
  return 1
end

on deconstruct me
  return 1
end

on initWindow me, tID, ttype
  if not windowExists(tID) then
    tBaseWindowType = "obj_disp_base.window"
    createWindow(tID, tBaseWindowType, 9999, 9999)
    tWndObj = getWindow(tID)
  else
    tWndObj = getWindow(tID)
    tWndObj.unmerge()
  end if
  tWndObj.lock()
  mergeWindow(tID, ttype)
  return tWndObj
end

on createFurnitureWindow me, tID, tProps
  tWndObj = me.initWindow(tID, "obj_disp_furni.window")
  tWndObj.getElement("room_obj_disp_name").setText(tProps[#name])
  tWndObj.getElement("room_obj_disp_desc").setText(tProps[#custom])
  tImage = member(getmemnum(tProps[#smallmember])).image
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tImage)
  tWndObj.lock()
  return 1
end

on createHumanWindow me, tID, tProps, tSelectedObj, tBadgeObjID
  tWndObj = me.initWindow(tID, "obj_disp_human.window")
  tWndObj.getElement("room_obj_disp_name").setText(tProps[#name])
  tWndObj.getElement("room_obj_disp_desc").setText(tProps[#custom])
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tProps[#image])
  tBadgeObj = getObject(tBadgeObjID)
  tBadgeObj.updateInfoStandBadge(tID, tSelectedObj, tProps[#badge])
  tWndObj.lock()
  return 1
end

on createPetWindow me, tID, tProps
  tWndObj = me.initWindow(tID, "obj_disp_human.window")
  tWndObj.getElement("room_obj_disp_name").setText(tProps[#name])
  tWndObj.getElement("room_obj_disp_desc").setText(tProps[#custom])
  tWndObj.getElement("room_obj_disp_avatar").feedImage(tProps[#image])
  tWndObj.lock()
  return 1
end

on createActionsHumanWindow me, tID, tTargetUserName, tShowButtons
  tSessionObj = getObject(#session)
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
        tButtonList["friend"] = #deactive
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
    tRoomInterface = getThread(#room).getInterface()
    tSelectedObj = tRoomInterface.getSelectedObject()
    tUserInfo = tRoomComponent.getUserObject(tSelectedObj).getInfo()
    tBadge = tUserInfo.getaProp(#badge)
    tIgnoreListObj = getThread(#room).getInterface().pIgnoreListObj
    if tIgnoreListObj.getIgnoreStatus(tUserInfo.name) then
      tButtonList["ignore"] = #hidden
    else
      tButtonList["unignore"] = #hidden
    end if
    if pModBadgeList.getOne(tBadge) > 0 then
      tButtonList["ignore"] = #hidden
      tButtonList["unignore"] = #hidden
    end if
    if not tRoomOwner and not tAnyRoomController then
      tButtonList["kick"] = #hidden
    end if
    if tRoomOwner then
      if tUserInfo.ctrl = 0 then
        tButtonList["take_rights"] = #hidden
      else
        if tUserInfo.ctrl = "furniture" then
          tButtonList["give_rights"] = #hidden
        else
          if tUserInfo.ctrl = "useradmin" then
            tButtonList["give_rights"] = #hidden
          end if
        end if
      end if
    else
      tButtonList["give_rights"] = #hidden
      tButtonList["take_rights"] = #hidden
    end if
  end if
  tWndObj = me.initWindow(tID, tWindowModel)
  me.scaleButtonWindow(tID, tButtonList, tShowButtons)
  tWndObj.lock()
  return tID
end

on createActionsFurniWindow me, tID, tClass, tShowButtons
  tButtonList = [:]
  tButtonList["move"] = #hidden
  tButtonList["rotate"] = #hidden
  tButtonList["pick"] = #hidden
  tButtonList["delete"] = #hidden
  tSessionObj = getObject(#session)
  tRoomController = tSessionObj.GET("room_controller")
  if tRoomController then
    tButtonList["move"] = #visible
    tButtonList["rotate"] = #visible
  end if
  tRoomOwner = tSessionObj.GET("room_owner")
  if tRoomOwner then
    tButtonList["move"] = #visible
    tButtonList["rotate"] = #visible
    tButtonList["pick"] = #visible
  end if
  tAnyRoomController = tSessionObj.GET("user_rights").getOne("fuse_any_room_controller")
  if tAnyRoomController then
    tButtonList["move"] = #visible
    tButtonList["rotate"] = #visible
    tButtonList["pick"] = #visible
  end if
  if tClass = "item" then
    tButtonList["move"] = #hidden
    tButtonList["rotate"] = #hidden
  end if
  tWndObj = me.initWindow(tID, "obj_disp_actions_furni.window")
  me.scaleButtonWindow(tID, tButtonList, tShowButtons)
  tWndObj.lock()
  return tID
end

on scaleButtonWindow me, tID, tButtonList, tShowButtons
  tWndObj = getWindow(tID)
  if tShowButtons = 0 then
    repeat with tIndex = 1 to tButtonList.count
      tButtonID = tButtonList.getPropAt(tIndex)
      tButtonList[tButtonID] = #hidden
    end repeat
    tArrowElem = tWndObj.getElement("object_displayer_toggle_actions_icon")
    tArrowElem.setProperty(#member, pExtensionClosedID)
    tTextElem = tWndObj.getElement("object_displayer_toggle_actions")
    tOpenText = getText("object_displayer_show_actions")
    tTextElem.setText(tOpenText)
  end if
  tCurrentButtonTopPos = 0
  tButtonVertMargins = 3
  tButtonHeight = 15
  tHiddenRowCount = 0
  repeat with tIndex = 1 to tButtonList.count
    tButtonID = tButtonList.getPropAt(tIndex)
    tButtonVisibility = tButtonList[tButtonID]
    tElement = tWndObj.getElement(tButtonID & ".button")
    tLeftPos = tElement.getProperty(#locX)
    if tIndex = 1 then
      tCurrentButtonTopPos = tElement.getProperty(#locY)
    end if
    case tButtonVisibility of
      #visible:
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tCurrentButtonTopPos = tCurrentButtonTopPos + tButtonHeight + tButtonVertMargins
      #deactive:
        tElement.moveTo(tLeftPos, tCurrentButtonTopPos)
        tElement.deactivate()
        tCurrentButtonTopPos = tCurrentButtonTopPos + tButtonHeight + tButtonVertMargins
      #hidden:
        tElement.setProperty(#visible, 0)
        tHiddenRowCount = tHiddenRowCount + 1
    end case
  end repeat
  tNewHeight = tWndObj.getProperty(#height) - tHiddenRowCount * (tButtonHeight + tButtonVertMargins) - tButtonVertMargins
  me.resizeWindowTo(tID, tWndObj.getProperty(#width), tNewHeight)
end

on createLinksWindow me, tID, tFormat
  case tFormat of
    #own:
      tWindowModel = "obj_disp_links_own.window"
    #peer:
      tWindowModel = "obj_disp_links_peer.window"
  end case
  tWndObj = me.initWindow(tID, tWindowModel)
  tWndObj.lock()
  return tID
end

on createBottomWindow me, tID
  tWndObj = me.initWindow(tID, "obj_disp_bottom.window")
  tWndObj.lock()
  return tID
end

on resizeWindowBy me, tID, tX, tY
  tWndObj = getWindow(tID)
  tWndObj.resizeBy(tX, tY)
end

on resizeWindowTo me, tID, tX, tY
  tWndObj = getWindow(tID)
  tWndObj.resizeTo(tX, tY)
end
