property spriteNum

on enterFrame me
  if rollover(me.spriteNum) then
    pointClicked = the mouseLoc
    currentMember = sprite(spriteNum).member
    wordNum = sprite(spriteNum).pointToWord(pointClicked)
    wordText = currentMember.word[wordNum]
    if wordText contains "http://" or wordText contains "palaute@kolumbus.fi" then
      iSpr = me.spriteNum
      set the cursor of sprite iSpr to [the number of member "cursor_finger", the number of member "cursor_finger_mask"]
      put "Rollover URL:" && wordText
    else
      iSpr = me.spriteNum
      set the cursor of sprite iSpr to 0
    end if
  end if
end

on mouseDown me
  pointClicked = the mouseLoc
  currentMember = sprite(spriteNum).member
  wordNum = sprite(spriteNum).pointToWord(pointClicked)
  wordText = currentMember.word[wordNum]
  if wordText contains "http://" or wordText contains "palaute@kolumbus.fi" then
    put "Clicked URL:" && wordText
    if wordText contains "http://" then
      gotoNetPage(wordText, "_new")
    else
      if wordText contains "palaute@kolumbus.fi" then
        gotoNetPage("mailto:palaute@kolumbus.fi")
      end if
    end if
  end if
end
