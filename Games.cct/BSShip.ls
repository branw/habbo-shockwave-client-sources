property x1, y1, x2, y2, size, spr, direction
global gBattleShip, gBSBoardSprite

on new me, tsize
  size = integer(tsize)
  return me
end

on endSprite me
  sprMan_releaseSprite(spr)
end

on hide me
  sprite(spr).visible = 0
  put "hide", spr
end

on show me
  sprite(spr).visible = 1
  put "show", spr
end

on exitFrame me
  locate(me)
end

on isMySector me, x, y
  case direction of
    #vertical:
      if x = x1 and y >= y1 and y <= y2 then
        return 1
      end if
    #horizontal:
      if y = y1 and x >= x1 and x <= x2 then
        return 1
      end if
  end case
  return 0
end

on place me, dir, x, y
  direction = dir
  case dir of
    #vertical:
      x1 = x
      y1 = y
      x2 = x
      y2 = y + size - 1
    #horizontal:
      x1 = x
      y1 = y
      x2 = x1 + size - 1
      y2 = y
  end case
  sendItemMessage(gBattleShip, "PLACESHIP" && size && x1 && y1 && x2 && y2)
  put "PLACESHIP" && size && x1 && y1 && x2 && y2
  spr = sprite(sprMan_getPuppetSprite())
  put spr
  spr.locZ = sprite(gBSBoardSprite).locZ + 1
  spr.castNum = getmemnum("bs_ship_" & size & "_" & char 1 of string(dir))
  spr.ink = 36
  spr.blend = 80
  spr.scriptInstanceList = [me]
  nextShip(gBattleShip)
end

on locate me
  spr.locH = sprite(gBSBoardSprite).left + 6 + 19 * x1
  spr.locV = sprite(gBSBoardSprite).top + 4 + 19 * y1
end
