property pStateSequenceList, pStateIndex, pState, pStateStringList, pLayerDataList, pFrameNumberList, pFrameNumberList2, pLoopCountList, pFrameRepeatList, pIsAnimatingList, pBlendList, pInkList, pNameBase, pInitialized

on define me, tProps
  pStateSequenceList = []
  pStateIndex = 1
  pState = 1
  pLayerDataList = [:]
  pStateStringList = []
  pFrameNumberList = []
  pFrameNumberList2 = []
  pLoopCountList = []
  pBlendList = []
  pInkList = []
  pLoczList = []
  pLocShiftList = []
  pFrameRepeatList = []
  pIsAnimatingList = []
  tClass = tProps[#class]
  tOffset = offset("*", tClass)
  if tOffset > 0 then
    tClass = tClass.char[1..tOffset - 1]
  end if
  pNameBase = tClass
  if getThread(#room).getInterface().getGeometry().pXFactor = 32 then
    pNameBase = "s_" & pNameBase
  end if
  tDataName = pNameBase & ".data"
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
        if voidp(pStateStringList) then
          pStateStringList = []
        end if
        if not me.validateStateSequenceList() then
          pStateSequenceList = []
        end if
      end if
    end if
  end if
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
    pInkList[tLayer] = me.solveInk(tLayerName, pNameBase)
    pBlendList[tLayer] = me.solveBlend(tLayerName, pNameBase)
  end repeat
  pInitialized = 0
  return callAncestor(#define, [me], tProps)
end

on prepare me, tdata
  tstate = tdata[#stuffdata]
  if pStateStringList.findPos(tstate) > 0 then
    tstate = pStateStringList.findPos(tstate)
  end if
  me.setState(tstate)
  me.resetFrameNumbers()
  callAncestor(#prepare, [me], tdata)
  return 1
end

on select me
  if the doubleClick then
    me.getNextState()
  else
    getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short: me.pLocX, #short: me.pLocY])
  end if
  callAncestor(#select, [me])
  return 1
end

on update me
  if pIsAnimatingList.findPos(1) = 0 then
    return 1
  end if
  tIsAnimatingList = []
  repeat with tLayer = 1 to pLayerDataList.count
    tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
    tIsAnimatingList[tLayer] = pIsAnimatingList[tLayer]
    if not voidp(tFrameList) and tIsAnimatingList[tLayer] then
      if not voidp(tFrameList[#frames]) then
        tDelay = tFrameList[#delay]
        if voidp(tDelay) or voidp(integer(tDelay)) or tDelay < 1 then
          tDelay = 1
        end if
        if pFrameRepeatList[tLayer] >= tDelay then
          tLoop = pLoopCountList[tLayer]
          tFrameCount = tFrameList[#frames].count
          if tFrameCount > 0 then
            if pFrameNumberList[tLayer] = tFrameCount then
              if pLoopCountList[tLayer] > 0 then
                pLoopCountList[tLayer] = pLoopCountList[tLayer] - 1
              end if
              if pLoopCountList[tLayer] = 0 then
                tIsAnimatingList[tLayer] = 0
              end if
            end if
            if pFrameNumberList[tLayer] < tFrameCount or tLoop then
              pFrameNumberList[tLayer] = pFrameNumberList[tLayer] mod tFrameCount + 1
              tRandom = 0
              if not voidp(tFrameList[#random]) then
                tRandom = 1
              end if
              if tRandom and tFrameCount > 1 then
                tValue = random(tFrameCount)
                if tValue = pFrameNumberList2[tLayer] then
                  tValue = pFrameNumberList2[tLayer] mod tFrameCount + 1
                end if
                pFrameNumberList2[tLayer] = tValue
              else
                pFrameNumberList2[tLayer] = pFrameNumberList[tLayer]
              end if
              if not voidp(tFrameList[#blend]) then
                tBlendList = tFrameList[#blend]
                if tBlendList.count >= pFrameNumberList2[tLayer] then
                  me.pSprList[tLayer].blend = tBlendList[pFrameNumberList2[tLayer]]
                end if
              end if
            end if
          end if
          pFrameRepeatList[tLayer] = 1
          next repeat
        end if
        pFrameRepeatList[tLayer] = pFrameRepeatList[tLayer] + 1
      end if
    end if
  end repeat
  me.solveMembers()
  repeat with tLayer = 1 to pLayerDataList.count
    pIsAnimatingList[tLayer] = tIsAnimatingList[tLayer]
  end repeat
  return 1
end

on solveMembers me
  if not pInitialized then
    callAncestor(#solveMembers, [me])
  end if
  tMembersFound = 0
  tCount = me.pLocShiftList.count
  if pLayerDataList.count > 0 then
    tCount = pLayerDataList.count
  end if
  repeat with tLayer = 1 to tCount
    tAnimating = 1
    if pIsAnimatingList.count >= tLayer then
      tAnimating = pIsAnimatingList[tLayer]
    end if
    if tAnimating then
      tLayerName = numToChar(charToNum("a") + tLayer - 1)
      if pLayerDataList.count >= tLayer then
        tLayerName = pLayerDataList.getPropAt(tLayer)
      end if
      tMemName = me.getMemberName(tLayerName)
      if me.pSprList.count < tLayer then
        tSpr = sprite(reserveSprite(me.getID()))
        tTargetID = getThread(#room).getInterface().getID()
        tLayerName = pLayerDataList.getPropAt(tLayer)
        if me.solveTransparency(tLayerName) = 0 then
          setEventBroker(tSpr.spriteNum, me.getID())
          tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
          tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
          tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
        end if
        me.pSprList.add(tSpr)
      else
        tSpr = me.pSprList[tLayer]
        if not pInitialized then
          if me.solveTransparency(tLayerName) then
            removeEventBroker(tSpr.spriteNum)
          end if
        end if
      end if
      tMemNum = getmemnum(tMemName)
      if tMemNum <> 0 then
        tMembersFound = tMembersFound + 1
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        else
          tSpr.rotation = 0
          tSpr.skew = 0
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
      else
        tSpr.width = 0
        tSpr.height = 0
        tSpr.castNum = 0
      end if
      if not pInitialized then
        if pInkList.count < tLayer then
          pInkList[tLayer] = me.solveInk(tLayerName, pNameBase)
        end if
        if pBlendList.count < tLayer then
          pBlendList[tLayer] = me.solveBlend(tLayerName, pNameBase)
        end if
        tSpr.ink = pInkList[tLayer]
        tSpr.blend = pBlendList[tLayer]
      end if
      me.postProcessLayer(tLayer)
      next repeat
    end if
    if me.pSprList.count >= tLayer then
      tSpr = me.pSprList[tLayer]
      if tSpr.castNum <> 0 then
        tMembersFound = tMembersFound + 1
      end if
    end if
  end repeat
  pInitialized = 1
  if tMembersFound = 0 then
    return 0
  else
    return 1
  end if
end

on postProcessLayer me, tLayer
  return 1
end

on getMemberName me, tLayer
  tName = pNameBase
  tLayerIndex = pLayerDataList.findPos(tLayer)
  tFrameList = me.getFrameList(tLayer)
  tDirection = 0
  if not voidp(me.pDirection) then
    if me.pDirection.count >= 1 then
      tDirection = me.pDirection[1]
    end if
  end if
  tFrame = 0
  if not voidp(tFrameList) and not voidp(tLayerIndex) then
    tFrameSequence = tFrameList[#frames]
    if not voidp(tFrameSequence) then
      tFrameNumber = pFrameNumberList2[tLayerIndex]
      tFrame = tFrameSequence[tFrameNumber]
      if tFrame < 0 then
        tFrame = random(abs(tFrame))
      end if
    end if
  end if
  tName = tName & "_" & tLayer & "_0_" & me.pDimensions[1] & "_" & me.pDimensions[2] & "_" & tDirection & "_" & tFrame
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

on updateStuffdata me, tValue
  if ilk(tValue) = #string then
    if pStateStringList.findPos(tValue) > 0 then
      tValue = pStateStringList.findPos(tValue)
    end if
  end if
  me.setState(value(tValue))
end

on setState me, tNewState
  repeat with tLayer = 1 to pLayerDataList.count
    pLoopCountList[tLayer] = 0
  end repeat
  if tNewState = EMPTY then
    tNewState = 1
  end if
  if ilk(value(tNewState)) <> #integer then
    return 0
  end if
  tNewState = value(tNewState)
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
      me.solveMembers()
      me.updateLocation()
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
  tStr = string(tStateNew)
  if pStateStringList.count >= tStateNew then
    tStr = string(pStateStringList[tStateNew])
  end if
  return getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
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
  pFrameRepeatList = []
  pIsAnimatingList = []
  pFrameNumberList = []
  pFrameNumberList2 = []
  repeat with i = 1 to max(me.pLocShiftList.count, pLayerDataList.count)
    pFrameNumberList[i] = 1
    pFrameNumberList2[i] = 1
    pFrameRepeatList[i] = 1
    pIsAnimatingList[i] = 1
  end repeat
end

on solveTransparency me, tPart
  tName = pNameBase
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk)
    else
      if tPropList[tPart] <> VOID then
        if tPropList[tPart][#transparent] <> VOID then
          return tPropList[tPart][#transparent]
        end if
      end if
    end if
  end if
  return 0
end
