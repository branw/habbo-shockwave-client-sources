property pState, pValidPartProps, pValidPartGroups

on construct me
  registerMessage(#userlogin, me.getID(), #checkWebShortcuts)
  return me.updateState("start")
end

on deconstruct me
  unregisterMessage(#userlogin, me.getID())
  return me.updateState("reset")
end

on showHideRoomKiosk me
  return me.getInterface().showHideRoomKiosk()
end

on sendNewRoomData me, tFlatData
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("CREATEFLAT", tFlatData)
  else
    return 0
  end if
end

on sendSetFlatInfo me, tFlatMsg
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("SETFLATINFO", tFlatMsg)
  else
    return 0
  end if
end

on sendFlatCategory me, tNodeId, tCategoryId
  if voidp(tNodeId) then
    return error(me, "Node ID expected!", #sendFlatCategory, #major)
  end if
  if voidp(tCategoryId) then
    return error(me, "Category ID expected!", #sendFlatCategory, #major)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("SETFLATCAT", [#integer: integer(tNodeId), #integer: integer(tCategoryId)])
  else
    return 0
  end if
end

on updateState me, tstate, tProps
  case tstate of
    "reset":
      pState = tstate
      return unregisterMessage(#open_roomkiosk, me.getID())
    "start":
      pState = tstate
      return registerMessage(#open_roomkiosk, me.getID(), #showHideRoomKiosk)
  end case
  return error(me, "Unknown state:" && tstate, #updateState, #minor)
end

on getState me
  return pState
end

on checkWebShortcuts me, tChecked
  if tChecked = 1 then
    executeMessage(#open_roomkiosk)
    return 1
  end if
  if variableExists("shortcut.id") then
    tShortcutID = getIntVariable("shortcut.id")
    if tShortcutID = 1 then
      tTimeOutId = #roommatic_opening_timeout
      if not timeoutExists(tTimeOutId) then
        createTimeout(#tTimeOutId, 2500, #checkWebShortcuts, me.getID(), 1, 1)
      end if
    end if
  end if
  return 1
end
