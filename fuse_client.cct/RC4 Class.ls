property pSbox, pKey, i, j, pLog
global _player

on setKey me, tMyKey, tMode
  if _player <> VOID then
    if _player.traceScript then
      return 0
    end if
  end if
  pLog = VOID
  tMyKeyS = string(tMyKey)
  pSbox = []
  pKey = []
  artificialKey = [209, 115, 122, 150, 70, 174, 114, 242, 78, 73, 104, 81, 109, 117, 83, 24, 86, 53, 89, 182, 16, 240, 252, 221, 183, 2, 92, 108, 61, 216, 153, 176, 203, 42, 225, 67, 74, 157, 235, 255, 172, 81, 208, 124, 247, 131, 83, 222, 99, 213, 2, 33, 251, 243, 234, 71, 98, 2, 242, 41, 84, 127, 172, 227, 79, 241, 38, 68, 221, 189, 219, 98, 189, 158, 16, 163, 101, 94, 109, 169, 93, 215, 140, 50, 244, 43, 87, 179, 139, 25, 17, 182, 33, 23, 224, 103, 202, 146, 60, 109, 250, 54, 250, 164, 190, 160, 11, 177, 50, 121, 6, 21, 196, 162, 53, 123, 211, 196, 31, 107, 137, 26, 252, 8, 93, 13, 203, 170, 255, 227, 40, 72, 248, 81, 205, 230, 203, 31, 92, 30, 218, 33, 102, 105, 173, 151, 44, 126, 223, 84, 109, 159, 117, 69, 51, 62, 194, 232, 113, 98, 182, 126, 19, 239, 226, 55, 177, 53, 251, 214, 16, 17, 67, 250, 163, 214, 233, 28, 151, 183, 45, 131, 174, 182, 155, 230, 31, 178, 172, 98, 29, 101, 27, 142, 168, 64, 71, 61, 127, 26, 247, 70, 31, 17, 55, 245, 221, 113, 65, 116, 158, 4, 247, 86, 161, 4, 148, 114, 235, 31, 68, 18, 76, 172, 255, 146, 79, 20, 178, 5, 139, 129, 82, 146, 76, 191, 38, 84, 24, 137, 125, 25, 176, 200, 219, 202, 178, 123, 178, 252, 236, 128, 141, 213, 252, 4, 232, 20, 113, 132, 60, 173, 237, 114, 204, 64, 120, 222, 48, 141, 11, 27, 87, 108, 2, 208, 46, 167, 138, 96, 229, 228, 82, 161, 215, 61, 50, 92, 94, 240, 140, 25, 99, 215, 165, 46, 152, 187, 27, 47, 125, 221, 84, 174, 73, 104, 210, 149, 202, 1, 147, 140, 120, 171, 142, 80, 175, 254, 20, 49, 199, 29, 248, 63, 136, 48, 151, 210, 104, 250, 242, 240, 49, 218, 109, 191, 124, 151, 2, 203, 126, 16, 70, 111, 215, 49, 12, 223, 75, 226, 179, 62, 42, 50, 219, 246, 15, 120, 63, 232, 12, 239, 115, 102, 239, 121, 206, 104, 34, 19, 116, 194, 133, 250, 44, 159, 147, 158, 16, 80, 145, 5, 194, 121, 214, 190, 82, 89, 25, 128, 199, 126, 146, 248, 189, 174, 223, 254, 37, 79, 99, 179, 248, 244, 122, 96, 69, 63, 207, 9, 27, 230, 100, 11, 146, 91, 176, 72, 231, 197, 167, 118, 187, 110, 156, 24, 223, 135, 4, 128, 26, 23, 66, 251, 215, 166, 199, 185, 78, 43, 166, 181, 186, 140, 235, 5, 255, 118, 225, 19, 120, 193, 120, 73, 13, 140, 185, 4, 204, 95, 242, 210, 223, 196, 246, 167, 112, 104, 111, 133, 76, 89, 20, 108, 82, 61, 48, 30, 207, 215, 137, 9, 122, 207, 20, 198, 9, 99, 247, 43, 52, 192, 100, 231, 130, 80, 98, 223, 46, 51, 135, 15, 192, 71, 140, 112, 170, 250, 66, 11, 60, 12, 214, 81, 29, 61, 100, 155, 195, 26, 107, 218, 237, 134, 84, 38, 30, 51, 38, 247, 103, 165, 72, 150, 92, 150, 180, 79, 137, 218, 83, 228, 83, 9, 151, 113, 202, 169, 160, 186, 126, 218, 107, 161, 173, 136, 127, 141, 58, 247, 142, 38, 212, 3, 50, 95, 129, 118, 5, 193, 6, 10, 80, 39, 113, 223, 55, 29, 138, 143, 91, 235, 131, 241, 114, 132, 59, 56, 164, 41, 150, 248, 44, 48, 235, 155, 1, 173, 206, 156, 74, 220, 116, 54, 126, 56, 98, 230, 124, 173, 75, 22, 150, 226, 99, 51, 121, 147, 88, 169, 211, 110, 226, 252, 5, 215, 176, 87, 6, 249, 128, 114, 157, 37, 103, 239, 172, 88, 165, 181, 57, 154, 238, 172, 58, 62, 192, 127, 111, 227, 239, 135, 53, 170, 205, 100, 173, 116, 209, 155, 194, 7, 15, 141, 159, 217, 7, 207, 26, 59, 95, 249, 5, 239, 111, 24, 236, 219, 106, 0, 95, 54, 251, 253, 64, 246, 143, 102, 245, 71, 51, 140, 157, 15, 243, 249, 204, 44, 31, 7, 226, 104, 251, 75, 133, 184, 60, 189, 170, 226, 178, 23, 246, 150, 190, 140, 53, 77, 126, 85, 186, 249, 208, 12, 71, 247, 155, 138, 137, 26, 178, 23, 61, 69, 37, 71, 136, 73, 208, 118, 5, 198, 75, 48, 79, 60, 156, 100, 36, 113, 160, 14, 114, 253, 31, 117, 3, 94, 117, 13, 37, 51, 192, 9, 2, 40, 29, 202, 57, 103, 158, 239, 198, 71, 122, 222, 130, 86, 219, 233, 225, 96, 196, 95, 116, 166, 45, 33, 226, 66, 205, 245, 190, 1, 240, 212, 110, 108, 32, 165, 231, 44, 55, 213, 109, 21, 226, 37, 50, 1, 231, 206, 134, 107, 64, 21, 165, 98, 93, 158, 219, 79, 174, 111, 246, 56, 149, 73, 9, 252, 51, 18, 158, 102, 117, 100, 156, 192, 160, 199, 170, 15, 18, 104, 162, 82, 187, 109, 227, 159, 55, 1, 42, 161, 3, 172, 57, 19, 233, 220, 124, 29, 180, 139, 202, 220, 101, 141, 86, 22, 55, 159, 176, 119, 88, 188, 243, 223, 119, 220, 46, 15, 187, 250, 105, 122, 140, 188, 12, 77, 11, 119, 157, 199, 164, 150, 111, 89, 15, 112, 206, 130, 52, 188, 126, 162, 15, 92, 21, 72, 90, 71, 50, 35, 26, 31, 179, 31, 135, 232, 240, 127, 26, 93, 90, 246, 53, 235, 221, 121, 152, 231, 78, 20, 106, 16, 105, 94, 207, 45, 210, 131, 34, 169, 106, 113, 195, 100, 124, 238, 43, 75, 149, 187, 200, 129, 165, 183, 38, 121, 61, 168, 241, 120, 222, 71, 73, 99, 123, 37, 251, 219, 191, 22, 82, 235, 109, 241, 121, 161, 113, 255, 212, 250, 59, 64, 191, 12, 196, 55, 178, 83, 105, 23, 84, 185, 185, 1, 238, 72, 250, 30, 84, 132, 142, 81, 130, 168, 44, 143, 101, 80, 192, 47, 21, 227, 181, 172, 89, 124, 161, 244, 149, 180]
  if voidp(tMode) then
    if voidp(value(tMyKey)) then
      tMode = #old
    else
      tMode = #artificialKey
    end if
  end if
  case tMode of
    #old, VOID:
      repeat with i = 0 to 255
        pKey[i + 1] = charToNum(tMyKeyS.char[i mod length(tMyKeyS) + 1])
        pSbox[i + 1] = i
      end repeat
    #artificialKey:
      len = bitAnd(tMyKey, 248) / 8
      if len < 20 then
        len = len + 20
      end if
      tOffset = tMyKey mod 1024
      ckey = []
      fakeKey = []
      prevKey = 0
      m = 3
      repeat with i = 0 to len - 1
        tFactor1 = 29
        tFactor2 = 5
        keySkip = prevKey mod tFactor1 - i mod tFactor2
        fakeKey[i + 1] = i
        m = m * -1
        nkey = artificialKey[abs(tOffset + i * m * keySkip + keySkip) mod count(artificialKey) + 1]
        prevKey = nkey
        ckey[i + 1] = nkey
        fakeKey[i + 1] = nkey + 2 + fakeKey[i + 1]
      end repeat
      repeat with i = 0 to 255
        pKey[i + 1] = ckey[i mod len + 1]
        fakeKey[i + 1] = pKey[i + 1]
        pSbox[i + 1] = i
      end repeat
    #new:
      repeat with i = 0 to 255
        pKey[i + 1] = i
      end repeat
      repeat with i = 0 to 1019
        pKey[i mod 256 + 1] = (charToNum(tMyKeyS.char[i mod length(tMyKeyS) + 1]) + pKey[i mod 256 + 1]) mod 256
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
  if _player <> VOID then
    if _player.traceScript then
      return 0
    end if
  end if
  tCipher = EMPTY
  tBytes = []
  repeat with e = 1 to length(tdata)
    a = charToNum(char e of tdata)
    if a > 255 then
      add(tBytes, (a - a mod 256) / 256)
      add(tBytes, a mod 256)
      next repeat
    end if
    add(tBytes, a)
  end repeat
  tStrServ = getStringServices()
  repeat with a = 1 to tBytes.count
    i = (i + 1) mod 256
    j = (j + pSbox[i + 1]) mod 256
    temp = pSbox[i + 1]
    pSbox[i + 1] = pSbox[j + 1]
    pSbox[j + 1] = temp
    d = pSbox[(pSbox[i + 1] + pSbox[j + 1]) mod 256 + 1]
    tCipher = tCipher & tStrServ.convertIntToHex(bitXor(tBytes[a], d))
  end repeat
  return tCipher
end

on decipher me, tdata
  if _player <> VOID then
    if _player.traceScript then
      return 0
    end if
  end if
  tCipher = EMPTY
  tStrServ = getStringServices()
  repeat with a = 1 to length(tdata)
    i = (i + 1) mod 256
    j = (j + pSbox[i + 1]) mod 256
    temp = pSbox[i + 1]
    pSbox[i + 1] = pSbox[j + 1]
    pSbox[j + 1] = temp
    d = pSbox[(pSbox[i + 1] + pSbox[j + 1]) mod 256 + 1]
    t = tStrServ.convertHexToInt(tdata.char[a..a + 1])
    tCipher = tCipher & numToChar(bitXor(t, d))
    a = a + 1
  end repeat
  return tCipher
end

on createKey me
  if _player <> VOID then
    if _player.traceScript then
      return 0
    end if
  end if
  tKeyMinLength = 30
  tKeyLengthVariation = 40
  tCharacters = "abcdefghijklmnopqrstuvwxyz1234567890"
  tSeed = the randomSeed
  the randomSeed = the milliSeconds
  tLength = tKeyMinLength + abs(random(65536) mod tKeyLengthVariation)
  tTable = EMPTY
  tKey = EMPTY
  repeat with i = 1 to tLength
    c = tCharacters.char[random(65536) mod tCharacters.length + 1]
    tTable = tTable & c
    c = tCharacters.char[random(65536) mod tCharacters.length + 1]
    tTable = tTable & c
    tKey = tKey & c
  end repeat
  tCodedKey = tTable & tKey
  the randomSeed = tSeed
  return tCodedKey
end

on preMixDecodeSbox me, tTestData, tCount
  repeat with k = 1 to tCount
    me.decipher(tTestData)
  end repeat
end

on preMixEncodeSbox me, tTestData, tCount
  repeat with l = 1 to tCount
    me.encipher(tTestData)
  end repeat
end

on enableLog me, tMemberName
end

on setLog me, tTextMember
end

on dumpState me
end
