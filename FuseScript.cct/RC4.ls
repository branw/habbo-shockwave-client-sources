property sbox, key, i, j

on new me
  return me
end

on setKey me, myKey
  put "New key assigned to RC4:" && myKey
  myKey = string(myKey)
  sbox = []
  key = []
  repeat with i = 0 to 255
    key[i + 1] = charToNum(char i mod length(myKey) + 1 of myKey)
    sbox[i + 1] = i
  end repeat
  j = 0
  repeat with i = 0 to 255
    j = (j + sbox[i + 1] + key[i + 1]) mod 256
    k = sbox[i + 1]
    sbox[i + 1] = sbox[j + 1]
    sbox[j + 1] = k
  end repeat
  i = 0
  j = 0
end

on encipher me, data
  cipher = EMPTY
  repeat with a = 1 to length(data)
    i = (i + 1) mod 256
    j = (j + sbox[i + 1]) mod 256
    temp = sbox[i + 1]
    sbox[i + 1] = sbox[j + 1]
    sbox[j + 1] = temp
    d = sbox[(sbox[i + 1] + sbox[j + 1]) mod 256 + 1]
    cipher = cipher & me.int2hex(bitXor(charToNum(char a of data), d))
  end repeat
  return cipher
end

on decipher me, data
  cipher = EMPTY
  repeat with a = 1 to length(data)
    i = (i + 1) mod 256
    put "i:" && i
    j = (j + sbox[i + 1]) mod 256
    put "j:" && j
    temp = sbox[i + 1]
    sbox[i + 1] = sbox[j + 1]
    sbox[j + 1] = temp
    d = sbox[(sbox[i + 1] + sbox[j + 1]) mod 256 + 1]
    put "d:" && d
    t = me.hex2int(char a to a + 1 of data)
    put "t:" && t
    cipher = cipher & numToChar(bitXor(t, d))
    a = a + 1
    put "-----"
  end repeat
  return cipher
end

on createKey me
  k = EMPTY
  the randomSeed = the milliSeconds
  repeat with i = 1 to 4
    k = k & me.int2hex(random(256) - 1)
  end repeat
  return abs(me.hex2int(k))
end

on int2hex me, aint
  digits = "0123456789ABCDEF"
  h = EMPTY
  if aint <= 0 then
    hexstr = "00"
  else
    repeat while aint > 0
      d = aint mod 16
      aint = aint / 16
      hexstr = char d + 1 of digits & hexstr
    end repeat
  end if
  if hexstr.length mod 2 = 1 then
    hexstr = "0" & hexstr
  end if
  return hexstr
end

on hex2int me, ahex
  digits = "0123456789ABCDEF"
  base = 1
  tot = 0
  repeat while length(ahex) > 0
    lc = the last char in ahex
    delete char -30000 of ahex
    vl = offset(lc, digits) - 1
    tot = tot + base * vl
    base = base * 16
  end repeat
  return tot
end
