on constructInterfaceManager
  return createManager(#interface_manager, getClassVariable("interface.manager.class"))
end

on deconstructInterfaceManager
  return removeManager(#interface_manager)
end

on getInterfaceManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#interface_manager) then
    return constructInterfaceManager()
  end if
  return tObjMngr.getManager(#interface_manager)
end

on createInterface tid, tClass
  return getInterfaceManager().create(tid, tClass)
end

on getInterface tid
  return getInterfaceManager().get(tid)
end

on removeInterface tid
  return getInterfaceManager().remove(tid)
end

on InterfaceExists tid
  return getInterfaceManager().exists(tid)
end

on printInterfaces
  return getInterfaceManager().print()
end
