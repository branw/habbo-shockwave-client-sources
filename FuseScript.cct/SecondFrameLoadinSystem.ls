on exitFrame
  put the runMode
  moveToFront(the stage)
  member("item.info_name").text = EMPTY
  member("item.info_text").text = EMPTY
  if the runMode = "Author" then
    tellStreamStatus(0)
    the alertHook = 0
    go(the frame + 1)
  end if
end
