property pWndID, pObjList, pWriterObj, pListHeight

on construct me
  pWndID = "Furniture Chooser."
  pObjList = [:]
  tMetrics = getStructVariable("struct.font.plain")
  tMetrics.setaProp(#lineHeight, 14)
  createWriter(me.getID() && "Writer", tMetrics)
  pWriterObj = getWriter(me.getID() && "Writer")
  if not createWindow(pWndID, "habbo_system.window", 5, 315) then
    return 0
  end if
  tWndObj = getWindow(pWndID)
  if not tWndObj.merge("chooser.window") then
    return tWndObj.close()
  end if
  tWndObj.resizeTo(260, 170)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcChooser, me.getID(), #mouseUp)
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  registerMessage(#enterRoom, me.getID(), #update)
  registerMessage(#activeObjectRemoved, me.getID(), #update)
  registerMessage(#itemObjectRemoved, me.getID(), #update)
  registerMessage(#activeObjectsUpdated, me.getID(), #update)
  registerMessage(#itemObjectsUpdated, me.getID(), #update)
  return 1
end

on deconstruct me
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  pWriterObj = VOID
  removeWriter(me.getID() && "Writer")
  pObjList = [:]
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#activeObjectRemoved, me.getID())
  unregisterMessage(#itemObjectRemoved, me.getID())
  unregisterMessage(#activeObjectsUpdated, me.getID())
  unregisterMessage(#itemObjectsUpdated, me.getID())
  return 1
end

on showList me
  return me.update()
end

on close me
  return removeObject(me.getID())
end

on update me
  if not threadExists(#room) then
    return removeObject(me.getID())
  end if
  if not windowExists(pWndID) then
    return removeObject(me.getID())
  end if
  tRoomComponent = getThread(#room).getComponent()
  if not objectp(tRoomComponent) then
    return [:]
  end if
  tActiveObjList = tRoomComponent.getActiveObject(#list)
  tItemObjList = tRoomComponent.getItemObject(#list)
  pObjList = [:]
  pObjList.sort()
  tClickAction = EMPTY
  tMoverClientId = 0
  tObjectMover = getThread(#room).getInterface().getObjectMover()
  if objectp(tObjectMover) then
    tMoverClientId = tObjectMover.getProperty(#clientID)
    tClickAction = getThread(#room).getInterface().getProperty(#clickAction)
  end if
  tAdminChooser = getObject(#session).GET("user_rights").getOne("fuse_any_room_controller")
  repeat with tObj in tActiveObjList
    if tAdminChooser then
      pObjList.setaProp("a" & tObj.getID(), "Id:" & tObj.getID() && tObj.getLocation() && tObj.getInfo().name)
      next repeat
    end if
    pObjList.setaProp("a" & tObj.getID(), tObj.getInfo().name)
  end repeat
  repeat with tObj in tItemObjList
    if tAdminChooser then
      pObjList.setaProp("i" & tObj.getID(), "Id:" & tObj.getID() && tObj.getLocation() && tObj.getInfo().name)
      next repeat
    end if
    pObjList.setaProp("i" & tObj.getID(), tObj.getInfo().name)
  end repeat
  tObjStr = EMPTY
  repeat with i = 1 to pObjList.count
    tObjStr = tObjStr && i & "." && pObjList[i] & RETURN
  end repeat
  delete char -30003 of tObjStr
  tImg = pWriterObj.render(tObjStr)
  tElem = getWindow(pWndID).getElement("list")
  tElem.feedImage(tImg)
  pListHeight = tImg.height
  return 1
end

on clear me
  pObjList = [:]
  pListHeight = 0
  getWindow(pWndID).getElement("list").feedImage(image(1, 1, 8))
  return 1
end

on eventProcChooser me, tEvent, tSprID, tParam
  case tSprID of
    "close":
      return removeObject(me.getID())
    "list":
      tCount = count(pObjList)
      if tCount = 0 then
        return 0
      end if
      tLineNum = tParam.locV / (pListHeight / tCount) + 1
      if tLineNum < 1 then
        tLineNum = 1
      end if
      if tLineNum > tCount then
        tLineNum = tCount
      end if
      if not threadExists(#room) then
        return removeObject(me.getID())
      end if
      tObjID = pObjList.getPropAt(tLineNum)
      tRoomInt = getThread(#room).getInterface()
      if not tRoomInt then
        return 0
      end if
      tRoomComponent = getThread(#room).getComponent()
      if not tRoomComponent then
        return 0
      end if
      tObjID = pObjList.getPropAt(tLineNum)
      tObjType = tObjID.char[1]
      tObjID = tObjID.char[2..tObjID.length]
      if tObjType = "a" then
        tActiveObj = tRoomComponent.getActiveObject(tObjID)
      else
        if tObjType = "i" then
          tItemObj = tRoomComponent.getItemObject(tObjID)
        end if
      end if
      if not (objectp(tActiveObj) or objectp(tItemObj)) then
        return 0
      end if
      if objectp(tItemObj) then
        ttype = "item"
      end if
      if objectp(tActiveObj) then
        ttype = "active"
      end if
      tRoomInt.cancelObjectMover()
      tRoomInt.pSelectedObj = tObjID
      tRoomInt.pSelectedType = ttype
      tRoomInt.showObjectInfo(ttype)
      tRoomInt.hideArrowHiliter()
      if ttype = "item" then
        if tItemObj.select() then
          tRoomInt.showInterface(ttype)
        else
          tRoomInt.hideInterface(#hide)
        end if
      else
        tRoomInt.showInterface(ttype)
      end if
  end case
end
