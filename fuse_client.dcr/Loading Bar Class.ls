property ancestor, pTaskId, pBuffer, pBgColor, pColor, pWidth, pHeight, pRect, pTaskType, pPercent, pWindowID, pUpdateStg

on new me
  return me
end

on construct me
  tProps = getVariableValue("loading.bar.props", [#bgColor: (the stage).bgColor, #color: rgb(128, 128, 128), #width: 128, #height: 16])
  pTaskId = EMPTY
  pBuffer = (the stage).image
  pWidth = tProps[#width]
  pHeight = tProps[#height]
  pBgColor = tProps[#bgColor]
  pColor = tProps[#color]
  pTaskType = #cast
  pWindowID = EMPTY
  pUpdateStg = 0
  return 1
end

on deconstruct me
  pTaskId = VOID
  removePrepare(me.getID())
  if pWindowID <> EMPTY then
    removeWindow(pWindowID)
    pWindowID = EMPTY
  end if
  if pUpdateStg then
    (the stage).bgColor = (the stage).bgColor
  end if
  return 1
end

on define me, tLoadID, tProps
  if not stringp(tLoadID) and not symbolp(tLoadID) then
    return error(me, "Invalid castload task ID:" && tLoadID, #define)
  end if
  pTaskId = tLoadID
  if ilk(tProps, #propList) then
    if ilk(tProps[#buffer], #image) then
      pBuffer = tProps[#buffer]
    end if
    if ilk(tProps[#width], #integer) then
      pWidth = tProps[#width]
    end if
    if ilk(tProps[#height], #integer) then
      pHeight = tProps[#height]
    end if
    if ilk(tProps[#bgColor], #color) then
      pBgColor = tProps[#bgColor]
    end if
    if ilk(tProps[#color], #color) then
      pColor = tProps[#color]
    end if
    if ilk(tProps[#type], #symbol) then
      pTaskType = tProps[#type]
    end if
    if tProps[#buffer] = #window then
      if pWindowID <> EMPTY then
        removeWindow(pWindowID)
      end if
      pWindowID = me.getID() && the milliSeconds
      tX = (the stageRight - the stageLeft) / 2 - pWidth / 2
      tY = (the stageBottom - the stageTop) / 2 - pHeight / 2
      createWindow(pWindowID, "system.window", tX, tY)
      getWindow(pWindowID).resizeTo(pWidth, pHeight)
      pBuffer = getWindow(pWindowID).getSprById("drag").member.image
    end if
  end if
  tRect = pBuffer.rect
  if pWidth > tRect.width then
    pWidth = tRect.width
  end if
  if pHeight > tRect.height then
    pHeight = tRect.height
  end if
  if pBuffer = (the stage).image then
    pUpdateStg = 1
  end if
  pRect = rect(tRect.width / 2 - pWidth / 2, tRect.height / 2 - pHeight / 2, tRect.width / 2 + pWidth / 2, tRect.height / 2 + pHeight / 2)
  pBuffer.fill(pRect, pBgColor)
  pBuffer.draw(pRect, [#color: pColor, #shapeType: #rect])
  return receivePrepare(me.getID())
end

on prepare me
  if voidp(pTaskId) then
    return removeObject(me.getID())
  end if
  case pTaskType of
    #cast:
      tNewPercent = getCastLoadPercent(pTaskId)
    #file:
      tNewPercent = getDownLoadPercent(pTaskId)
  end case
  if pPercent = tNewPercent then
    return 
  end if
  pPercent = tNewPercent
  pBuffer.fill(rect(pRect[1] + 2, pRect[2] + 2, pRect[1] + pPercent * pWidth - 2, pRect[4] - 2), pColor)
  pBuffer.draw(pRect, [#color: pColor, #shapeType: #rect])
  if pUpdateStg then
    updateStage()
  end if
  if pPercent = 1.0 then
    removeObject(me.getID())
  end if
end
