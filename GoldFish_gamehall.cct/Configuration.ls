global gXFactor, gYFactor, gHFactor, gWorldType, xoffset, yoffset

on checkOffsets
  gXFactor = 32.0
  gYFactor = 16.0
  gHFactor = 16.0
  xoffset = 386
  yoffset = 186
  if gWorldType = "hallA" or gWorldType = "hallD" then
    xoffset = 360
    yoffset = 179
  else
    if gWorldType = "hallB" then
      xoffset = 366
      yoffset = 132
    else
      if gWorldType = "hallC" then
        xoffset = 359
        yoffset = 163
      else
        if gWorldType = "entryhall" then
          xoffset = 344
          yoffset = 154
        end if
      end if
    end if
  end if
end
