on constructHandlerManager
  return createManager(#handler_manager, getClassVariable("handler.manager.class"))
end

on deconstructHandlerManager
  return removeManager(#handler_manager)
end

on getHandlerManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#handler_manager) then
    return constructHandlerManager()
  end if
  return tObjMngr.getManager(#handler_manager)
end

on createHandler tid, tClass
  return getHandlerManager().create(tid, tClass)
end

on getHandler tid
  return getHandlerManager().get(tid)
end

on removeHandler tid
  return getHandlerManager().remove(tid)
end

on HandlerExists tid
  return getHandlerManager().exists(tid)
end

on getHandlerMethod tid, tCommand
  return getHandlerManager().getMethod(tid, tCommand)
end

on printHandlers
  return getHandlerManager().print()
end
