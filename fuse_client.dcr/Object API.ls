global gObjs

on constructObjectManager me
  if objectp(gObjs) then
    return gObjs
  end if
  tClass = value(convertToPropList(field("System Variables"), RETURN)["object.manager.class"])[1]
  gObjs = script(tClass).new()
  gObjs.construct()
  return gObjs
end

on deconstructObjectManager
  if voidp(gObjs) then
    return 0
  end if
  gObjs.deconstruct()
  gObjs = VOID
  return 1
end

on getObjectManager
  if voidp(gObjs) then
    return constructObjectManager()
  end if
  return gObjs
end

on createObject tid
  tClassList = []
  repeat with i = 2 to the paramCount
    if listp(param(i)) then
      repeat with j = 1 to param(i).count
        tClassList.add(param(i)[j])
      end repeat
      next repeat
    end if
    tClassList.add(param(i))
  end repeat
  return getObjectManager().create(tid, tClassList)
end

on removeObject tid
  return getObjectManager().remove(tid)
end

on getObject tid
  return getObjectManager().get(tid)
end

on objectExists tid
  return getObjectManager().exists(tid)
end

on registerObject tid, tObject
  return getObjectManager().registerObject(tid, tObject)
end

on unregisterObject tid
  return getObjectManager().unregisterObject(tid)
end

on createManager tid
  tClassList = []
  repeat with i = 2 to the paramCount
    if listp(param(i)) then
      repeat with j = 1 to param(i).count
        tClassList.add(param(i)[j])
      end repeat
      next repeat
    end if
    tClassList.add(param(i))
  end repeat
  getObjectManager().create(tid, tClassList)
  getObjectManager().registerManager(tid)
  return getObjectManager().get(tid)
end

on removeManager tid
  return getObjectManager().remove(tid)
end

on getManager tid
  return getObjectManager().getManager(tid)
end

on registerManager tid
  return getObjectManager().registerManager(tid)
end

on unregisterManager tid
  return getObjectManager().unregisterManager(tid)
end

on managerExists tid
  return getObjectManager().managerExists(tid)
end

on receivePrepare tid
  return getObjectManager().receivePrepare(tid)
end

on removePrepare tid
  return getObjectManager().removePrepare(tid)
end

on receiveUpdate tid
  return getObjectManager().receiveUpdate(tid)
end

on removeUpdate tid
  return getObjectManager().removeUpdate(tid)
end

on pauseUpdate
  return getObjectManager().pauseUpdate()
end

on unpauseUpdate
  return getObjectManager().unpauseUpdate()
end

on printObjects
  return getObjectManager().print()
end
