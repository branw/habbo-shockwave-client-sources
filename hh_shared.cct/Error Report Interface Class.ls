property pWindowID, pCurrentErrorIndex

on construct me
  pWindowID = getText("error_report")
  pCurrentErrorIndex = 1
  return 1
end

on deconstruct me
  return 1
end

on showErrors me
  tReportLists = me.getComponent().getErrorLists()
  if tReportLists.count = 0 then
    return 0
  end if
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "habbo_full.window")
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("error_report_details.window")
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcErrorReport, me.getID(), #mouseUp)
  tIndexOfCurrentReport = tReportLists.count
  tErrorReport = tReportLists[tIndexOfCurrentReport]
  tTexts = [:]
  tTexts["error_report_errorid"] = "ID:" && tErrorReport[#errorId]
  tExplainText = EMPTY
  tExplainText = tErrorReport[#time] & RETURN
  tExplainText = tExplainText & getText("error_report_trigger_message") & ":" && tErrorReport[#errorMsgId]
  tTexts["error_report_details"] = tExplainText
  repeat with tIndex = 1 to tTexts.count
    tElementName = tTexts.getPropAt(tIndex)
    tText = tTexts[tIndex]
    if tWndObj.elementExists(tElementName) then
      tElement = tWndObj.getElement(tElementName)
      tElement.setText(tText)
    end if
  end repeat
end

on hideErrorReportWindow me
  if not windowExists(pWindowID) then
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.close()
end

on eventProcErrorReport me, tEvent, tElemID, tParams
  if tEvent = #mouseUp then
    case tElemID of
      "error_report_ok", "close":
        me.hideErrorReportWindow()
    end case
  end if
end
