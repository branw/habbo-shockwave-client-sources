on constructParserManager
  return createManager(#parser_manager, getClassVariable("parser.manager.class"))
end

on deconstructParserManager
  return removeManager(#parser_manager)
end

on getParserManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#parser_manager) then
    return constructParserManager()
  end if
  return tObjMngr.getManager(#parser_manager)
end

on createParser tid, tClass
  return getParserManager().create(tid, tClass)
end

on getParser tid
  return getParserManager().get(tid)
end

on removeParser tid
  return getParserManager().remove(tid)
end

on ParserExists tid
  return getParserManager().exists(tid)
end

on getParserMethod tid, tCommand
  return getParserManager().getMethod(tid, tCommand)
end

on printParsers
  return getParserManager().print()
end
