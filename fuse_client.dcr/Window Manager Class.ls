property ancestor, pLockLocZ, pDefLocX, pDefLocY, pClsList

on new me
  return me
end

on construct me
  pLockLocZ = 0
  pDefLocX = getIntVariable("window.default.locx", 100)
  pDefLocY = getIntVariable("window.default.locy", 100)
  me.pItemList = []
  me.pHideList = []
  me.setProperty(#defaultLocZ, getIntVariable("window.default.locz", 0))
  me.pBoundary = rect(0, 0, (the stage).rect.width, (the stage).rect.height) + getVariableValue("window.boundary.limit")
  me.pInstanceClass = getClassVariable("window.instance.class")
  pClsList = [:]
  pClsList[#wrapper] = getClassVariable("window.wrapper.class")
  pClsList[#unique] = getClassVariable("window.unique.class")
  pClsList[#grouped] = getClassVariable("window.grouped.class")
  if not memberExists("null") then
    tNull = member(createMember("null", #bitmap))
    tNull.image = image(1, 1, 8)
    tNull.image.setPixel(0, 0, rgb(0, 0, 0))
  end if
  return 1
end

on create me, tid, tLayout, tLocX, tLocY, tSpecial
  if tSpecial = #modal then
    return me.modal(tid, tLayout, tLocX, tLocY, tSpecial)
  end if
  if voidp(tLayout) then
    tLayout = "empty.window"
  end if
  if me.exists(tid) then
    if voidp(tLocX) then
      tLocX = me.get(tid).getProperty(#locX)
    end if
    if voidp(tLocY) then
      tLocY = me.get(tid).getProperty(#locY)
    end if
    me.remove(tid)
  end if
  if integerp(tLocX) and integerp(tLocY) then
    tX = tLocX
    tY = tLocY
  else
    if not voidp(me.pPosCache[tid]) then
      tX = me.pPosCache[tid][1]
      tY = me.pPosCache[tid][2]
    else
      tX = pDefLocX
      tY = pDefLocY
    end if
  end if
  tItem = getObjectManager().create(tid, me.pInstanceClass)
  if not tItem then
    return error(me, "Failed to create window object:" && tid, #create)
  end if
  tProps = [:]
  tProps[#locX] = tX
  tProps[#locY] = tY
  tProps[#locZ] = me.pAvailableLocZ
  tProps[#boundary] = me.pBoundary
  tProps[#elements] = pClsList
  tProps[#manager] = me
  if not tItem.define(tProps) then
    getObjectManager().remove(tid)
    return 0
  end if
  me.pItemList.add(tid)
  tItem.merge(tLayout)
  pAvailableLocZ = pAvailableLocZ + tItem.getProperty(#sprCount)
  me.Activate()
  return 1
end

on Activate me, tid
  if pLockLocZ then
    return 0
  end if
  if me.pItemList.count = 0 then
    return 0
  end if
  if voidp(tid) then
    tid = me.pItemList.getLast()
  else
    if not me.exists(tid) then
      return 0
    end if
  end if
  me.pItemList.deleteOne(tid)
  me.pItemList.append(tid)
  tInstance = VOID
  me.pAvailableLocZ = me.pDefaultLocZ
  repeat with i = 1 to me.pItemList.count
    tCurrID = me.pItemList[i]
    if tCurrID = tid then
      tInstance = me.get(tCurrID)
      next repeat
    end if
    tItem = me.get(tCurrID)
    tItem.setDeactive()
    repeat with tSpr in tItem.getProperty(#spriteList)
      tSpr.locZ = me.pAvailableLocZ
      me.pAvailableLocZ = me.pAvailableLocZ + 1
    end repeat
  end repeat
  if not objectp(tInstance) then
    return 0
  end if
  repeat with tSpr in tInstance.getProperty(#spriteList)
    tSpr.locZ = me.pAvailableLocZ
    me.pAvailableLocZ = me.pAvailableLocZ + 1
  end repeat
  me.pActiveItem = tid
  return tInstance.setActive()
end

on deactivate me, tid
  if me.exists(tid) then
    me.pItemList.deleteOne(tid)
    me.pItemList.addAt(1, tid)
    me.Activate()
    return 1
  end if
  return 0
end

on lock me
  pLockLocZ = 1
  return 1
end

on unlock me
  pLockLocZ = 0
  return 1
end

on modal me, tid, tLayout, tLocX, tLocY, tSpecial
  if not me.create(tid, "modal.window", 0, 0) then
    return 0
  end if
  tWnd = me.get(tid)
  tWnd.merge(tLayout)
  tW = tWnd.getProperty(#width)
  tH = tWnd.getProperty(#height)
  tX = (the stage).rect.width / 2 - tW / 2
  tY = (the stage).rect.height / 2 - tH / 2
  tWnd.moveTo(tX, tY)
  tWnd.getElement("modal").moveTo(0, 0)
  tWnd.getElement("modal").resizeTo((the stage).rect.width, (the stage).rect.height)
  tWnd.moveZ(20000000 - tWnd.getProperty(#sprCount))
  tWnd.lock()
  return 1
end
