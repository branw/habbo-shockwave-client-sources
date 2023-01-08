property pStateSequenceList, pStateIndex, pState, pLayerDataList, pFrameNumberList, pLoopCountList, pBlendList, pInkList, pLoczList, pLocShiftList, pNameBase

on define me, tProps
  pStateSequenceList = []
  pStateIndex = 1
  pState = 1
  pLayerDataList = [:]
  pFrameNumberList = []
  pLoopCountList = []
  pBlendList = []
  pInkList = []
  pLoczList = []
  pLocShiftList = []
  pNameBase = EMPTY
  tClass = tProps[#class]
  ttype = tProps[#type]
  case tClass of
    "poster":
      pNameBase = "poster" && ttype
    "post.it.vd", "post.it", "photo":
      pNameBase = "wallitem" && tClass
  end case
  tDataName = pNameBase & ".data"
  if getThread(#room).getInterface().getGeometry().pXFactor = 32 then
    tDataName = "s_" & tDataName
  end if
  if memberExists(tDataName) then
    tText = member(getmemnum(tDataName)).text
    tText = replaceChunks(tText, RETURN, EMPTY)
    tdata = value(tText)
    if not voidp(tdata) then
      if tdata.ilk = #propList then
        pStateSequenceList = tdata[#states]
        pLayerDataList = tdata[#layers]
        if voidp(pLayerDataList) then
          pLayerDataList = [:]
        end if
        if voidp(pStateSequenceList) then
          pStateSequenceList = []
        end if
        if not me.validateStateSequenceList() then
          pStateSequenceList = []
        end if
      end if
    end if
  end if
  tstate = 1
  me.setState(tstate)
  me.resetFrameNumbers()
  tCount = 1
  if pLayerDataList.count > 0 then
    tCount = pLayerDataList.count
  end if
  repeat with tLayer = 1 to tCount
    tLayerName = EMPTY
    if pLayerDataList.count >= tLayer then
      tLayerName = pLayerDataList.getPropAt(tLayer)
    end if
    pInkList[tLayer] = me.solveInk(tLayerName)
    pBlendList[tLayer] = me.solveBlend(tLayerName)
  end repeat
  return callAncestor(#define, [me], tProps)
end

on select me
  if the doubleClick then
    me.getNextState()
  end if
  return 1
end

on update me
  repeat with tLayer = 1 to pLayerDataList.count
    tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
    if not voidp(tFrameList) then
      tLoop = pLoopCountList[tLayer]
      if pLoopCountList[tLayer] > 0 then
        pLoopCountList[tLayer] = pLoopCountList[tLayer] - 1
      end if
      if not voidp(tFrameList[#frames]) then
        tFrameCount = tFrameList[#frames].count
        if tFrameCount > 0 then
          if pFrameNumberList[tLayer] < tFrameCount or tLoop then
            pFrameNumberList[tLayer] = pFrameNumberList[tLayer] mod tFrameCount + 1
          end if
        end if
      end if
    end if
  end repeat
  me.solveMembers()
  return 1
end

on updateLocation me
  callAncestor(#updateLocation, [me])
  tDirection = me.pDirection
  if ilk(tDirection) = #string then
    if tDirection = "leftwall" then
      tDirection = 2
    else
      if tDirection = "rightwall" then
        tDirection = 4
      end if
    end if
  end if
  if ilk(tDirection) = #integer then
    tCount = 1
    if pLayerDataList.count > 0 then
      tCount = pLayerDataList.count
    end if
    repeat with tLayer = 1 to tCount
      tLayerName = EMPTY
      if pLayerDataList.count >= tLayer then
        tLayerName = pLayerDataList.getPropAt(tLayer)
      end if
      tlocz = me.solveLocZ(tLayerName)
      me.pSprList[tLayer].locZ = me.pSprList[tLayer].locZ + tlocz
      tLocShift = me.solveLocShift(tLayerName)
      if ilk(tLocShift) = #point then
        me.pSprList[tLayer].loc = me.pSprList[tLayer].loc + tLocShift
      end if
    end repeat
  end if
end

on solveMembers me
  tMembersFound = 0
  tCount = 1
  if pLayerDataList.count > 0 then
    tCount = pLayerDataList.count
  end if
  repeat with tLayer = 1 to tCount
    tLayerName = EMPTY
    if pLayerDataList.count >= tLayer then
      tLayerName = pLayerDataList.getPropAt(tLayer)
      tMemName = me.getMemberName(tLayerName)
    else
      tMemName = me.getMemberName()
    end if
    if me.pSprList.count < tLayer then
      tSpr = sprite(reserveSprite(me.getID()))
      tTargetID = getThread(#room).getInterface().getID()
      setEventBroker(tSpr.spriteNum, me.getID())
      tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
      tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
      tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
      me.pSprList.add(tSpr)
    else
      tSpr = me.pSprList[tLayer]
    end if
    tMemNum = getmemnum(tMemName)
    if tMemNum <> 0 then
      tMembersFound = tMembersFound + 1
      if tMemNum < 1 then
        tMemNum = abs(tMemNum)
        tSpr.flipH = 1
      end if
      tSpr.ink = pInkList[tLayer]
      tSpr.blend = pBlendList[tLayer]
      tSpr.castNum = tMemNum
      tSpr.width = member(tMemNum).width
      tSpr.height = member(tMemNum).height
    else
      tSpr.width = 0
      tSpr.height = 0
      tSpr.castNum = 0
    end if
    me.postProcessLayer(tLayer)
  end repeat
  if tMembersFound = 0 then
    return 0
  end if
  return 1
end

on postProcessLayer me, tLayer
  return 1
end

on getMemberName me, tLayer
  tName = me.pDirection && pNameBase
  tLayerIndex = pLayerDataList.findPos(tLayer)
  tFrameList = me.getFrameList(tLayer)
  if not voidp(tFrameList) and not voidp(tLayerIndex) then
    tFrameSequence = tFrameList[#frames]
    if not voidp(tFrameSequence) then
      tFrameNumber = pFrameNumberList[tLayerIndex]
      tName = tName & "_" & tLayer & "_" & tFrameSequence[tFrameNumber]
    end if
  end if
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  return tName
end

on getFrameList me, tLayer
  if not voidp(tLayer) then
    if not voidp(pLayerDataList[tLayer]) then
      tLayerData = pLayerDataList[tLayer]
      tAction = pState
      if tAction > tLayerData.count then
        tAction = 1
      end if
      if tAction >= 1 and tAction <= tLayerData.count then
        tActionData = tLayerData[tAction]
        return tActionData
      end if
    end if
  end if
  return VOID
end

on setState me, tNewState
  tNewIndex = 0
  repeat with tIndex = 1 to pStateSequenceList.count
    tstate = pStateSequenceList[tIndex]
    if ilk(tstate) = #list then
      repeat with tIndex2 = 1 to tstate.count
        if tstate[tIndex2] = tNewState then
          tNewIndex = tIndex
          exit repeat
        end if
      end repeat
    else
      if tstate = tNewState then
        tNewIndex = tIndex
      end if
    end if
    if tNewIndex <> 0 then
      pStateIndex = tNewIndex
      pState = tNewState
      me.resetFrameNumbers()
      repeat with tLayer = 1 to pLayerDataList.count
        tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
        if not voidp(tFrameList) then
          tLoop = 1
          if not voidp(tFrameList[#loop]) then
            tLoop = tFrameList[#loop] - 1
          end if
          pLoopCountList[tLayer] = tLoop
        end if
      end repeat
      return 1
    end if
  end repeat
  return 0
end

on getNextState me
  if pStateSequenceList.count < 1 then
    return 0
  end if
  tStateIndex = pStateIndex mod pStateSequenceList.count + 1
  tstate = pStateSequenceList[tStateIndex]
  if ilk(tstate) = #list then
    if tstate.count < 1 then
      return 0
    end if
    tStateNew = tstate[random(tstate.count)]
  else
    tStateNew = tstate
  end if
  return me.setState(tStateNew)
end

on validateStateSequenceList me
  tstatelist = []
  repeat with tIndex = 1 to pStateSequenceList.count
    tstate = pStateSequenceList[tIndex]
    if ilk(tstate) = #list then
      if tstate.count < 1 then
        return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList)
      end if
      repeat with tIndex2 = 1 to tstate.count
        tState2 = tstate[tIndex2]
        if tState2 < 1 then
          return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList)
        end if
        if tstatelist.count < tState2 then
          tstatelist[tState2] = 1
          next repeat
        end if
        if tstatelist[tState2] > 0 then
          return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList)
        end if
      end repeat
      next repeat
    end if
    if tstate < 1 then
      return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList)
    end if
    if tstatelist.count < tstate then
      tstatelist[tstate] = 1
      next repeat
    end if
    if tstatelist[tstate] > 0 then
      return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList)
    end if
  end repeat
  return 1
end

on resetFrameNumbers me
  pFrameNumberList = []
  repeat with i = 1 to pLayerDataList.count
    pFrameNumberList[i] = 1
  end repeat
end

on solveInk me, tPart
  tName = pNameBase
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk)
    else
      if tPropList[tPart] <> VOID then
        if tPropList[tPart][#ink] <> VOID then
          return tPropList[tPart][#ink]
        end if
      end if
    end if
  end if
  return 8
end

on solveBlend me, tPart
  tName = pNameBase
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk)
    else
      if tPropList[tPart] <> VOID then
        if tPropList[tPart][#blend] <> VOID then
          return tPropList[tPart][#blend]
        end if
      end if
    end if
  end if
  return 100
end

on solveLocShift me, tPart, tdir
  tName = pNameBase
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  if not memberExists(tName & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(tName & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tName & ".props is not valid!", #solveLocShift)
    return 0
  else
    if voidp(tPropList[tPart]) then
      return 0
    end if
    if voidp(tPropList[tPart][#locshift]) then
      return 0
    end if
    if tPropList[tPart][#locshift].count <= tdir then
      return 0
    end if
    tShift = value(tPropList[tPart][#locshift][tdir + 1])
    if ilk(tShift) = #point then
      return tShift
    end if
  end if
  return 0
end

on solveLocZ me, tPart, tdir
  tName = pNameBase
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  if not memberExists(tName & ".props") then
    return charToNum(tPart)
  end if
  tPropList = value(field(getmemnum(tName & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tName & ".props is not valid!", #solveLocZ)
    return 0
  else
    if tPropList[tPart] = VOID then
      return 0
    end if
    if tPropList[tPart][#zshift] = VOID then
      return 0
    end if
    if tPropList[tPart][#zshift].count <= tdir then
      tdir = 0
    end if
  end if
  return tPropList[tPart][#zshift][tdir + 1]
end
