property pState

on construct me
  registerMessage(#enterRoom, me.getID(), #leaveEntry)
  registerMessage(#leaveRoom, me.getID(), #enterEntry)
  registerMessage(#initialize, me.getID(), #updateState)
  return 1
end

on deconstruct me
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#initialize, me.getID())
  updateState(me, "reset")
  return 1
end

on enterEntry me
  me.updateState(#hotelView)
  me.updateState(#entryBar)
  return 1
end

on leaveEntry me
  return me.updateState("reset")
end

on getState me
  return pState
end

on updateState me, tstate
  case tstate of
    "reset":
      pState = tstate
      return me.getInterface().hideAll()
    #hotelView, "initialize":
      pState = tstate
      return me.getInterface().showHotel()
    #entryBar:
      pState = tstate
      return me.getInterface().showEntryBar()
  end case
  return error(me, "Unknown state:" && tstate, #updateState)
end
