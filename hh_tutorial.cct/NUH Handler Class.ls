on construct me
  me.registerServerMessages(1)
  return 1
end

on deconstruct me
  return 1
end

on handleHelpItems me, tMsg
  tConn = tMsg.getaProp(#connection)
  tIdCount = tConn.GetIntFrom()
  tdata = [:]
  repeat with tNo = 1 to tIdCount
    tID = tConn.GetIntFrom()
    tKey = EMPTY
    case tID of
      1:
        tKey = "own_user"
      2:
        tKey = "messenger"
      3:
        tKey = "navigator"
      4:
        tKey = "chat"
      5:
        tKey = "hand"
    end case
    if tKey <> EMPTY then
      tdata[tKey] = 1
    end if
  end repeat
  me.getComponent().setHelpStatusData(tdata)
end

on registerServerMessages me, tBool
  tMsgs = [:]
  tMsgs.setaProp(352, #handleHelpItems)
  tCmds = [:]
  tCmds.setaProp("MSG_REMOVE_ACCOUNT_HELP_TEXT", 313)
  if tBool then
    registerListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #Info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #Info), me.getID(), tCmds)
  end if
  return 1
end
