property fireplaceOn, formulaFrame, tvFrame, carLoop, carLoopCount, stillWait

on prepare me, tdata
  tvFrame = 0
  formulaFrame = 0
  carLoop = 1
  stillWait = 0
  if tdata[#stuffdata] = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  return 1
end

on updateStuffdata me, tValue
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me
  if me.pSprList.count < 4 then
    return 
  end if
  tvFrame = tvFrame + 1
  if fireplaceOn and tvFrame >= 3 then
    tvFrame = 0
    tName = me.pSprList[4].member.name
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tTmpName = tName.item[1..tName.item.count - 1] & "_"
    the itemDelimiter = tDelim
    if carLoop = 1 then
      carLoopCount = 4 + random(7)
    end if
    if carLoop >= 1 then
      tNewName = tTmpName & formulaFrame
      formulaFrame = formulaFrame + 1
      if formulaFrame > 13 then
        if carLoop < carLoopCount then
          formulaFrame = 1
          carLoop = carLoop + 1
        else
          carLoop = 0
          tNewName = tTmpName & "14"
          stillWait = 200 + random(200)
        end if
      end if
    else
      if carLoop = 0 then
        if formulaFrame <= stillWait then
          formulaFrame = formulaFrame + 1
          return 1
        else
          formulaFrame = 0
          carLoop = 1
          return 1
        end if
      end if
    end if
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[4].castNum = tmember.number
      me.pSprList[4].width = tmember.width
      me.pSprList[4].height = tmember.height
    end if
  end if
  if fireplaceOn = 0 then
    tNewName = "tv_luxus_d_0_1_3_0_0"
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[4].castNum = tmember.number
      me.pSprList[4].width = tmember.width
      me.pSprList[4].height = tmember.height
    end if
  end if
  me.pSprList[4].locZ = me.pSprList[1].locZ + 2
end

on setOn me
  stillWait = 0
  carLoop = 1
  formulaFrame = 0
  fireplaceOn = 1
end

on setOff me
  fireplaceOn = 0
end

on select me
  if the doubleClick then
    if fireplaceOn then
      tOnString = "OFF"
    else
      tOnString = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tOnString])
  end if
end
