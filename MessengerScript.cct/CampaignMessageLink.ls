global gActiveMsg

on mouseUp me
  gActiveMsg.markAsClicked()
  gotoNetPage(gActiveMsg.link, "_new")
end
