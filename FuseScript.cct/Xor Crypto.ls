global gXC

on x_to s
  oHex = new(script(getmemnum("RC4")))
  if voidp(gXC) then
    gXC = abs(random(254))
  end if
  tCrypted = EMPTY
  repeat with i = 1 to s.length
    tCrypted = tCrypted & oHex.int2hex(bitXor(charToNum(s.char[i]), gXC))
  end repeat
  return tCrypted
end

on x_from s
  oHex = new(script(getmemnum("RC4")))
  tUnCrypted = EMPTY
  repeat with i = 1 to s.length / 2
    tUnCrypted = tUnCrypted & numToChar(bitXor(oHex.hex2int(s.char[i * 2 - 1..i * 2]), gXC))
  end repeat
  return tUnCrypted
end

on x_test
  sorig = "sd=001/255,255,255&hr=006/148,223,255&hd=002/146,99,56&ey=002/0&fc=001/146,99,56&bd=001/146,99,56&lh=001/146,99,56&rh=001/146,99,56&ch=006/186,199,255&ls=001/186,199,255&rs=001/186,199,255&lg=004/193,210,219&sh=003/175,220,223"
  repeat with i = 0 to 254
    gXC = i
    sX = x_to(sorig)
    sY = x_from(sX)
    if sorig <> sY then
      put "MISMATCH WITH", gXC, sY
      next repeat
    end if
    put gXC, "ok"
  end repeat
end
