global gPresentCard, gPresentStuffId

on mouseDown me
  xmasEve = date("20011224")
  sendFuseMsg("PRESENTOPEN /" & gPresentStuffId)
end
