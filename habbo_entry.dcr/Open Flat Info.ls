property num

on mouseDown me
  ml = (the mouseV + sprite(me.spriteNum).member.scrollTop - sprite(me.spriteNum).top) / 12 + 1
  openFlatInfo(ml)
end
