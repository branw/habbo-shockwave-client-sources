on construct me
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #msgstruct_numtickets:
      return me.handle_numtickets(tdata)
    #msgstruct_notickets:
      return me.handle_notickets(tdata)
    #msgstruct_users:
      return me.handle_users(tdata)
    #msgstruct_loungeinfo:
      return me.handle_loungeinfo(tdata)
    #msgstruct_instancenotavailable:
      return me.handle_instancenotavailable(tdata)
    #msgstruct_gameparameters:
      return me.handle_gameparameters(tdata)
    #msgstruct_createfailed:
      return me.handle_createfailed(tdata)
    #msgstruct_gamedeleted:
      return me.handle_gamedeleted(tdata)
    #msgstruct_joinparameters:
      return me.handle_joinparameters(tdata)
    #msgstruct_joinfailed:
      return me.handle_joinfailed(tdata)
    #msgstruct_watchfailed:
      return me.handle_watchfailed(tdata)
    #msgstruct_gamelocation:
      return me.handle_gamelocation(tdata)
    #msgstruct_startfailed:
      return me.handle_startfailed(tdata)
    #msgstruct_playerrejoined:
      return me.handle_playerrejoined(tdata)
    #msgstruct_idlewarning:
      return me.handle_idlewarning(tdata)
  end case
  return 0
end

on handle_numtickets me, tMsg
  tNum = integer(tMsg.content.line[1].word[1])
  if not integerp(tNum) then
    return 0
  end if
  return me.getGameSystem().sendGameSystemEvent(#numtickets, tNum)
end

on handle_notickets me, tMsg
  return me.getGameSystem().sendGameSystemEvent(#notickets, VOID)
end

on handle_users me, tMsg
  return me.getGameSystem().sendGameSystemEvent(#users, tMsg)
end

on handle_loungeinfo me, tMsg
  tConn = tMsg.connection
  tHasTournament = tConn.GetIntFrom()
  if tHasTournament then
    tdata = [:]
    tdata.addProp(#tournament_logo_url, tConn.GetStrFrom())
    tdata.addProp(#tournament_logo_click_url, tConn.GetStrFrom())
    return me.getGameSystem().sendGameSystemEvent(#loungeinfo, tdata)
  else
    return me.getGameSystem().sendGameSystemEvent(#loungeinfo, [:])
  end if
end

on handle_instancenotavailable me, tMsg
  tConn = tMsg.connection
  tid = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#instancenotavailable, tid)
end

on handle_gameparameters me, tMsg
  tConn = tMsg.connection
  tParamCount = tConn.GetIntFrom()
  tParamList = []
  repeat with i = 1 to tParamCount
    tItem = [:]
    tItem.addProp(#name, tConn.GetStrFrom())
    ttype = tConn.GetIntFrom()
    if ttype = 0 then
      tItem.addProp(#type, #integer)
      tItem.addProp(#default, tConn.GetIntFrom())
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#min, tConn.GetIntFrom())
      end if
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#max, tConn.GetIntFrom())
      end if
    else
      tItem.addProp(#type, #string)
      tItem.addProp(#default, tConn.GetStrFrom())
      tItem.addProp(#choices, [])
      tNumChoices = tConn.GetIntFrom()
      if tNumChoices > 0 then
        repeat with i = 1 to tNumChoices
          tItem[#choices].append(tConn.GetStrFrom)
        end repeat
      end if
    end if
    tParamList.append(tItem)
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#gameparameters, tParamList)
end

on handle_createfailed me, tMsg
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  tReasonStr = me.get_instance_error_str(tReason)
  if tReason = 1 then
    tdata = [#reason: tReason, #request: "create", #reasonstr: tReasonStr, #key: tConn.GetStrFrom()]
  else
    tdata = [#reason: tReason, #request: "create", #reasonstr: tReasonStr]
  end if
  return me.getGameSystem().sendGameSystemEvent(#createfailed, tdata)
end

on handle_gamedeleted me, tMsg
  tConn = tMsg.connection
  tid = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#gamedeleted, tid)
end

on handle_joinparameters me, tMsg
  tConn = tMsg.connection
  tInstanceId = tConn.GetIntFrom()
  tParamCount = tConn.GetIntFrom()
  tParamList = []
  repeat with i = 1 to tParamCount
    tItem = [:]
    tItem.addProp(#name, tConn.GetStrFrom())
    ttype = tConn.GetIntFrom()
    if ttype = 0 then
      tItem.addProp(#type, #integer)
      tItem.addProp(#default, tConn.GetIntFrom())
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#min, tConn.GetIntFrom())
      end if
      if tConn.GetIntFrom() = 1 then
        tItem.addProp(#max, tConn.GetIntFrom())
      end if
    else
      tItem.addProp(#type, #string)
      tItem.addProp(#default, tConn.GetStrFrom())
      tItem.addProp(#choices, [])
      tNumChoices = tConn.GetIntFrom()
      if tNumChoices > 0 then
        repeat with i = 1 to tNumChoices
          tItem[#choices].append(tConn.GetStrFrom)
        end repeat
      end if
    end if
    tParamList.append(tItem)
  end repeat
  return me.getGameSystem().sendGameSystemEvent(#joinparameters, tParamList)
end

on handle_joinfailed me, tMsg
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  tReasonStr = me.get_instance_error_str(tReason)
  if tReason = 1 then
    tdata = [#request: "join", #reason: tReason, #reasonstr: tReasonStr, #key: tConn.GetStrFrom()]
  else
    tdata = [#request: "join", #reason: tReason, #reasonstr: tReasonStr]
  end if
  return me.getGameSystem().sendGameSystemEvent(#joinfailed, tdata)
end

on handle_watchfailed me, tMsg
  tConn = tMsg.connection
  tInstanceId = tConn.GetIntFrom()
  tReason = tConn.GetIntFrom()
  tReasonStr = me.get_instance_error_str(tReason)
  return me.getGameSystem().sendGameSystemEvent(#watchfailed, [#id: tInstanceId, #request: "watch", #reason: tReason, #reasonstr: tReasonStr])
end

on handle_gamelocation me, tMsg
  tConn = tMsg.connection
  tUnitId = tConn.GetIntFrom()
  tWorldId = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#gamelocation, [#unitId: tUnitId, #worldId: tWorldId])
end

on handle_startfailed me, tMsg
  tConn = tMsg.connection
  tReason = tConn.GetIntFrom()
  tReasonStr = me.get_instance_error_str(tReason)
  return me.getGameSystem().sendGameSystemEvent(#startfailed, [#reason: tReason, #request: "start", #reasonstr: tReasonStr])
end

on handle_playerrejoined me, tMsg
  tConn = tMsg.connection
  tid = tConn.GetIntFrom()
  return me.getGameSystem().sendGameSystemEvent(#playerrejoined, [#id: tid])
end

on handle_idlewarning me, tMsg
  return me.getGameSystem().sendGameSystemEvent(#idlewarning, VOID)
end

on get_instance_error_str me, tReason
  case tReason of
    0:
      return "nospace"
    1:
      return "invalidparam"
    2:
      return "notickets"
    3:
      return "noskill"
    4:
      return "dailylimit"
    5:
      return "blockedip"
    6:
      return "kicked"
    7:
      return "alreadythere"
    8:
      return "noplayers"
  end case
  return EMPTY
end
