global gCore

on constructCoreThread
  if objectp(gCore) then
    return gCore
  end if
  gCore = script("Core Component Class").Initialize()
  return gCore
end

on deconstructCoreThread
  return 0
end

on getCoreThread
  if not objectp(gCore) then
    return constructCoreThread()
  end if
  return gCore
end

on createThread tid, tInitField
  return getCoreThread().component.create(tid, tInitField)
end

on removeThread tid
  return getCoreThread().component.remove(tid)
end

on getThread tid
  return getCoreThread().component.get(tid)
end

on threadExists tid
  return getCoreThread().component.exists(tid)
end

on initThread tCastNumOrMemName
  return getCoreThread().component.initThread(tCastNumOrMemName)
end

on initExistingThreads
  return getCoreThread().component.initExistingThreads()
end

on closeThread tCastNumOrID
  return getCoreThread().getComponent().closeThread(tCastNumOrID)
end

on closeExistingThreads
  return getCoreThread().getComponent().closeExistingThreads()
end

on printThreads
  return getCoreThread().getComponent().print()
end
