property pState, pDelay, pAnimFrame, pLoczList, pLocShiftList, pPartColors

on prepare me, tdata
  pState = 1
  pDelay = 0
  pAnimFrame = 0
  pLoczList = []
  pLocShiftList = []
  pPartColors = []
  me.solveMembersCustom(tdata[#class] && tdata[#type])
  return 1
end

on updateStuffdata me, tValue
  me.setState(tValue)
end

on update me
  if not pState then
    return 1
  end if
  tThreshold = 2 + random(4)
  if pDelay < tThreshold then
    pDelay = pDelay + 1
    return 1
  end if
  pDelay = 0
  me.setState(pState)
  me.pAnimFrame = me.pAnimFrame + 1
  if me.pAnimFrame > 3 then
    me.pAnimFrame = 1
  end if
end

on setState me, tValue
  pState = tValue
  if pState = 0 then
    tPartStates = [[#sprite: "a", #member: "0"], [#sprite: "b", #member: "0"], [#sprite: "c", #member: "0"]]
  else
    tPartStates = [[#sprite: "a", #member: "1"], [#sprite: "b", #member: string(me.pAnimFrame)], [#sprite: "c", #member: "1"]]
  end if
  repeat with tPart in tPartStates
    tPartId = tPart.sprite
    tmember = tPart.member
    if tmember <> VOID then
      me.switchMember(tPartId, tmember)
    end if
    me.setPartVisible(tPartId, tmember <> VOID)
  end repeat
  return 1
end

on switchMember me, tPart, tNewMem
  tSprNum = charToNum(tPart) - (charToNum("a") - 1)
  if me.pSprList.count < tSprNum or tSprNum <= 0 then
    return 0
  end if
  tName = me.pSprList[tSprNum].member.name
  tName = tName.char[1..tName.length - 1] & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.pSprList[tSprNum].castNum = tmember.number
    me.pSprList[tSprNum].width = tmember.width
    me.pSprList[tSprNum].height = tmember.height
  end if
  return 1
end

on setPartVisible me, tPart, tstate
  tSprNum = charToNum(tPart) - (charToNum("a") - 1)
  if me.pSprList.count < tSprNum or tSprNum <= 0 then
    return 0
  end if
  me.pSprList[tSprNum].visible = tstate
  return 1
end

on solveMembersCustom me, tClass
  if tClass contains "*" then
    tSmallMem = tClass & "_small"
    tClass = tClass.char[1..offset("*", tClass) - 1]
    if not memberExists(tSmallMem) then
      tSmallMem = tClass & "_small"
    end if
  else
    tSmallMem = tClass & "_small"
  end if
  pSmallMember = tSmallMem
  if me.pXFactor = 32 then
    tClass = "s_" & tClass
  end if
  if me.pSprList.count > 0 then
    repeat with tSpr in me.pSprList
      releaseSprite(tSpr.spriteNum)
    end repeat
    me.pSprList = []
  end if
  if me.pDirection = "rightwall" then
    tRealDirection = [4, 4, 4]
  else
    tRealDirection = [2, 2, 2]
  end if
  tMemNum = 1
  i = charToNum("a")
  j = 1
  tLoczAdjust = -5
  repeat while tMemNum > 0
    tFound = 0
    repeat while tFound = 0
      tMemNameA = tClass & "_" & numToChar(i) & "_" & "0" & "_1_1"
      if not voidp(tRealDirection) then
        if count(tRealDirection) >= j then
          tMemName = tMemNameA & "_" & tRealDirection[j] & "_" & me.pAnimFrame
        else
          tMemName = tMemNameA & "_" & tRealDirection[1] & "_" & me.pAnimFrame
        end if
      else
        tMemName = tMemNameA & "_" & me.pAnimFrame
      end if
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if not tMemNum then
        tMemName = tMemNameA & "_0_" & me.pAnimFrame
        tMemNum = getmemnum(tMemName)
      end if
      if not tMemNum and j = 1 then
        tFound = 0
        if listp(tRealDirection) then
          repeat with tdir = 1 to tRealDirection.count
            tRealDirection[tdir] = integer(tRealDirection[tdir] + 1)
          end repeat
          if tRealDirection[1] = 8 then
            error(me, "Couldn't define members:" && tClass, #solveMembers)
            if me.pXFactor = 32 then
              tMemNum = getmemnum("s_room_object_placeholder")
            else
              tMemNum = getmemnum("room_object_placeholder")
            end if
            tRealDirection = [0, 0, 0]
            tFound = 1
          end if
        end if
        next repeat
      end if
      tFound = 1
    end repeat
    if tMemNum <> 0 then
      if count(me.pSprList) >= j then
        tSpr = me.pSprList[j]
      else
        tTargetID = getThread(#room).getInterface().getID()
        tSpr = sprite(reserveSprite(me.getID()))
        me.pSprList.add(tSpr)
        setEventBroker(tSpr.spriteNum, me.getID())
        tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
        tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
        tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
      end if
      if me.pLoczList.count < me.pSprList.count then
        me.pLoczList.add([])
      end if
      if me.pLocShiftList.count < me.pSprList.count then
        me.pLocShiftList.add([])
      end if
      repeat with tdir = 0 to 7
        me.pLoczList.getLast().add(integer(me.solveLocZ(numToChar(i), tdir, tClass)) + tLoczAdjust)
        me.pLocShiftList.getLast().add(me.solveLocShift(numToChar(i), tdir, tClass))
      end repeat
      tLoczAdjust = tLoczAdjust + 1
      if not voidp(tSpr) and tSpr <> sprite(0) then
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
        tSpr.ink = me.solveInk(numToChar(i), tClass)
        tSpr.blend = me.solveBlend(numToChar(i), tClass)
        if j <= me.pPartColors.count then
          if string(me.pPartColors[j]).char[1] = "#" then
            tSpr.bgColor = rgb(me.pPartColors[j])
          else
            tSpr.bgColor = paletteIndex(integer(me.pPartColors[j]))
          end if
        end if
      else
        return error(me, "Out of sprites!!!", #solveMembers)
      end if
    end if
    i = i + 1
    j = j + 1
  end repeat
  if me.pSprList.count > 0 then
    return 1
  else
    return error(me, "Couldn't define members:" && tClass, #solveMembers)
  end if
end
