property pObjects, pCollision, pSquareRoot, pObjectTypeIndex

on construct me
  pGeometry = createObject(#temp, getClassVariable("gamesystem.geometry.class"))
  if not objectp(pGeometry) then
    return error(me, "Cannot create pGeometry.", #construct)
  end if
  pSquareRoot = createObject(#temp, getClassVariable("gamesystem.squareroot.class"))
  if not objectp(pSquareRoot) then
    return error(me, "Cannot create pSquareRoot.", #construct)
  end if
  pCollision = createObject(#temp, getClassVariable("gamesystem.collision.class"))
  if not objectp(pCollision) then
    return error(me, "Cannot create pCollision.", #construct)
  end if
  pCollision.setaProp(#pSquareRoot, pSquareRoot)
  pObjects = [:]
  pObjectTypeIndex = [:]
  initIntVector()
  receiveUpdate(me.getID())
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  repeat while pObjects.count > 0
    me.removeGameObject(pObjects[1].getObjectId())
  end repeat
  pCollision = VOID
  pSquareRoot = VOID
  pObjects = VOID
  pObjectTypeIndex = VOID
  return 1
end

on defineClient me, tid
  return 1
end

on getCollision me
  return pCollision
end

on update me
  call(#update, pObjects)
end

on executeGameObjectEvent me, tid, tEvent, tdata
  tGameObject = me.getGameObject(tid)
  if tGameObject = 0 then
    return error(me, "Cannot execute game object event:" && tEvent && "on:" && tid, #executeGameObjectEvent)
  end if
  call(#executeGameObjectEvent, tGameObject, tEvent, tdata)
  return 1
end

on calculateChecksum me, tSeed
  tCheckSum = tSeed
  repeat with tObject in pObjects
    tCheckSum = tCheckSum + tObject.addChecksum()
  end repeat
  return tCheckSum
end

on dumpChecksumValues me
  tText = EMPTY
  repeat with tObject in pObjects
    tText = tText & tObject.dump() & RETURN
  end repeat
  put tText
end

on createGameObject me, tObjectId, ttype, tdata
  if not listp(tdata) then
    tdata = [:]
  end if
  tObjectId = integer(tObjectId)
  tObjectStrId = string(tObjectId)
  if pObjectTypeIndex.getaProp(tObjectId) <> VOID then
    return error(me, "Game object by id already exists! Id:" && tObjectId, #createGameObject)
  end if
  tClass = getClassVariable(me.getSystemId() & "." & ttype & ".class")
  tBaseClass = getClassVariable("gamesystem.gameobject.class")
  if tClass = 0 then
    tClass = tBaseClass
  else
    if listp(tClass) then
      tClass.addAt(1, tBaseClass)
    else
      tClass = [tBaseClass, tClass]
    end if
  end if
  tObject = createObject(#temp, tClass)
  if tObject = 0 then
    return error(me, "Unable to create game object!", #createGameObject)
  end if
  tObject.setID(tObjectStrId)
  tObject.setObjectId(tObjectStrId)
  tObject.setGameSystemReference(me.getFacade())
  pObjects.setaProp(tObjectId, tObject)
  pObjects.sort()
  pObjectTypeIndex.setaProp(tObjectId, ttype)
  if tdata[#z] = VOID then
    tZ = 0
  else
    tZ = tdata[#z]
  end if
  tObject.pGameObjectLocation = me.getWorld().initLocation()
  tObject.pGameObjectNextTarget = me.getWorld().initLocation()
  tObject.pGameObjectFinalTarget = me.getWorld().initLocation()
  me.updateGameObject(tObjectStrId, tdata.duplicate())
  return tObject
end

on updateGameObject me, tObjectId, tdata
  tObjectId = string(tObjectId)
  tObject = me.getGameObject(tObjectId)
  if not listp(tdata) then
    return 0
  end if
  if tObject = 0 then
    return error(me, "Game object not found:" && tObjectId, #updateGameObject)
  end if
  tObject.setGameObjectSyncProperty(tdata)
  if tdata[#z] = VOID then
    tdata[#z] = 0
  end if
  if tdata.findPos(#x) > 0 and tdata.findPos(#y) > 0 then
    tObject.setLocation(tdata.x, tdata.y, tdata.z)
  end if
  return 1
end

on removeGameObject me, tObjectId
  tObjectId = integer(tObjectId)
  tObjectStrId = string(tObjectId)
  ttype = pObjectTypeIndex.getaProp(tObjectId)
  if ttype = VOID then
    return 1
  end if
  tObject = me.getGameObject(tObjectStrId)
  if objectp(tObject) then
    tObject.deconstruct()
  end if
  pObjects.deleteProp(tObjectId)
  pObjectTypeIndex.deleteProp(tObjectId)
  return 1
end

on executeSubturnMoves me, tSync, tSubturn
  tRemoveList = []
  repeat with i = 1 to pObjects.count
    tGameObject = pObjects[i]
    tGameObject.calculateFrameMovement()
    if tGameObject.getActive() = 0 then
      tRemoveList.add(tGameObject.getObjectId())
    end if
  end repeat
  repeat with tObjectId in tRemoveList
    me.removeGameObject(tObjectId)
  end repeat
  return 1
end

on getGameObject me, tObjectId
  if pObjects = VOID then
    return 0
  end if
  return pObjects.getaProp(integer(tObjectId))
end

on getGameObjectIdsOfType me, ttype
  tResult = []
  repeat with i = 1 to pObjectTypeIndex.count
    if pObjectTypeIndex[i] = ttype or ttype = #all then
      tResult.append(string(pObjectTypeIndex.getPropAt(i)))
    end if
  end repeat
  return tResult
end

on getGameObjectType me, tObjectId
  tObjectId = integer(tObjectId)
  return pObjectTypeIndex.getaProp(tObjectId)
end

on dump me
  tText = EMPTY
  repeat with tObject in pObjects
    tText = tText & tObject.dump() & RETURN
  end repeat
  return tText
end

on _SendAction me, tMsg
  if tMsg[2] = 4 then
    me.getMessageSender().sendGameEventMessage([#integer: 4])
  end if
  return 1
end
