property ancestor

on new me
  return me
end

on construct me
  me.pItemList = []
  me.pItemList.sort()
  return 1
end

on create me, tid, tHost, tPort, tProtocol
  if not symbolp(tid) and not stringp(tid) then
    return error(me, "Symbol or string expected:" && tid, #create)
  end if
  if not stringp(tHost) then
    return error(me, "String expected:" && tHost, #create)
  end if
  if not integerp(tPort) then
    return error(me, "Integer expected:" && tPort, #create)
  end if
  if the controlDown and keyPressed("c") and keyPressed("l") then
    tConnectionTrace = 1
  else
    tConnectionTrace = 0
  end if
  if getIntVariable("connection.log.level") = 2 or tConnectionTrace then
    if not memberExists("connectionLog.text") then
      tLogField = member(createMember("connectionLog.text", #field))
      tLogField.boxType = #scroll
      tLogField.rect = rect(0, 0, 300, 250)
    else
      tLogField = member(getmemnum("connectionLog.text"))
    end if
    tLogField.text = tLogField.text & RETURN & "Connection logging" && tid & RETURN
  end if
  if tConnectionTrace then
    setVariable("debug", 2)
    createWindow("ConnectionLog", "system.window")
    getWindow("ConnectionLog").resizeTo(300, 250)
    getWindow("ConnectionLog").getSprById("drag").setMember(tLogField)
    getWindow("ConnectionLog").getSprById("drag").height = 250
  end if
  if not me.exists(tid) then
    if not createObject(tid, getClassVariable("connection.instance.class")) then
      return error(me, "Failed to initialize connection:" && tid, #create)
    end if
    me.pItemList.add(tid)
  end if
  me.get(tid).setProtocol(tProtocol)
  me.get(tid).connect(tHost, tPort)
  return 1
end

on closeAll me
  repeat with i = 1 to me.pItemList.count
    if objectExists(me.pItemList[i]) then
      removeObject(me.pItemList[i])
    end if
  end repeat
  me.pItemList = []
end
