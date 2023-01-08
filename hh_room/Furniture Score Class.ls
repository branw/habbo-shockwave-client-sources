property pScore, pBoardImg

on prepare me, tdata
  pScore = 0
  tTemp = tdata.getaProp(#stuffdata)
  me.setScore(tTemp)
  return 1
end

on relocate me
  me.setScore(pScore)
end

on updateStuffdata me, tValue
  me.setScore(tValue)
end

on setScore me, tScore
  if me.pSprList.count < 4 then
    return 0
  end if
  if me.pXFactor = 32 then
    tClass = "s_hockey_score"
    if me.pDirection[1] = 2 then
      tLoc3 = me.pSprList[1].loc + [26, -100]
      tLoc4 = me.pSprList[1].loc + [32, -103]
    else
      tLoc3 = me.pSprList[1].loc + [-44, -105]
      tLoc4 = me.pSprList[1].loc + [-38, -102]
    end if
  else
    tClass = "hockey_score"
    if me.pDirection[1] = 2 then
      tLoc3 = me.pSprList[1].loc + [26, -100]
      tLoc4 = me.pSprList[1].loc + [36, -105]
    else
      tLoc3 = me.pSprList[1].loc + [-44, -105]
      tLoc4 = me.pSprList[1].loc + [-34, -100]
    end if
  end if
  if tScore = "x" then
    pScore = "x"
    me.pSprList[3].blend = 0
    me.pSprList[4].blend = 0
    return 1
  end if
  pScore = integer(tScore)
  if pScore.ilk <> #integer then
    pScore = 0
  end if
  if pScore < 0 then
    pScore = 99
  end if
  if pScore > 99 then
    pScore = 0
  end if
  tString = string(pScore)
  if length(tString) = 1 then
    tString = "0" & tString
  end if
  me.pSprList[3].member = member(getmemnum(tClass & "_" & me.pDirection[1] & "_" & tString.char[1]))
  me.pSprList[4].member = member(getmemnum(tClass & "_" & me.pDirection[1] & "_" & tString.char[2]))
  me.pSprList[3].loc = tLoc3
  me.pSprList[4].loc = tLoc4
  me.pSprList[3].width = me.pSprList[3].member.width
  me.pSprList[3].height = me.pSprList[3].member.height
  me.pSprList[4].width = me.pSprList[4].member.width
  me.pSprList[4].height = me.pSprList[4].member.height
  me.pSprList[3].blend = 100
  me.pSprList[4].blend = 100
  return 1
end

on select me
  tUpdate = 0
  tScore = pScore
  tloc = point(the mouseH - me.pSprList[1].left, the mouseV - me.pSprList[1].top)
  if me.pXFactor = 32 then
    tRect1 = rect(0, 53, 12, 66)
    tRect2 = rect(13, 53, 23, 66)
  else
    tRect1 = rect(14, 108, 22, 116)
    tRect2 = rect(26, 108, 34, 116)
  end if
  if pScore <> "x" then
    if inside(tloc, tRect1) then
      tUpdate = 1
      tScore = tScore - 1
      if tScore < 0 then
        tScore = 99
      end if
    else
      if inside(tloc, tRect2) then
        tUpdate = 1
        tScore = tScore + 1
        if tScore > 99 then
          tScore = 0
        end if
      end if
    end if
  end if
  if tUpdate = 0 and the doubleClick then
    tUpdate = 1
    if pScore = "x" then
      tScore = 0
    else
      tScore = "x"
    end if
  end if
  if tUpdate then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: string(tScore)])
  end if
  return 1
end
