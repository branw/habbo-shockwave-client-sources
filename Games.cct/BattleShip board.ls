global gBattleShip, gBSBoardSprite

on beginSprite me
  gBSBoardSprite = me.spriteNum
  sprite(me.spriteNum).ink = 36
end

on mouseWithin me
  if objectp(gBattleShip) then
    boardX = integer((the mouseH - (sprite(me.spriteNum).left + 5)) / 19)
    boardY = integer((the mouseV - (sprite(me.spriteNum).top + 5)) / 19)
    x = sprite(me.spriteNum).left + 6 + 19 * boardX
    y = sprite(me.spriteNum).top + 4 + 19 * boardY
    if not onBoard(me, boardX, boardY) then
      boardEndRollover(gBattleShip)
    else
      boardRollover(gBattleShip, x, y)
    end if
  end if
end

on mouseLeave me
  if objectp(gBattleShip) then
    boardEndRollover(gBattleShip)
  end if
end

on mouseDown me
  boardX = integer((the mouseH - (sprite(me.spriteNum).left + 5)) / 19)
  boardY = integer((the mouseV - (sprite(me.spriteNum).top + 5)) / 19)
  if not onBoard(me, boardX, boardY) then
    return 
  else
    boardMouseDown(gBattleShip, boardX, boardY)
  end if
end

on onBoard me, x, y
  if x < 0 or y < 0 then
    return 0
  end if
  if objectp(gBattleShip.shipToPlace) then
    case gBattleShip.direction of
      #horizontal:
        if x + gBattleShip.shipToPlace.size >= 14 or y >= 12 then
          return 0
        else
          return 1
        end if
      #vertical:
        if y + gBattleShip.shipToPlace.size - 1 >= 12 or x >= 13 then
          return 0
        else
          return 1
        end if
    end case
  else
    return x <= 25 and y <= 23
  end if
end
