property pThread, pVarMgrObj

on construct me
  return 1
end

on deconstruct me
  if objectp(pThread) then
    if objectp(pThread.getBaseLogic()) then
      pThread.getBaseLogic().initVariables()
    end if
    if objectp(pThread.getProcManager()) then
      pThread.getProcManager().removeProcessors()
    end if
  end if
  pThread = VOID
  return 1
end

on defineClient me, tSystemObj
  pThread = tSystemObj
  if pThread = 0 then
    return error(me, "Client game framework not found:" && me.getID(), #defineClient)
  end if
  if getmemnum(me.getID() & ".variable.index") then
    dumpVariableField(me.getID() & ".variable.index")
  end if
  pThread.getBaseLogic().defineClient(me.getID())
  pThread.getMessageHandler().defineClient(me.getID())
  pThread.getProcManager().defineClient(me.getID())
  pThread.getProcManager().distributeEvent(#facadeok, me.getID())
  return 1
end

on getNumTickets me
  if getObject(#session) = 0 then
    return 0
  end if
  return getObject(#session).get("user_ph_tickets")
end

on getSpectatorModeFlag me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().get(#spectatormode_flag)
end

on getGameStatus me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().getGameStatus()
end

on getTournamentFlag me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().get(#tournament_flag)
end

on getInstanceList me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().get(#instancelist)
end

on getObservedInstance me
  if me.getVarMgr() = 0 then
    return 0
  end if
  return me.getVarMgr().get(#observed_instance_data)
end

on getGameParameters me
  if me.getVarMgr() = 0 then
    return 0
  end if
  if not me.getVarMgr().exists(#gameparametervalues_format) then
    return 0
  end if
  return me.getVarMgr().get(#gameparametervalues_format)
end

on getJoinParameters me
  if me.getVarMgr() = 0 then
    return 0
  end if
  if not me.getVarMgr().exists(#joinparametervalues_format) then
    return 0
  end if
  return me.getVarMgr().get(#joinparametervalues_format)
end

on setInstanceListUpdates me, tBoolean
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().setInstanceListUpdates(tBoolean)
end

on sendGetInstanceList me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendGetInstanceList()
end

on observeInstance me, tid
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendObserveInstance(tid)
end

on unobserveInstance me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendUnobserveInstance()
end

on initiateCreateGame me, tTeamId
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendInitiateCreateGame(tTeamId)
end

on cancelCreateGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().cancelCreateGame()
end

on createGame me, tParamList, tTeamId
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendGameParameterValues(tParamList, tTeamId)
end

on deleteGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendDeleteGame()
end

on initiateJoinGame me, tInstanceId, tTeamId
  if pThread = 0 then
    return 0
  end if
  pThread.getBaseLogic().store_joinparameters(me, [:])
  return pThread.getMessageSender().sendInitiateJoinGame(tInstanceId, tTeamId)
end

on joinGame me, tInstanceId, tTeamId, tParamList
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendJoinParameterValues(tInstanceId, tTeamId, tParamList)
end

on leaveGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendLeaveGame()
end

on kickPlayer me, tPlayerId
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendKickPlayer(tPlayerId)
end

on watchGame me, tInstanceId
  if pThread = 0 then
    return 0
  end if
  if tInstanceId = VOID then
    tInstance = me.getObservedInstance()
    if tInstance = 0 then
      return 0
    end if
    tInstanceId = tInstance[#id]
  end if
  return pThread.getMessageSender().sendWatchGame(tInstanceId)
end

on startGame
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendStartGame()
end

on sendMoveGoal me, tLocX, tLocY
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendMoveGoal(tLocX, tLocY)
end

on rejoinGame me
  if pThread = 0 then
    return 0
  end if
  return pThread.getMessageSender().sendRejoinGame()
end

on enterLounge me
  if pThread = 0 then
    return 0
  end if
  return pThread.getBaseLogic().enterLounge()
end

on sendGameSystemEvent me, tTopic, tdata
  if pThread = 0 then
    return 0
  end if
  return pThread.getProcManager().distributeEvent(tTopic, tdata)
end

on getVarMgr me
  if pThread = 0 then
    return 0
  end if
  return pThread.getVariableManager()
end
