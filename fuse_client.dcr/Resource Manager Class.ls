property ancestor, pAllMemNumList, pDynMemNumList, pBmpMemNumList, pLegalDuplicates, pBin

on new me
  return me
end

on construct me
  pAllMemNumList = [:]
  pAllMemNumList.sort()
  pDynMemNumList = []
  pDynMemNumList.sort()
  pBmpMemNumList = []
  pBmpMemNumList.sort()
  pBin = getVariable("dynamic.bin.cast", "bin")
  pLegalDuplicates = getVariableValue("legal.duplicate.names", ["thread.index", "memberalias.index", "variable.index"])
  if the runMode contains "Author" then
    me.emptyDynamicBin()
  end if
  return 1
end

on deconstruct me
  if the runMode contains "Author" then
    me.deleteDynamicMembers()
  end if
  pAllMemNumList = [:]
  return 1
end

on getProperty me, tPropID
  case tPropID of
    #memberCount:
      return pAllMemNumList.count()
    #dynMemCount:
      return pDynMemNumList.count()
  end case
  return 0
end

on setProperty me, tPropID, tValue
  -- ERROR: Could not identify jmp
  return 0
end

on createMember me, tMemName, ttype
  if not voidp(pAllMemNumList[tMemName]) then
    error(me, "Member already exists:" && tMemName, #createMember)
    return me.getmemnum(tMemName)
  end if
  if ttype = #bitmap and pBmpMemNumList.count <> 0 then
    tMember = member(pBmpMemNumList[1])
    pBmpMemNumList.deleteAt(1)
  else
    tMember = new(ttype, castLib(pBin))
    if not ilk(tMember, #member) then
      return error(me, "Failed to create member:" && tMemName && ttype, #createMember)
    end if
  end if
  tMember.name = tMemName
  tMemNum = tMember.number
  pAllMemNumList[tMemName] = tMemNum
  pDynMemNumList.add(tMemNum)
  return tMemNum
end

on removeMember me, tMemName
  tMemNum = pAllMemNumList[tMemName]
  if pDynMemNumList.getPos(tMemNum) < 1 then
    return error(me, "Can't delete member:" && tMemName, #removeMember)
  end if
  tMember = member(tMemNum)
  if tMember.type = #bitmap then
    tMember.name = EMPTY
    tMember.image = image(1, 1, 8)
    pBmpMemNumList.add(tMemNum)
  else
    tMember.erase()
  end if
  pDynMemNumList.deleteOne(tMemNum)
  pAllMemNumList.deleteProp(tMemName)
  return 1
end

on updateMember me, tMemName
  if not stringp(tMemName) then
    return error(me, "Member's name required:" && tMemName, #updateMember)
  end if
  if not me.unregisterMember(tMemName) then
    return 0
  end if
  if not me.registerMember(tMemName) then
    return 0
  end if
  return 1
end

on registerMember me, tMemName, tMemberNum
  if voidp(tMemberNum) then
    tMemberNum = member(tMemName).number
  end if
  if tMemberNum < 1 then
    return 0
  end if
  pAllMemNumList[tMemName] = tMemberNum
  return tMemberNum
end

on unregisterMember me, tMemName
  if voidp(pAllMemNumList[tMemName]) then
    return 0
  end if
  pAllMemNumList.deleteProp(tMemName)
  return 1
end

on preIndexMembers me, tCastNum
  if integerp(tCastNum) then
    tFirstCast = tCastNum
    tLastCast = tCastNum
  else
    pAllMemNumList = [:]
    pAllMemNumList.sort()
    tFirstCast = 1
    tLastCast = the number of castLibs
  end if
  tNameAlertFlag = getIntVariable("duplicate.name.alert")
  repeat with tCastLib = tFirstCast to tLastCast
    tMemberAmount = the number of castMembers of castLib tCastLib
    repeat with i = 1 to tMemberAmount
      tMember = member(i, tCastLib)
      if length(tMember.name) > 0 then
        if tNameAlertFlag then
          if not voidp(pAllMemNumList[tMember.name]) and pLegalDuplicates.getPos(tMember.name) = 0 then
            if pAllMemNumList[tMember.name] <> tMember.number then
              tMemA = member(pAllMemNumList[tMember.name])
              tMemB = tMember
              if tMemA.name <> EMPTY and tMemB.name <> EMPTY then
                tLibA = castLib(tMemA.castLibNum).name
                tLibB = castLib(tMemB.castLibNum).name
                error(me, "Duplicate member names:" && tMember.name && "/" && tLibA && "/" && tLibB, #preIndexMembers)
              else
              end if
            end if
          end if
        end if
        pAllMemNumList[tMember.name] = tMember.number
      end if
    end repeat
    if member("variable.index", tCastLib).number > 0 then
      dumpVariableField(member("variable.index", tCastLib).number)
    end if
    if member("memberalias.index", tCastLib).number > 0 then
      tAliasList = field("memberalias.index", tCastLib)
      repeat with i = 1 to tAliasList.line.count
        tLine = tAliasList.line[i]
        if tLine.length > 2 then
          tName = tLine.char[offset("=", tLine) + 1..length(tLine)]
          if the last char in tName = "*" then
            tName = tName.char[1..length(tName) - 1]
            tNumber = pAllMemNumList[tName]
            if tNumber > 0 then
              tReplacingNum = -tNumber
            else
              tReplacingNum = tNumber
            end if
          else
            tNumber = pAllMemNumList[tName]
            tReplacingNum = tNumber
          end if
          if tNumber > 0 then
            tMemName = tLine.char[1..offset("=", tLine) - 1]
            pAllMemNumList[tMemName] = tReplacingNum
          end if
        end if
      end repeat
    end if
  end repeat
  return 1
end

on unregisterMembers me, tCastNum
  if voidp(tCastNum) then
    return me.clearMemNumLists()
  end if
  tMemberAmount = the number of castMembers of castLib tCastNum
  repeat with i = 1 to tMemberAmount
    tMember = member(i, tCastNum)
    tTempNum = pAllMemNumList[tMember.name]
    if tTempNum <> VOID then
      if tTempNum = tMember.number then
        pAllMemNumList.deleteProp(tMember.name)
      end if
    end if
    if pDynMemNumList.getPos(tMember.name) > 0 then
      pDynMemNumList.deleteAt(pDynMemNumList.getPos(tMember.name))
    end if
  end repeat
  if member("memberalias.index", tCastNum).number > 0 then
    tAliasList = field("memberalias.index", tCastNum)
    repeat with i = 1 to the number of lines in tAliasList
      tLine = tAliasList.line[i]
      if tLine.length > 2 then
        tName = tLine.char[offset("=", tLine) + 1..length(tLine)]
        if the last char in tName = "*" then
          tName = tName.char[1..length(tName) - 1]
        end if
        if not voidp(pAllMemNumList[tName]) then
          tMemName = tLine.char[1..offset("=", tLine) - 1]
          if not voidp(tMemName) then
            pAllMemNumList.deleteProp(tMemName)
          end if
        end if
      end if
    end repeat
  end if
  return 1
end

on exists me, tMemName
  return not voidp(pAllMemNumList[tMemName])
end

on getmemnum me, tMemName
  tMemNum = pAllMemNumList[tMemName]
  if voidp(tMemNum) then
    tMemNum = 0
  end if
  return tMemNum
end

on print me
  repeat with i = 1 to pAllMemNumList.count
    put pAllMemNumList.getPropAt(i) && "--" && pAllMemNumList[i]
  end repeat
  return 1
end

on clearMemNumLists me
  pAllMemNumList = [:]
  pAllMemNumList.sort()
  return 1
end

on emptyDynamicBin me
  tMemberAmount = the number of castMembers of castLib pBin
  repeat with i = 1 to tMemberAmount
    tMember = member(i, pBin)
    if tMember.type <> #empty then
      tMember.erase()
    end if
  end repeat
  pDynMemNumList = []
  pBmpMemNumList = []
  return 1
end

on deleteDynamicMembers me
  repeat with i = 1 to pDynMemNumList.count
    member(pDynMemNumList[i]).erase()
  end repeat
  repeat with i = 1 to pBmpMemNumList.count
    member(pBmpMemNumList[i]).erase()
  end repeat
  pDynMemNumList = []
  pBmpMemNumList = []
  return 1
end
