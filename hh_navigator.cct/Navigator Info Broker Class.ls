property pClientList

on construct me
  pClientList = [:]
  registerMessage(#requestRoomData, me.getID(), #requestRoomData)
end

on deconstruct me
  pClientList = VOID
  unregisterMessage(#requestRoomData, me.getID())
end

on requestRoomData me, tRoomID, ttype, tCallback
  tNavComponent = me.getNavComponent()
  if tNavComponent = 0 then
    return 0
  end if
  if tRoomID = VOID then
    return error(me, "Must specify room ID.", #requestRoomData, #major)
  end if
  if not listp(tCallback) then
    return error(me, "Callback list in format [obj, handler] expected.", #requestRoomData, #major)
  end if
  if voidp(tCallback[1]) or voidp(tCallback[2]) then
    return error(me, "Callback list in format [obj, handler] expected.", #requestRoomData, #major)
  end if
  if ttype = #private and not (tRoomID contains "f_") then
    tID = "f_" & tRoomID
  else
    tID = tRoomID
  end if
  if pClientList.findPos(tID) = 0 then
    pClientList.addProp(tID, [])
  end if
  tList = pClientList[tID]
  tList.append(tCallback)
  if ttype = #private then
    return tNavComponent.sendGetFlatInfo(tRoomID)
  else
    return tNavComponent.sendNavigate(tRoomID, 1, 0)
  end if
end

on processNavigatorData me, tdata
  if not listp(tdata) then
    return 0
  end if
  tList = pClientList[tdata[#id]]
  pClientList.deleteProp(tdata[#id])
  if tList = VOID then
    return 1
  end if
  repeat with tCallback in tList
    tTargetObject = getObject(tCallback[1])
    tTargetMethod = tCallback[2]
    if tTargetObject <> 0 then
      call(tTargetMethod, tTargetObject, tdata)
    end if
  end repeat
  return 1
end

on getNavComponent me
  tObject = getObject(#navigator_component)
  if tObject = 0 then
    return error(me, "Navigator component not found!", #getNavigator, #major)
  end if
  return tObject
end
