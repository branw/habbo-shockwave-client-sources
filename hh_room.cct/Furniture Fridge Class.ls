property pTokenList, pDoorTimer

on prepare me
  tTokenList = getText("obj_" & me.pClass, "juice")
  pTokenList = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  repeat with i = 1 to tTokenList.item.count
    pTokenList.add(tTokenList.item[i].word[1..tTokenList.item[i].word.count])
  end repeat
  the itemDelimiter = tDelim
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "TRUE" then
    pDoorTimer = 43
  else
    pDoorTimer = 0
  end if
end

on select me
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  if tUserObj = 0 then
    return 1
  end if
  case me.pDirection[1] of
    4:
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = -1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY + 1)
      end if
    0:
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = 1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY - 1)
      end if
    2:
      if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = -1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX + 1 && me.pLocY)
      end if
    6:
      if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = 1 then
        if the doubleClick then
          me.giveDrink()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX - 1 && me.pLocY)
      end if
  end case
  return 1
end

on giveDrink me
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return 0
  end if
  tConnection.send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "DOOROPEN" & "/" & "TRUE")
  tConnection.send(#room, "LOOKTO" && me.pLocX && me.pLocY)
  tConnection.send(#room, "CarryDrink" && me.getDrinkname())
end

on getDrinkname me
  return pTokenList[random(pTokenList.count)]
end

on update me
  if pDoorTimer <> 0 then
    if me.pSprList.count < 1 then
      return 
    end if
    tCurName = me.pSprList[1].member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & 1
    tmember = member(abs(getmemnum(tNewName)))
    pDoorTimer = pDoorTimer - 1
    if pDoorTimer = 0 then
      tCurName = me.pSprList[1].member.name
      tNewName = tCurName.char[1..length(tCurName) - 1] & 0
      tmember = member(getmemnum(tNewName))
    end if
    me.pSprList[1].castNum = tmember.number
    me.pSprList[1].width = tmember.width
    me.pSprList[1].height = tmember.height
  end if
end
