on constructVariableManager me
  return createManager(#variable_manager, value(convertToPropList(field("System Variables"), RETURN)["variable.manager.class"]))
end

on deconstructVariableManager
  return removeManager(#variable_manager)
end

on getVariableManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#variable_manager) then
    return constructVariableManager()
  end if
  return tObjMngr.getManager(#variable_manager)
end

on createVariable tid, tValue
  return getVariableManager().create(tid, tValue)
end

on setVariable tid, tValue
  return getVariableManager().create(tid, tValue)
end

on getVariable tid, tDefault
  return getVariableManager().get(tid, tDefault)
end

on getIntVariable tid, tDefault
  return getVariableManager().getInt(tid, tDefault)
end

on getStructVariable tid, tDefault
  return getVariableManager().getValue(tid, tDefault)
end

on getClassVariable tid, tDefault
  return getVariableManager().getValue(tid, tDefault)
end

on getVariableValue tid, tDefault
  return getVariableManager().getValue(tid, tDefault)
end

on removeVariable tid
  return getVariableManager().remove(tid)
end

on variableExists tid
  return getVariableManager().exists(tid)
end

on printVariables
  return getVariableManager().print()
end

on dumpVariableField tField, tDelimiter
  return getVariableManager().dump(tField, tDelimiter)
end
