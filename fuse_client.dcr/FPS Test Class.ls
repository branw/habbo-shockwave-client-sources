property pWndID, pTimerA, pTimerB, pFrames, pCurrMs, pFieldA, pFieldB

on new me
  return me
end

on construct me
  pWndID = "PerfTest"
  pTimerA = the milliSeconds
  pTimerB = the milliSeconds
  pFrames = 0
  pCurrMs = 0
  createWindow(pWndID, "performance.window")
  tInstance = getWindow(pWndID)
  tInstance.center()
  tInstance.registerClient(me.getID())
  tInstance.registerProcedure(#eventProcPerf, me.getID(), #mouseUp)
  tInstance.getElement("perf_per_frm").setEdit(0)
  tInstance.getElement("perf_total").setEdit(0)
  tInstance.getElement("close").setEdit(0)
  tInstance.getElement("close").setText("x")
  tMember = tInstance.getSprById("close").member
  tMember.alignment = "center"
  tMember.fontStyle = "plain"
  tMember.boxDropShadow = 1
  pFieldA = tInstance.getElement("perf_per_frm").getProperty(#sprite).member
  pFieldB = tInstance.getElement("perf_total").getProperty(#sprite).member
  return receiveUpdate(me.getID())
end

on deconstruct me
  pFieldA = VOID
  pFieldB = VOID
  removeUpdate(me.getID())
  removeWindow(pWndID)
  return 1
end

on update me
  pFrames = (pFrames + 1) mod the frameTempo
  tTime = the milliSeconds - pTimerA
  pFieldA.text = tTime && "ms."
  if pFrames = 0 then
    tCurrMs = the milliSeconds - pTimerB
    if tCurrMs <> pCurrMs then
      pCurrMs = tCurrMs
      pFieldB.text = pCurrMs && "ms."
    end if
    pTimerB = the milliSeconds
  end if
  pTimerA = the milliSeconds
end

on eventProcPerf me, tEvent, tSprID, tParam
  if tSprID = "close" then
    return removeObject(me.getID())
  end if
  return 0
end
