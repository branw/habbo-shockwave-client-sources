on constructBrokerManager
  return createManager(#broker_manager, getClassVariable("broker.manager.class"))
end

on deconstructBrokerManager
  return removeManager(#broker_manager)
end

on getBrokerManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#broker_manager) then
    return constructBrokerManager()
  end if
  return tObjMngr.getManager(#broker_manager)
end

on createBroker tMessage
  return getBrokerManager().create(tMessage)
end

on removeBroker tMessage
  return getBrokerManager().remove(tMessage)
end

on getBroker tMessage
  return getBrokerManager().get(tMessage)
end

on brokerExists tMessage
  return getBrokerManager().exists(tMessage)
end

on registerMessage tMessage, tClientID, tMethod
  return getBrokerManager().register(tMessage, tClientID, tMethod)
end

on unregisterMessage tMessage, tClientID
  return getBrokerManager().unregister(tMessage, tClientID)
end

on executeMessage tMessage, tArgA, tArgB, tArgC
  return getBrokerManager().execute(tMessage, tArgA, tArgB, tArgC)
end

on printBrokers
  return getBrokerManager().print()
end
