property pItemList

on new me
  return me
end

on construct me
  pItemList = []
  pItemList.sort()
  return 1
end

on deconstruct me
  tObjMngr = getObjectManager()
  repeat with i = 1 to pItemList.count
    if tObjMngr.exists(pItemList[i]) then
      tObjMngr.remove(pItemList[i])
    end if
  end repeat
  pItemList = []
  return 1
end

on create me, tid, tClass
  if getObjectManager().exists(tid) then
    return error(me, "Object already exists:" && tid, #create)
  end if
  if not createObject(tid, tClass) then
    return 0
  end if
  pItemList.add(tid)
  return 1
end

on get me, tid
  return getObjectManager().get(tid)
end

on remove me, tid
  if not me.exists(tid) then
    return 0
  end if
  pItemList.deleteOne(tid)
  return getObjectManager().remove(tid)
end

on exists me, tid
  return me.pItemList.getOne(tid) > 0
end

on print me
  tListMode = ilk(me.pItemList)
  repeat with i = 1 to me.pItemList.count
    if tListMode = #list then
      tid = me.pItemList[i]
    else
      tid = me.pItemList.getPropAt(i)
    end if
    tObj = me.get(tid)
    if symbolp(tid) then
      tid = "#" & tid
    end if
    put tid && ":" && tObj
  end repeat
  return 1
end
