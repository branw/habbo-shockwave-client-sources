on mouseDown
  global gMyName, gChosenUser, gBadgeOn, gMeModerator, hiliter, gMyModLevel
  if gMyName = gChosenUser and gMeModerator then
    if gBadgeOn = 1 then
      sendFuseMsg("HIDEBADGE")
      gBadgeOn = 0
      sprite(726).blend = 50
    else
      sendFuseMsg("SHOWBADGE")
      gBadgeOn = 1
      sprite(726).blend = 100
    end if
  end if
end
