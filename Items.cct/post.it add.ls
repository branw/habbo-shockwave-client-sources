global gpopUpAdder

on mouseUp
  createPostIt(gpopUpAdder)
  the keyboardFocusSprite = 0
  popupClose(gpopUpAdder.postItClassName && "add")
end
