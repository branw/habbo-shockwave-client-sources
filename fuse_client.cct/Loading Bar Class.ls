property pTaskId, pBuffer, pBgColor, pcolor, pwidth, pheight, pBarRect, pOffRect, pTaskType, pPercent, pDrawPoint, pWindowID, pExtraTasks, pReadyFlag

on construct me
  tProps = [#bgColor: (the stage).bgColor, #color: rgb(128, 128, 128), #width: 128, #height: 16]
  tProps = getVariableValue("loading.bar.props", tProps)
  pTaskId = EMPTY
  pBuffer = (the stage).image
  pwidth = tProps[#width]
  pheight = tProps[#height]
  pBgColor = tProps[#bgColor]
  pcolor = tProps[#color]
  pTaskType = #cast
  pDrawPoint = 0
  pWindowID = EMPTY
  pReadyFlag = 0
  pExtraTasks = [:]
  registerMessage(#loadingBarSetExtraTaskDone, me.getID(), #setExtraTaskDone)
  return 1
end

on deconstruct me
  pTaskId = VOID
  removePrepare(me.getID())
  if pWindowID <> EMPTY then
    removeWindow(pWindowID)
    pWindowID = EMPTY
  end if
  unregisterMessage(#loadingBarSetExtraTaskDone, me.getID())
  return 1
end

on define me, tLoadID, tProps
  if not stringp(tLoadID) and not symbolp(tLoadID) then
    return error(me, "Invalid castload task ID:" && tLoadID, #define, #major)
  end if
  pTaskId = tLoadID
  pPercent = 0.0
  pDrawPoint = 0
  pReadyFlag = 0
  if ilk(tProps, #propList) then
    if ilk(tProps[#buffer]) = #image then
      pBuffer = tProps[#buffer]
    end if
    if ilk(tProps[#width]) = #integer then
      pwidth = tProps[#width]
    end if
    if ilk(tProps[#height]) = #integer then
      pheight = tProps[#height]
    end if
    if ilk(tProps[#bgColor]) = #color then
      pBgColor = tProps[#bgColor]
    end if
    if ilk(tProps[#color]) = #color then
      pcolor = tProps[#color]
    end if
    if ilk(tProps[#type]) = #symbol then
      pTaskType = tProps[#type]
    end if
    if ilk(tProps[#extraTasks]) = #list then
      repeat with tTask in tProps[#extraTasks]
        pExtraTasks.setaProp(tTask, 0)
      end repeat
    end if
    if tProps[#buffer] = #window then
      if pWindowID <> EMPTY then
        removeWindow(pWindowID)
      end if
      pWindowID = me.getID() && the milliSeconds
      createWindow(pWindowID, "system.window")
      tWndObj = getWindow(pWindowID)
      tWndObj.resizeTo(pwidth, pheight)
      tWndObj.center()
      pBuffer = tWndObj.getElement("drag").getProperty(#buffer).image
    end if
  end if
  if not voidp(tProps[#locY]) then
    tWndObj.moveTo(tWndObj.getProperty(#locX), tProps[#locY])
  end if
  if not voidp(tProps[#locX]) then
    tWndObj.moveTo(tProps[#locX], tWndObj.getProperty(#locY))
  end if
  tRect = pBuffer.rect
  if pwidth > tRect.width then
    pwidth = tRect.width
  end if
  if pheight > tRect.height then
    pheight = tRect.height
  end if
  pBarRect = rect(tRect.width / 2 - pwidth / 2, tRect.height / 2 - pheight / 2, tRect.width / 2 + pwidth / 2, tRect.height / 2 + pheight / 2)
  pOffRect = rect(pBarRect[1] + 2, pBarRect[2] + 2, pBarRect[3] - 2, pBarRect[4] - 2)
  pBuffer.fill(pBarRect, pBgColor)
  pBuffer.draw(pBarRect, [#color: pcolor, #shapeType: #rect])
  return receivePrepare(me.getID())
end

on setExtraTaskDone me, tTaskId
  if not voidp(pExtraTasks.getaProp(tTaskId)) then
    pExtraTasks.setaProp(tTaskId, 1)
  end if
end

on prepare me
  if voidp(pTaskId) or pReadyFlag then
    return removeObject(me.getID())
  end if
  case pTaskType of
    #cast:
      tPercent = getCastLoadManager().getLoadPercent(pTaskId)
    #file:
      tPercent = getDownloadManager().getLoadPercent(pTaskId)
  end case
  repeat with tTask in pExtraTasks
    if not tTask then
      tPercent = tPercent - 0.10000000000000001 / pExtraTasks.count
    end if
  end repeat
  pDrawPoint = pDrawPoint + 1
  if pDrawPoint <= pPercent * pOffRect.width then
    tRect = rect(pOffRect[1] + pDrawPoint - 1, pOffRect[2], pOffRect[1] + pDrawPoint, pOffRect[4])
    pBuffer.fill(tRect, pcolor)
  end if
  if pPercent = tPercent then
    return 
  end if
  pBuffer.fill(pBarRect, pBgColor)
  pBuffer.draw(pBarRect, [#color: pcolor, #shapeType: #rect])
  tRect = rect(pOffRect[1], pOffRect[2], pPercent * pOffRect.width + pOffRect[1], pOffRect[4])
  pBuffer.fill(tRect, pcolor)
  pDrawPoint = pPercent * pOffRect.width
  pPercent = tPercent
  if pPercent >= 1.0 then
    pBuffer.fill(pOffRect, pcolor)
    pReadyFlag = 1
  end if
end

on handlers
  return []
end
