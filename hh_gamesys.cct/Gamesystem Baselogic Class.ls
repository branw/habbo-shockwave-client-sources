property pTurnManagerState, pDownloadMgrs

on construct me
  pTurnManagerState = 0
  pDownloadMgrs = [:]
  registerMessage(#roomReady, me.getID(), #checkIfInGameArea)
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#spectatorMode_on, me.getID(), #store_spectatorMode_on)
  registerMessage(#spectatorMode_off, me.getID(), #store_spectatorMode_off)
  return 1
end

on deconstruct me
  me.stopTurnManager()
  pDownloadMgrs = [:]
  if memberExists("gsys_tournamentlogo") then
    removeMember("gsys_tournamentlogo")
  end if
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#spectatorMode_on, me.getID())
  unregisterMessage(#spectatorMode_off, me.getID())
  return 1
end

on defineClient me, tid
  me.initVariables()
end

on leaveRoom me
  me.stopTurnManager()
  me.getMessageSender().setInstanceListUpdates(0)
  me.initVariables()
  return 1
end

on initVariables me
  tVarMgr = me.getVariableManager()
  if tVarMgr = 0 then
    return 1
  end if
  tVarMgr.set(#game_status, #none)
  tVarMgr.set(#game_location, [:])
  tVarMgr.set(#instancelist, [:])
  tVarMgr.set(#observed_instance_data, [:])
  tVarMgr.set(#spectatormode_flag, 0)
  tVarMgr.set(#tournament_flag, 0)
  return 1
end

on getGamestatus me
  tVarMgr = me.getVariableManager()
  if tVarMgr = 0 then
    return 0
  end if
  if tVarMgr.exists(#game_status) = 0 then
    return 0
  end if
  return tVarMgr.get(#game_status)
end

on startTurnManager me
  if pTurnManagerState then
    return 1
  end if
  pTurnManagerState = 1
  return me.getTurnManager().StartMinigameEngine()
end

on stopTurnManager me
  if pTurnManagerState = 0 then
    return 1
  end if
  pTurnManagerState = 0
  return me.getTurnManager().stopMinigameEngine()
end

on cancelCreateGame me
  me.getVariableManager().set(#game_status, #none)
  return me.getMessageSender().setInstanceListUpdates(1)
end

on enterLounge me
  if not getObject(#session).exists(#gamelounge_world_info) then
    return 0
  end if
  tLoungeData = getObject(#session).get(#gamelounge_world_info)
  if not listp(tLoungeData) then
    return 0
  end if
  executeMessage(#changeRoom)
  return me.spaceTravel(tLoungeData[#unitId], tLoungeData[#worldId], tLoungeData[#type])
end

on checkIfInGameArea me
  if not getObject(#session).exists("lastroom") then
    return 0
  end if
  tRoomData = getObject(#session).get("lastroom")
  if not getObject(#session).exists(#gamespace_world_info) then
    return 0
  end if
  tGameSpaceData = getObject(#session).get(#gamespace_world_info)
  if tRoomData[#port] = tGameSpaceData[#unitId] and tRoomData[#door] = tGameSpaceData[#worldId] then
    return 1
  else
    return 0
  end if
end

on store_loungeinfo me, tdata
  if tdata[#tournament_logo_url] <> VOID then
    me.getVariableManager().set(#tournament_flag, 1)
    if memberExists("gsys_tournamentlogo") then
      removeMember("gsys_tournamentlogo")
    end if
    tAdMemNum = queueDownload(tdata[#tournament_logo_url], "gsys_tournamentlogo", #bitmap, 1)
    registerDownloadCallback(tAdMemNum, #store_tournamentlogo_member, me.getID(), [#member_num: tAdMemNum, #click_url: tdata[#tournament_logo_click_url]])
    if tAdMemNum = 0 then
      error(me, "Gamesystem cannot initialize download manager!", #store_loungeinfo)
    end if
  end if
  me.getVariableManager().set(#game_status, #none)
  me.getMessageSender().setInstanceListUpdates(1)
  if getObject(#session) = 0 then
    return 0
  end if
  tWorldData = getObject(#session).get("lastroom")
  if not listp(tWorldData) then
    return 0
  end if
  getObject(#session).set(#gamelounge_world_info, [#unitId: tWorldData[#port], #worldId: tWorldData[#door], #type: tWorldData[#type]])
  getObject(#session).Remove(#gamespace_world_info)
  return 1
end

on store_tournamentlogo_member me, tdata
  me.getProcManager().distributeEvent(#tournamentlogo, tdata)
  return 1
end

on store_instancelist me, tList
  if tList = 0 then
    tList = [:]
  end if
  tVarMgr = me.getVariableManager()
  if tVarMgr = 0 then
    return 0
  end if
  tVarMgr.set(#instancelist, tList)
  tVarMgr.set(#instancelist_timestamp, the milliSeconds)
end

on store_gameinstance me, tItem
  me.getMessageSender().setInstanceListUpdates(0)
  me.getVariableManager().set(#observed_instance_data, tItem)
  tInstanceList = me.getVariableManager().get(#instancelist)
  tInstanceList[string(tItem[#id])] = tItem
  me.getVariableManager().set(#instancelist, tInstanceList)
  if me.getGamestatus() = #watch_requested then
    me.getVariableManager().set(#game_status, #watch_confirmed)
    return me.getProcManager().distributeEvent(#watchok)
  end if
  if me.getGamestatus() = #join_requested then
    me.getVariableManager().set(#game_status, #join_confirmed)
    return me.getProcManager().distributeEvent(#joinok)
  end if
  if me.getGamestatus() = #create_requested then
    me.getVariableManager().set(#game_status, #create_confirmed)
    return me.getProcManager().distributeEvent(#createok)
  end if
  return 1
end

on store_gameparameters me, tParamList
  me.getVariableManager().set(#gameparametervalues_format, tParamList)
end

on store_createfailed me, tReason
  me.getVariableManager().set(#game_status, #none)
  me.getMessageSender().setInstanceListUpdates(1)
end

on store_gamedeleted me, tInstanceId
  tInstanceList = me.getVariableManager().get(#instancelist)
  tInstanceList.deleteProp(string(tInstanceId))
  me.getVariableManager().set(#instancelist, tInstanceList)
  me.getVariableManager().set(#observed_instance_data, [:])
  me.getVariableManager().set(#game_status, #none)
  me.getMessageSender().setInstanceListUpdates(1)
end

on store_joinparameters me, tParamList
  me.getVariableManager().set(#joinparametervalues_format, tParamList)
end

on store_watchfailed me, tParamList
  me.getVariableManager().set(#game_status, #observe_confirmed)
end

on store_gamelocation me, tParamList
  tVarMgr = me.getVariableManager()
  tVarMgr.set(#observed_instance_data, [:])
  tVarMgr.set(#game_status, #game_waiting_for_start)
  if getObject(#session) = 0 then
    return 0
  end if
  tParamList.addProp(#tournament_flag, me.getVariableManager().get(#tournament_flag))
  getObject(#session).set(#gamespace_world_info, tParamList)
  me.getMessageSender().setInstanceListUpdates(0)
  tUnitId = tParamList[#unitId]
  tWorldId = tParamList[#worldId]
  me.spaceTravel(tUnitId, tWorldId, #game)
end

on store_fullgamestatus me, tdata
  if not listp(tdata) then
    return 0
  end if
  case tdata[#state] of
    1:
      me.store_gamereset()
    2:
      me.store_gamestart()
    3:
      me.store_gameend()
  end case
  repeat with i = 1 to tdata.count
    tElementId = tdata.getPropAt(i)
    me.getProcManager().distributeEvent(tdata.getPropAt(i), tdata[i].duplicate())
  end repeat
  return 1
end

on store_gamestatus me, tdata
  if not listp(tdata) then
    return 0
  end if
  repeat with i = 1 to tdata.count
    tElementId = tdata.getPropAt(i)
    me.getProcManager().distributeEvent(tdata.getPropAt(i), tdata[i])
  end repeat
  return 1
end

on store_gamestatus_turn me, tdata
  if not objectp(tdata) then
    return 0
  end if
  return me.getTurnManager()._AddTurnToBuffer(tdata)
end

on store_gamestart me, tdata
  executeMessage(#game_started)
  return me.getVariableManager().set(#game_status, #game_started)
end

on store_gameend me, tdata
  executeMessage(#game_end)
  return me.getVariableManager().set(#game_status, #game_waiting_for_restart)
end

on store_gamereset me, tdata
  executeMessage(#game_reset)
  return me.getVariableManager().set(#game_status, #game_waiting_for_start)
end

on store_spectatorMode_on me
  return me.getVariableManager().set(#spectatormode_flag, 1)
end

on store_spectatorMode_off me
  return me.getVariableManager().set(#spectatormode_flag, 0)
end

on spaceTravel me, tUnitId, tWorldId, tWorldType
  me.getMessageSender().setInstanceListUpdates(0)
  tPresentStruct = getObject(#session).get("lastroom")
  if tPresentStruct = 0 then
    tPresentStruct = [#name: tWorldId, #casts: []]
  end if
  tStruct = [:]
  tStruct.setaProp(#id, tPresentStruct[#id])
  tStruct.setaProp(#name, tPresentStruct[#name])
  tStruct.setaProp(#type, tWorldType)
  tStruct.setaProp(#owner, 0)
  tStruct.setaProp(#teleport, 0)
  tStruct.setaProp(#door, tWorldId)
  tStruct.setaProp(#port, tUnitId)
  tStruct.setaProp(#casts, tPresentStruct[#casts])
  executeMessage(#enterRoomDirect, tStruct)
  return 1
end
