property ancestor, spr, locX, locY, locHeight, isOpen, chosenType, circleButtonSpr, crossButtonSpr, destImage, origImage, bothTypeChosen
global gpInteractiveItems, gGameContext, gTicTacToe, gpObjects, gMyName

on new me, towner, tlocation, tid, tdata
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "TicTacToe"
  gTicTacToe = me
  return me
end

on itemDie me, itemId
  if itemId = me.id then
    close(me)
    if spr > 0 then
      sprMan_releaseSprite(spr)
    end if
  end if
end

on selectTicType me, tictype
  chosenType = tictype
  sendItemMessage(me, "CHOOSETYPE" && chosenType)
end

on Initialize me
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(item 1 of the location of me)
  me.locY = integer(item 2 of the location of me)
  me.locHeight = integer(item 3 of the location of me)
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("TicTacToe_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc[1], screenLoc[2])
  sprite(spr).locZ = screenLoc[3]
end

on boardMouseDown me, x, y
  sendItemMessage(me, "SETSECTOR" && chosenType && x && y)
  setSector(me, x, y, chosenType)
end

on mouseDown me
  if the doubleClick then
    open(me)
  else
    select(me)
  end if
end

on setupBoard me, data
  if isOpen = 0 then
    isOpen = 1
  end if
  origImage = member("TicTacToe.board.real.plain").image
  destImage = member(getmemnum("TicTacToe.board.real")).image
  origMemImage = member("TicTacToe.board.real.plain").image
  destImage.copyPixels(origMemImage, member("TicTacToe.board.real.plain").image.rect, member("TicTacToe.board.real").rect)
  w = 25
  setOpponents(me, line 1 to 2 of data)
  data = line 3 to the number of lines in data of data
  repeat with i = 1 to data.length
    c = char i of data
    if c <> " " then
      setSector(me, i mod w - 1, i / w, c)
    end if
  end repeat
  if bothTypeChosen = 1 and gGameContext.frame <> "game" then
    displayFrame(gGameContext, "game")
  end if
end

on setOpponents me, data
  member("opponent.x").text = word 2 of line 1 of data
  member("opponent.o").text = word 2 of line 2 of data
  member("tictactoe.game_players").text = data
  if (line 1 of data).length > 3 and (line 2 of data).length > 3 then
    bothTypeChosen = 1
  else
    bothTypeChosen = 0
  end if
end

on close me
  if isOpen then
    isOpen = 0
    sendItemMessage(me, "CLOSE")
    close(gGameContext)
  end if
end

on open me, content
  sendItemMessage(me, "OPEN")
  if not voidp(gGameContext) then
    close(gGameContext)
  end if
  myUserLoc = sprite(getaProp(gpObjects, gMyName)).loc
  if myUserLoc[1] > 400 then
    p = point(40, 70)
  else
    p = point(400, 70)
  end if
  gGameContext = new(script("PopUp Context Class"), 2000000000, 30, 99, p)
end

on setSector me, x, y, c
  sectorWidth = 10
  memberImage = member("TicTacToe." & c).image
  destRect = rect(6 + x * sectorWidth - 1, 6 + y * sectorWidth - 1, 6 + (x + 1) * sectorWidth - 1, 6 + (y + 1) * sectorWidth - 1)
  destImage.copyPixels(memberImage, destRect, member("TicTacToe." & c).rect, [#ink: 36])
end

on processItemMessage me, content
  ln1 = line 2 of content
  if ln1 contains "BOARDDATA" then
    setupBoard(me, line 3 to the number of lines in content of content)
    if gGameContext.frame = VOID then
      displayFrame(gGameContext, "chooseparty")
      if bothTypeChosen then
        displayFrame(gGameContext, "game")
      end if
    end if
  else
    if ln1 contains "SELECTTYPE" then
      chosenType = word 2 of line 2 of content
      put "CHOSENTYPE", chosenType
      displayFrame(gGameContext, "game")
    else
      if ln1 contains "OPPONENTS" then
        setOpponents(me, line 3 to 4 of content)
      else
        if ln1 contains "TYPERESERVED" then
          beep(1)
        end if
      end if
    end if
  end if
end
