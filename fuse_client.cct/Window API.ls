on constructWindowManager
  return createManager(#window_manager, getClassVariable("window.manager.class"))
end

on deconstructWindowManager
  return removeManager(#window_manager)
end

on getWindowManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#window_manager) then
    return constructWindowManager()
  end if
  return tObjMngr.getManager(#window_manager)
end

on createWindow tid, tLayout, tLocX, tLocY, tSpecial
  return getWindowManager().create(tid, tLayout, tLocX, tLocY, tSpecial)
end

on removeWindow tid
  return getWindowManager().remove(tid)
end

on getWindow tid
  return getWindowManager().get(tid)
end

on windowExists tid
  return getWindowManager().exists(tid)
end

on mergeWindow tid, tLayout
  if windowExists(tid) then
    return getWindow(tid).merge(tLayout)
  else
    return 0
  end if
end

on activateWindow tid
  return getWindowManager().Activate(tid)
end

on deactivateWindow tid
  return getWindowManager().deactivate(tid)
end

on registerClient tid, tClientID
  if windowExists(tid) then
    return getWindow(tid).registerClient(tClientID)
  else
    return 0
  end if
end

on registerProcedure tid, tHandler, tClientID, tEvent
  if windowExists(tid) then
    return getWindow(tid).registerProcedure(tHandler, tClientID, tEvent)
  else
    return 0
  end if
end

on showWindows
  return getWindowManager().showAll()
end

on hideWindows
  return getWindowManager().hideAll()
end

on lockWindowLayering
  return getWindowManager().lock()
end

on unlockWindowLayering
  return getWindowManager().unlock()
end

on printWindows
  return getWindowManager().print()
end
