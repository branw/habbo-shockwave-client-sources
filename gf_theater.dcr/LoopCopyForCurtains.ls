on exitFrame me
  global hiliter, hiliteStart, gChosenStuffSprite
  if the ticks - hiliteStart > 220 then
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
  end if
  if objectp(hiliter) then
    hiliteExitframe(hiliter)
  end if
  sprite(10).animateCurtains()
  if sprite(42).liteAnimationStatus = 1 then
    sprite(42).animateLite(sprite(42))
  end if
  if sprite(43).animationStatus > 0 then
    sprite(43).animate(sprite(43))
  end if
  if sprite(44).animationStatus > 0 then
    sprite(44).animate(sprite(44))
  end if
  go(the frame)
end

on mouseDown me
  global hiliter
  if objectp(hiliter) then
    mouseDown(hiliter)
  end if
end
