property itemType, spr, postItClassName
global gpopUpAdder, gpPostItNos, gPostitCounter

on new me, ttype, stripItemId, tPostItCount, tPostItClassName
  if tPostItClassName = VOID then
    postItClassName = "post.it"
  else
    postItClassName = tPostItClassName
  end if
  put "gPostitCounter:" && gPostitCounter
  if gPostitCounter < 40 then
    spr = sprMan_getPuppetSprite()
    sprite(spr).castNum = getmemnum("leftwall " & postItClassName)
    o = new(script("PostItAdder Class"), spr, stripItemId, tPostItCount, postItClassName)
    add(sprite(spr).scriptInstanceList, o)
    setProp(o, #spriteNum, spr)
    beginSprite(o)
    put o
    return o
  else
    helpText_setText(AddTextToField("NoMorePostits"))
  end if
end
