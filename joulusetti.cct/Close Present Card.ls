global gPresentCard

on mouseDown me
  if objectp(gPresentCard) then
    close(gPresentCard)
  end if
end
