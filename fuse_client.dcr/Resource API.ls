on constructResourceManager
  return createManager(#resource_manager, getClassVariable("resource.manager.class"))
end

on deconstructResourceManager
  return removeManager(#resource_manager)
end

on getResourceManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#resource_manager) then
    return constructResourceManager()
  end if
  return tObjMngr.getManager(#resource_manager)
end

on getResourceManagerReady
  return objectExists(#resource_manager)
end

on preIndexMembers tCastNum
  return getResourceManager().preIndexMembers(tCastNum)
end

on unregisterMembers tCastNum
  return getResourceManager().unregisterMembers(tCastNum)
end

on createMember tMemName, ttype
  return getResourceManager().createMember(tMemName, ttype)
end

on removeMember tMemName
  return getResourceManager().removeMember(tMemName)
end

on updateMember tMemName
  return getResourceManager().updateMember(tMemName)
end

on registerMember tMemName
  return getResourceManager().registerMember(tMemName)
end

on unregisterMember tMemName
  return getResourceManager().unregisterMember(tMemName)
end

on memberExists tMemName
  return getResourceManager().exists(tMemName)
end

on getmemnum tMemName
  return getResourceManager().getmemnum(tMemName)
end

on printMembers me
  return getResourceManager().print()
end
