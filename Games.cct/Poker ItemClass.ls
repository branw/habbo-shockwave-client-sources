property ancestor, spr, locX, locY, locHeight, isOpen, chosenType, circleButtonSpr, crossButtonSpr, destImage, origImage, bothTypeChosen, cardNum, pCards, pOtherCards, lCardTypes, pPlayersCards, changed
global gpInteractiveItems, gGameContext, gPoker, gpObjects, gMyName

on new me, towner, tlocation, tid, tdata
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "Poker"
  gPoker = me
  changed = 0
  return me
end

on Initialize me
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(item 1 of the location of me)
  me.locY = integer(item 2 of the location of me)
  me.locHeight = integer(item 3 of the location of me)
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("Poker_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc[1], screenLoc[2])
  sprite(spr).locZ = screenLoc[3]
end

on mouseDown me
  if the doubleClick then
    open(me)
  else
    select(me)
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
  if not voidp(gGameContext) then
    close(gGameContext)
  end if
  myUserLoc = sprite(getaProp(gpObjects, gMyName)).loc
  if myUserLoc[1] > 400 then
    p = point(40, 70)
  else
    p = point(400, 70)
  end if
  isOpen = 1
  gGameContext = new(script("PopUp Context Class"), 2000000000, 30, 99, p)
  displayFrame(gGameContext, "card_intro")
end

on register me, oCard
  if voidp(pCards) then
    pCards = [:]
  end if
  setaProp(pCards, cardNum, oCard)
  setCard(oCard, getAt(lCardTypes, cardNum))
  cardNum = cardNum + 1
end

on registerOtherCard me, oCard
  if gGameContext.frame = "card_change" then
    setaProp(pOtherCards, oCard.playerNum && oCard.cardNum, oCard)
    sprite(oCard.spriteNum).visible = 0
  else
    l = getaProp(pPlayersCards, oCard.playerNum)
    if listp(l) then
      if count(l) >= 5 then
        setCard(oCard, l[6 - oCard.cardNum])
      else
        sprite(oCard.spriteNum).visible = 0
      end if
    else
      sprite(oCard.spriteNum).visible = 0
    end if
  end if
end

on startOver me
  sendItemMessage(me, "OPEN")
  sendItemMessage(me, "STARTOVER")
  changed = 0
end

on change me
  if changed then
    return 
  end if
  s = EMPTY
  repeat with i = 1 to count(pCards)
    o = pCards[i]
    if o.selected then
      s = s && i - 1
      sprite(o.spriteNum).member = getmemnum("BACKSIDE")
      select(o, 0)
    end if
  end repeat
  sendItemMessage(me, "CHANGE" && s)
  changed = 1
  member("cards.helptext").text = "Waiting for the other players"
end

on processItemMessage me, content
  ln1 = line 2 of content
  put content
  if ln1 contains "START" then
    pOtherCards = [:]
    member("cards.helptext").text = "Choose the cards to change"
  end if
  if ln1 contains "OPPONENTS" then
    if gGameContext.frame = "card_change" then
      j = 1
      repeat with i = 1 to 4
        if getmemnum("cards.names." & i) > 0 then
          member("cards.names." & i).text = EMPTY
          member("cards.ready." & i).text = EMPTY
        end if
      end repeat
      repeat with i = 1 to 4
        ln = line 2 + i of content
        if ln.length > 0 then
          if word 1 of ln <> gMyName then
            member("cards.names." & j).text = word 1 of ln
            if word 2 of ln = "0" then
              member("cards.ready." & j).text = "NOT READY"
            else
              member("cards.ready." & j).text = "DONE - changed" && word 2 of ln
            end if
            repeat with u = 1 to 5
              oCard = getaProp(pOtherCards, j && u)
              if not voidp(oCard) then
                sprite(oCard.spriteNum).visible = 1
              end if
            end repeat
            j = j + 1
          else
          end if
          next repeat
        end if
      end repeat
    end if
  end if
  if ln1 contains "CHANGED" then
    ln = line 3 of content
    the itemDelimiter = "/"
    player = item 1 of ln
    cardNos = item 2 of ln
    the itemDelimiter = ","
    repeat with j = 1 to 3
      if member("cards.names." & j).text = player then
        playerNo = j
      end if
    end repeat
    put playerNo, "pn"
    if not voidp(playerNo) then
      repeat with j = 1 to the number of words in cardNos
        oc = getaProp(pOtherCards, playerNo && 6 - integer(1 + word j of cardNos))
        if not voidp(oc) then
          select(oc, 1)
          next repeat
        end if
        put playerNo && 6 - integer(1 + word j of cardNos), "not found"
      end repeat
    end if
    member("cards.ready." & playerNo).text = "Done" && "- changed " && the number of words in cardNos
  end if
  if ln1 contains "REVEALCARDS" then
    pOtherCards = [:]
    j = 1
    pPlayersCards = [:]
    repeat with i = 3 to the number of lines in content
      the itemDelimiter = "/"
      ln = line i of content
      playerName = item 1 of ln
      if playerName = gMyName then
        num = 0
        fieldNum = 1
      else
        j = j + 1
        num = j - 1
        fieldNum = j
      end if
      member("cards.names." & fieldNum).text = playerName
      l = []
      repeat with e = 3 to the number of items in ln
        add(l, item e of ln)
      end repeat
      addProp(pPlayersCards, num, l)
      the itemDelimiter = ","
    end repeat
    displayFrame(gGameContext, "card_end")
  end if
  if ln1 contains "YOURCARDS" then
    cardNum = 1
    lCardTypes = []
    sCards = word 2 of ln1
    the itemDelimiter = "/"
    repeat with i = 3 to the number of items in sCards
      add(lCardTypes, item i of sCards)
      if not voidp(pCards) then
        if count(pCards) = 5 and i - 2 <= 5 then
          o = pCards[i - 2]
          if not voidp(o) then
            setCard(o, lCardTypes[i - 2])
          end if
        end if
      end if
    end repeat
    the itemDelimiter = ","
    if gGameContext.frame <> "card_change" then
      displayFrame(gGameContext, "card_change")
    end if
  end if
end
