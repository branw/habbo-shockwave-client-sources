property pActive, pSync, pChanges, pSmokelist, pSmokeLocs, pInitializeSprites, pPause, pAnimFrame

on construct me
  me.pSmokelist = []
  me.pSmokeLocs = []
  me.pInitializeSprites = 0
  return callAncestor(#deconstruct, [me])
end

on deconstruct me
  repeat with i = 1 to me.pSmokelist.count
    releaseSprite(me.pSmokelist[i].spriteNum)
  end repeat
  return callAncestor(#deconstruct, [me])
end

on prepareForMove me
  if pActive = 1 then
    return 1
  end if
  repeat with i = 1 to me.pSmokelist.count
    releaseSprite(me.pSmokelist[i].spriteNum)
  end repeat
  me.pSmokelist = []
  me.pChanges = 0
  return 1
end

on prepare me, tdata
  if tdata[#stuffdata] = "ON" then
    me.setOn()
  else
    me.setOff()
    me.pChanges = 0
  end if
  if me.pSprList.count > 1 then
    removeEventBroker(me.pSprList[2].spriteNum)
  end if
  me.pAnimFrame = 1
  me.pSync = 1
  if me.pSmokelist.count >= 2 then
    me.pInitializeSprites = 1
  end if
  return 1
end

on createSmokeSprites me, tNumOf
  if me.pSprList.count < 5 then
    return 0
  end if
  repeat with i = 1 to tNumOf
    me.pSmokelist.add(sprite(reserveSprite(me.getID())))
  end repeat
  return me.initializeSmokeSprites()
end

on initializeSmokeSprites me
  if me.pSprList.count < 5 then
    return 0
  end if
  tStartLoc = me.pSprList[4].loc + point(28, -60)
  tSmokeBig = me.pSmokelist[1]
  tSmokeBig.loc = tStartLoc
  tSmokeBig.ink = 8
  tSmokeBig.blend = 100
  me.changeMember(tSmokeBig, "scifirocket_sm_tiny")
  pSmokeLocs[1] = tSmokeBig.loc
  tSmokeBig.visible = 0
  tSmokeBig.locZ = me.pSprList[4].locZ + 2
  repeat with i = 2 to me.pSmokelist.count
    tSp = me.pSmokelist[i]
    tSp.loc = tStartLoc + point(-3, -21) + point(random(6), random(4))
    tSp.ink = 8
    tSp.locZ = me.pSprList[4].locZ + 1
    tSp.blend = 100
    tSp.visible = 0
    me.pSmokeLocs[i] = tSp.loc
    if random(3) = 1 then
      me.changeMember(tSp, "scifirocket_sm_tiny")
      next repeat
    end if
    me.changeMember(tSp, "scifirocket_sm_small")
  end repeat
  me.pInitializeSprites = 0
  return 1
end

on animateSmallSmokes me, tVal
  case tVal of
    "move":
      repeat with i = 2 to me.pSmokelist.count
        case i of
          2:
            if random(2) = 2 then
              me.pSmokeLocs[i][2] = me.pSmokeLocs[i][2] - 0.59999999999999998
            end if
          3:
            me.pSmokeLocs[i][1] = me.pSmokeLocs[i][1] + 0.59999999999999998 - random(6) / 12.0
          4:
            me.pSmokeLocs[i][1] = me.pSmokeLocs[i][1] - random(6) / 12.0
          5:
            me.pSmokeLocs[i][1] = me.pSmokeLocs[i][1] + 1.0 - random(6) / 12.0
            me.pSmokeLocs[i][2] = me.pSmokeLocs[i][2] + random(10) / 12.0
          6:
            me.pSmokeLocs[i][1] = me.pSmokeLocs[i][1] - 0.5 - random(6) / 12.0
            me.pSmokeLocs[i][2] = me.pSmokeLocs[i][2] + random(10) / 12.0
        end case
        me.pSmokeLocs[i][2] = me.pSmokeLocs[i][2] - 0.69999999999999996 + random(6) / 11.0
        me.pSmokeLocs[i][1] = me.pSmokeLocs[i][1] + sin(the timer)
        me.pSmokelist[i].visible = 1
        me.pSmokelist[i].loc = me.pSmokeLocs[i]
      end repeat
    "make_smaller":
      repeat with i = 2 to me.pSmokelist.count
        if random(5) = 2 then
          me.changeMember(me.pSmokelist[i], "scifirocket_sm_tiny")
        end if
      end repeat
    "blend":
      repeat with i = 2 to me.pSmokelist.count
        me.pSmokelist[i].blend = me.pSmokelist[i].blend - 15
      end repeat
  end case
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
  if me.pSprList.count < 5 then
    return 0
  end if
  tlight = me.pSprList[2]
  if me.pActive then
    tlight.blend = 100
  else
    tlight.blend = 0
  end if
  if pSync < 3 then
    me.pSync = me.pSync + 1
    return 0
  else
    me.pSync = 1
  end if
  if not me.pChanges then
    return 0
  end if
  if me.pSmokelist = [] then
    me.createSmokeSprites(4)
  end if
  if me.pInitializeSprites then
    me.initializeSmokeSprites()
  end if
  if me.pAnimFrame = 1 then
    if random(8) <> 2 then
      return 1
    end if
  end if
  tSmokeBig = me.pSmokelist[1]
  if me.pAnimFrame <= 23 then
    if me.pAnimFrame = 4 then
      me.changeMember(tSmokeBig, "scifirocket_sm_small")
    end if
    if me.pAnimFrame = 9 then
      me.changeMember(tSmokeBig, "scifirocket_sm_med")
    end if
    if me.pAnimFrame = 14 then
      me.changeMember(tSmokeBig, "scifirocket_sm_big")
    end if
    me.pSmokeLocs[1][2] = me.pSmokeLocs[1][2] - 0.90000000000000002
    tSmokeBig.visible = 1
    tSmokeBig.loc = me.pSmokeLocs[1]
  else
    tSmokeBig.blend = tSmokeBig.blend - 20
    if me.pAnimFrame > 52 then
      me.animateSmallSmokes("make_smaller")
    end if
    if me.pAnimFrame > 60 then
      me.animateSmallSmokes("blend")
    end if
    if tSmokeBig.blend < 20 then
      tSmokeBig.visible = 0
    end if
    me.animateSmallSmokes("move")
  end if
  me.pAnimFrame = me.pAnimFrame + 1
  if me.pAnimFrame > 66 then
    me.initializeSmokeSprites()
    me.pAnimFrame = 1
    if me.pActive = 0 then
      me.pChanges = 0
    end if
  end if
end

on changeMember me, tSpr, tMemName
  tMem = getMember(tMemName)
  if tMem = VOID then
    return 0
  end if
  tSpr.member = tMem
  tSpr.width = tMem.width
  tSpr.height = tMem.height
  return 1
end

on setOn me
  me.pChanges = 1
  me.pActive = 1
end

on setOff me
  me.pChanges = 1
  me.pActive = 0
  me.pInitializeSprites = 0
end

on select me
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
  end if
  return 1
end
