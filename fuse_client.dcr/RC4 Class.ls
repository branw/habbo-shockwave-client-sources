property pSbox, pKey, i, j

on new me
  return me
end

on setKey me, tMyKey, tMode
  tMyKey = string(tMyKey)
  pSbox = []
  pKey = []
  case tMode of
    #old, VOID:
      repeat with i = 0 to 255
        pKey[i + 1] = charToNum(tMyKey.char[i mod length(tMyKey) + 1])
        pSbox[i + 1] = i
      end repeat
    #new:
      repeat with i = 0 to 255
        pKey[i + 1] = i
      end repeat
      repeat with i = 0 to 1019
        pKey[i mod 256 + 1] = (charToNum(tMyKey.char[i mod length(tMyKey) + 1]) + pKey[i mod 256 + 1]) mod 256
      end repeat
      repeat with i = 0 to 255
        pSbox[i + 1] = i
      end repeat
  end case
  j = 0
  repeat with i = 0 to 255
    j = (j + pSbox[i + 1] + pKey[i + 1]) mod 256
    k = pSbox[i + 1]
    pSbox[i + 1] = pSbox[j + 1]
    pSbox[j + 1] = k
  end repeat
  i = 0
  j = 0
end

on encipher me, tdata
  tCipher = EMPTY
  repeat with a = 1 to length(tdata)
    i = (i + 1) mod 256
    j = (j + pSbox[i + 1]) mod 256
    temp = pSbox[i + 1]
    pSbox[i + 1] = pSbox[j + 1]
    pSbox[j + 1] = temp
    d = pSbox[(pSbox[i + 1] + pSbox[j + 1]) mod 256 + 1]
    tCipher = tCipher & convertIntToHex(bitXor(charToNum(tdata.char[a]), d))
  end repeat
  return tCipher
end

on decipher me, tdata
  tCipher = EMPTY
  repeat with a = 1 to length(tdata)
    i = (i + 1) mod 256
    j = (j + pSbox[i + 1]) mod 256
    temp = pSbox[i + 1]
    pSbox[i + 1] = pSbox[j + 1]
    pSbox[j + 1] = temp
    d = pSbox[(pSbox[i + 1] + pSbox[j + 1]) mod 256 + 1]
    t = convertHexToInt(tdata.char[a..a + 1])
    tCipher = tCipher & numToChar(bitXor(t, d))
    a = a + 1
  end repeat
  return tCipher
end

on createKey me
  k = EMPTY
  the randomSeed = the milliSeconds
  repeat with i = 1 to 4
    k = k & convertIntToHex(random(256) - 1)
  end repeat
  return abs(convertHexToInt(k))
end
