global gPresentStuffId

on setPresentPic me, mem
  sprite(me.spriteNum).member = mem
  sprite(me.spriteNum).width = mem.width
  sprite(me.spriteNum).height = mem.height
  sprite(me.spriteNum).ink = 8
end
