property ancestor, pInstanceClass, pActiveItem, pDefaultLocZ, pAvailableLocZ, pPosCache, pHideList, pBoundary

on new me
  return me
end

on construct me
  pInstanceClass = getClassVariable("visualizer.instance.class")
  pActiveItem = EMPTY
  pPosCache = [:]
  pHideList = []
  pDefaultLocZ = getIntVariable("visualizer.default.locz", -20000000)
  pAvailableLocZ = pDefaultLocZ
  pBoundary = rect(0, 0, (the stage).rect.width, (the stage).rect.height) + getVariableValue("visualizer.boundary.limit")
  return 1
end

on create me, tid, tLayout, tLocX, tLocY
  if not integerp(tLocX) then
    tLocX = 0
  end if
  if not integerp(tLocY) then
    tLocY = 0
  end if
  if me.exists(tid) then
    me.remove(tid)
  end if
  tItem = getObjectManager().create(tid, pInstanceClass)
  if not tItem then
    return error(me, "Item creation failed:" && tid, #create)
  end if
  tProps = [:]
  tProps[#locX] = tLocX
  tProps[#locY] = tLocY
  tProps[#locZ] = pAvailableLocZ
  tProps[#layout] = tLayout
  tProps[#boundary] = pBoundary
  if not tItem.define(tProps) then
    getObjectManager().remove(tid)
    return 0
  end if
  me.pItemList.add(tid)
  pAvailableLocZ = pAvailableLocZ + tItem.getProperty(#sprCount)
  return 1
end

on remove me, tid
  if not me.exists(tid) then
    return 0
  end if
  tItem = me.get(tid)
  pAvailableLocZ = pAvailableLocZ - tItem.getProperty(#sprCount)
  pPosCache[tid] = [tItem.getProperty(#locX), tItem.getProperty(#locY)]
  me.pItemList.deleteOne(tid)
  return getObjectManager().remove(tid)
end

on hideAll me
  repeat with tItem in me.pItemList
    tObj = me.get(tItem)
    if tObj.getProperty(#visible) then
      tObj.hide()
      pHideList.add(tItem)
    end if
  end repeat
  return 1
end

on showAll me
  repeat with tItem in pHideList
    tObj = me.get(tItem)
    if tObj <> 0 then
      tObj.show()
    end if
  end repeat
  pHideList = []
  return 1
end

on getProperty me, tProp
  case tProp of
    #defaultLocZ:
      return pDefaultLocZ
    #boundary:
      return pBoundary
    #count:
      return me.pItemList.count
  end case
  return 0
end

on setProperty me, tProp, tValue
  case tProp of
    #defaultLocZ:
      return me.setDefaultLocZ(tValue)
    #boundary:
      return me.setBoundary(tValue)
  end case
  return 0
end

on setDefaultLocZ me, tValue
  if not integerp(tValue) then
    return error(me, "integer expected:" && tValue, #setDefaultLocZ)
  end if
  pDefaultLocZ = tValue
  return Activate(me)
end

on setBoundary me, tValue
  if not listp(tValue) and not ilk(tValue, #rect) then
    return error(me, "List or rect expected:" && tValue, #setBoundary)
  end if
  pBoundary[1] = tValue[1]
  pBoundary[2] = tValue[2]
  pBoundary[3] = tValue[3]
  pBoundary[4] = tValue[4]
  call(#moveBy, me.pItemList, 0, 0)
  return 1
end
