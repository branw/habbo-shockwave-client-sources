on constructComponentManager
  return createManager(#component_manager, getClassVariable("component.manager.class"))
end

on deconstructComponentManager
  return removeManager(#component_manager)
end

on getComponentManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#component_manager) then
    return constructComponentManager()
  end if
  return tObjMngr.getManager(#component_manager)
end

on createComponent tid, tClass
  return getComponentManager().create(tid, tClass)
end

on getComponent tid
  return getComponentManager().get(tid)
end

on removeComponent tid
  return getComponentManager().remove(tid)
end

on ComponentExists tid
  return getComponentManager().exists(tid)
end

on printComponents
  return getComponentManager().print()
end
