property pActive, pAskedFriends
global gpUiButtons, gChosenUser, gBuddyList, gPopUpContext

on beginSprite me
  if not listp(gpUiButtons) then
    gpUiButtons = [:]
  end if
  setaProp(gpUiButtons, "ask_friend", me.spriteNum)
  pAskedFriends = []
  disable(me)
end

on enable me
  sprite(me.spriteNum).visible = 1
  if gBuddyList.getIsBuddy(gChosenUser) or getPos(pAskedFriends, gChosenUser) > 0 then
    sprite(me.spriteNum).blend = 30
    pActive = 0
  else
    sprite(me.spriteNum).blend = 100
    pActive = 1
  end if
  sprite(me.spriteNum).locZ = 1000
end

on disable me
  sprite(me.spriteNum).visible = 0
end

on mouseUp me
  if pActive and stringp(gChosenUser) then
    sprite(me.spriteNum).blend = 30
    pActive = 0
    add(pAskedFriends, gChosenUser)
    if voidp(gPopUpContext) then
      openMessenger()
    end if
    s = member(getmemnum("messenger.ask_to_buddy_confirmation")).text
    put gChosenUser into line 1 of s
    member(getmemnum("messenger.ask_to_buddy_confirmation")).text = s
    goContext("asktobuddy")
    sendEPFuseMsg("MESSENGER_REQUESTBUDDY" && gChosenUser & RETURN & "request buddy.message")
  end if
end

on mouseDown me
  put "huuhaa"
end

on mouseWithin me
  if the mouseDown and word 2 of the name of the member of sprite(the spriteNum of me) = "active" then
    if word 2 of the name of the member of sprite(the spriteNum of me) = "active" then
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "hi")
    end if
  end if
end

on mouseLeave me
  if word 2 of the name of the member of sprite(the spriteNum of me) = "hi" then
    sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "active")
  end if
end
