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
  artificialKey = [20, 210, 136, 205, 176, 188, 8, 194, 116, 128, 154, 120, 2, 150, 42, 249, 139, 65, 222, 200, 56, 190, 112, 62, 88, 75, 211, 214, 152, 37, 73, 237, 201, 65, 21, 40, 79, 226, 231, 49, 15, 152, 17, 225, 15, 246, 144, 35, 99, 223, 53, 167, 206, 178, 222, 137, 45, 227, 93, 28, 108, 132, 188, 176, 158, 120, 210, 72, 63, 14, 48, 42, 63, 248, 4, 138, 227, 246, 233, 69, 13, 130, 175, 220, 177, 57, 107, 124, 13, 1, 150, 125, 209, 180, 46, 154, 126, 113, 16, 59, 202, 187, 204, 12, 31, 197, 27, 86, 239, 9, 184, 188, 23, 243, 45, 27, 34, 85, 129, 67, 130, 221, 43, 80, 196, 72, 118, 222, 187, 204, 247, 12, 206, 169, 175, 70, 203, 224, 206, 30, 91, 32, 51, 16, 177, 19, 135, 147, 58, 112, 122, 132, 92, 203, 240, 167, 54, 25, 203, 146, 135, 152, 203, 188, 59, 57, 246, 68, 229, 39, 57, 198, 130, 109, 77, 102, 52, 173, 73, 22, 99, 37, 43, 64, 45, 188, 30, 178, 139, 176, 68, 241, 124, 169, 107, 36, 151, 27, 236, 108, 18, 190, 2, 23, 113, 249, 157, 198, 152, 209, 60, 204, 223, 84, 210, 199, 206, 212, 91, 139, 28, 133, 203, 149, 21, 131, 153, 148, 125, 81, 69, 119, 123, 106, 185, 84, 108, 3, 27, 57, 252, 203, 58, 142, 64, 139, 100, 143, 216, 17, 236, 5, 181, 3, 7, 33, 50, 208, 193, 191, 25, 121, 41, 128, 77, 4, 40, 151, 106, 52, 206, 59, 33, 161, 73, 118, 238, 183, 109, 110, 44, 252, 194, 81, 23, 106, 18, 22, 152, 107, 76, 10, 174, 108, 234, 246, 57, 239, 126, 11, 148, 161, 236, 166, 239, 31, 19, 222, 165, 51, 3, 14, 108, 109, 103, 60, 119, 113, 2, 215, 111, 248, 180, 84, 16, 49, 128, 89, 244, 167, 95, 254, 202, 158, 252, 217, 240, 129, 30, 161, 244, 22, 128, 215, 127, 100, 219, 202, 253, 200, 133, 91, 194, 10, 238, 217, 42, 52, 36, 81, 184, 96, 29, 34, 30, 97, 243, 247, 208, 155, 109, 35, 190, 224, 5, 181, 17, 234, 249, 67, 70, 96, 42, 156, 2, 224, 208, 202, 122, 219, 165, 86, 194, 173, 196, 220, 86, 113, 116, 11, 227, 157, 95, 79, 189, 108, 251, 89, 16, 5, 253, 93, 227, 129, 17, 180, 132, 167, 155, 229, 144, 98, 82, 126, 210, 65, 188, 137, 110, 238, 156, 39, 159, 100, 251, 119, 250, 57, 4, 151, 48, 191, 29, 38, 216, 189, 28, 106, 254, 90, 192, 102, 147, 9, 138, 108, 174, 186, 16, 131, 20, 160, 4, 253, 29, 89, 3, 207, 86, 1, 42, 114, 104, 57, 128, 101, 30, 164, 221, 41, 14, 39, 134, 86, 187, 147, 92, 189, 159, 125, 189, 118, 43, 217, 222, 229, 156, 225, 116, 232, 5, 156, 50, 89, 115, 208, 221, 186, 33, 79, 210, 115, 179, 99, 63, 101, 216, 21, 199, 90, 242, 163, 132, 4, 72, 42, 101, 31, 255, 97, 85, 151, 14, 58, 92, 201, 80, 81, 159, 92, 66, 190, 184, 115, 210, 28, 22, 62, 202, 20, 109, 86, 120, 247, 39, 225, 56, 228, 245, 193, 74, 204, 238, 73, 204, 232, 249, 52, 195, 61, 89, 123, 86, 0, 3, 187, 178, 42, 177, 118, 6, 244, 230, 220, 6, 255, 20, 196, 120, 106, 144, 12, 40, 193, 221, 237, 112, 105, 170, 196, 210, 32, 220, 136, 37, 46, 182, 20, 128, 218, 51, 8, 24, 180, 255, 193, 246, 26, 214, 52, 187, 85, 153, 195, 104, 64, 147, 78, 124, 87, 35, 207, 72, 243, 74, 60, 236, 52, 62, 7, 204, 38, 90, 140, 27, 1, 124, 246, 164, 177, 218, 229, 104, 102, 16, 182, 123, 233, 43, 211, 73, 159, 202, 135, 53, 144, 233, 7, 219, 112, 0, 224, 10, 128, 179, 79, 67, 145, 68, 241, 243, 107, 104, 170, 26, 71, 162, 247, 248, 203, 190, 122, 130, 68, 152, 113, 107, 57, 149, 217, 152, 23, 183, 19, 19, 37, 62, 168, 83, 211, 13, 183, 198, 129, 199, 61, 30, 31, 64, 1, 25, 200, 133, 248, 167, 120, 250, 152, 3, 44, 25, 107, 187, 114, 223, 85, 161, 11, 229, 229, 39, 237, 214, 180, 134, 22, 252, 1, 248, 244, 38, 181, 59, 127, 129, 219, 139, 1, 182, 116, 215, 68, 209, 27, 80, 234, 196, 8, 214, 88, 162, 160, 44, 10, 218, 18, 162, 165, 158, 148, 222, 224, 128, 54, 98, 212, 122, 191, 215, 239, 252, 146, 5, 181, 76, 73, 88, 223, 242, 142, 182, 105, 72, 30, 227, 249, 199, 126, 11, 127, 165, 152, 59, 15, 10, 160, 178, 252, 131, 159, 133, 165, 53, 229, 114, 198, 226, 96, 71, 86, 23, 150, 168, 107, 51, 8, 98, 30, 105, 173, 180, 83, 49, 92, 46, 147, 99, 232, 247, 31, 91, 132, 101, 44, 44, 146, 68, 176, 107, 112, 135, 113, 160, 170, 249, 132, 101, 175, 210, 170, 253, 252, 24, 210, 174, 17, 8, 9, 254, 173, 30, 137, 80, 243, 155, 220, 167, 179, 103, 123, 143, 208, 244, 187, 158, 66, 88, 141, 207, 171, 242, 49, 247, 178, 179, 82, 223, 43, 210, 8, 198, 55, 186, 102, 146, 180, 31, 83, 159, 73, 10, 247, 92, 159, 95, 67, 182, 245, 91, 86, 200, 185, 146, 132, 229, 72, 136, 148, 154, 12, 197, 104, 252, 178, 128, 27, 0, 194, 59, 184, 132, 250, 31, 189, 26, 38, 11, 131, 40, 199, 249, 131, 244, 86, 25, 224, 176, 29, 154, 137, 91, 158, 207, 79, 228, 153, 203, 30, 231, 113, 17, 86, 100, 237, 222, 70, 132, 241, 51, 30, 65, 62, 15, 245, 32, 198, 0, 109, 123, 169, 115, 51, 234, 160, 21, 24, 49, 58, 25, 109, 75, 59, 19, 127, 207, 39, 66, 17, 229, 87, 130, 106, 175, 136]
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
      m = 5
      repeat with i = 0 to len - 1
        tGiven = me.bitshiftright(tMyKey, i mod 32)
        tOwn = artificialKey[abs(tOffset + i) mod artificialKey.count + 1]
        ckey[i + 1] = bitAnd(bitXor(tGiven, tOwn), 32767)
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

on bitshiftright me, x, n
  return bitOr(x / power(2, n), 0)
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
