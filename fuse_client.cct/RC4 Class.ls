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
  artificialKey = [204, 53, 74, 109, 63, 4, 163, 182, 210, 186, 19, 162, 160, 115, 139, 83, 235, 177, 14, 15, 11, 127, 4, 210, 222, 138, 10, 138, 151, 236, 158, 186, 67, 1, 168, 69, 139, 214, 243, 32, 157, 161, 211, 155, 20, 192, 214, 155, 12, 153, 192, 112, 98, 146, 33, 30, 22, 131, 81, 161, 105, 142, 103, 204, 112, 9, 167, 185, 176, 51, 27, 166, 249, 228, 24, 165, 197, 25, 166, 216, 74, 14, 104, 15, 77, 49, 6, 50, 65, 126, 10, 187, 15, 17, 189, 155, 246, 221, 92, 104, 79, 87, 186, 88, 80, 50, 223, 126, 148, 217, 81, 223, 91, 70, 165, 237, 150, 95, 195, 205, 199, 176, 156, 122, 187, 232, 252, 230, 169, 94, 157, 194, 44, 164, 208, 22, 141, 139, 167, 236, 201, 42, 130, 14, 44, 57, 253, 224, 130, 118, 242, 226, 146, 202, 154, 40, 201, 171, 160, 91, 143, 144, 150, 197, 169, 204, 121, 131, 139, 112, 214, 196, 74, 123, 159, 220, 77, 176, 151, 73, 125, 135, 166, 26, 176, 31, 255, 234, 91, 30, 218, 41, 121, 17, 45, 3, 234, 35, 185, 52, 112, 108, 65, 72, 184, 93, 225, 113, 62, 0, 110, 38, 43, 15, 44, 114, 162, 167, 69, 40, 103, 144, 114, 215, 228, 47, 112, 235, 179, 211, 116, 237, 70, 167, 36, 224, 183, 11, 0, 74, 145, 241, 153, 40, 151, 211, 231, 199, 235, 176, 109, 95, 160, 141, 137, 236, 39, 17, 246, 97, 120, 227, 12, 1, 195, 239, 150, 169, 85, 226, 23, 58, 145, 157, 37, 218, 132, 168, 94, 15, 240, 24, 152, 230, 249, 80, 145, 208, 209, 144, 154, 228, 197, 40, 6, 248, 90, 15, 1, 82, 145, 77, 220, 27, 167, 0, 149, 0, 103, 53, 226, 242, 175, 9, 177, 130, 65, 216, 107, 4, 194, 71, 135, 231, 151, 178, 188, 220, 33, 152, 120, 165, 73, 124, 32, 215, 127, 130, 29, 40, 20, 3, 212, 254, 106, 42, 98, 7, 8, 129, 195, 30, 74, 118, 169, 81, 88, 235, 149, 232, 181, 182, 206, 82, 163, 26, 116, 37, 41, 50, 63, 185, 165, 2, 81, 10, 149, 103, 211, 168, 34, 55, 32, 233, 16, 238, 219, 235, 170, 255, 244, 12, 89, 211, 88, 33, 24, 38, 190, 75, 70, 86, 89, 2, 189, 134, 207, 65, 6, 148, 124, 22, 57, 21, 118, 227, 173, 21, 236, 236, 139, 189, 230, 153, 153, 182, 230, 216, 26, 0, 9, 50, 32, 189, 97, 3, 208, 201, 103, 163, 96, 0, 42, 11, 173, 98, 102, 76, 31, 243, 59, 71, 223, 252, 186, 157, 231, 90, 212, 83, 10, 69, 69, 165, 209, 112, 157, 237, 24, 90, 4, 44, 247, 32, 159, 126, 171, 99, 216, 196, 228, 217, 157, 143, 32, 16, 111, 67, 106, 231, 10, 167, 13, 240, 182, 105, 52, 12, 84, 91, 243, 205, 180, 180, 35, 58, 238, 240, 0, 209, 48, 249, 243, 209, 93, 10, 22, 183, 5, 177, 110, 16, 188, 201, 240, 194, 11, 76, 219, 67, 254, 176, 139, 66, 81, 138, 109, 178, 71, 143, 74, 217, 52, 0, 127, 190, 12, 214, 231, 84, 239, 165, 155, 89, 95, 106, 62, 30, 182, 137, 85, 39, 221, 51, 188, 149, 104, 167, 71, 11, 220, 212, 246, 114, 10, 4, 216, 127, 233, 231, 178, 174, 181, 29, 49, 118, 177, 108, 156, 174, 118, 196, 216, 106, 203, 96, 65, 12, 140, 248, 152, 35, 152, 17, 89, 136, 138, 94, 5, 190, 92, 189, 16, 216, 61, 70, 165, 36, 238, 167, 16, 61, 206, 140, 226, 251, 37, 225, 211, 111, 42, 195, 36, 248, 233, 67, 146, 100, 244, 23, 154, 103, 48, 4, 15, 33, 169, 151, 13, 151, 115, 173, 37, 103, 172, 23, 182, 29, 22, 25, 54, 46, 188, 14, 24, 12, 182, 241, 163, 90, 121, 172, 29, 73, 191, 91, 232, 229, 197, 200, 32, 7, 67, 214, 141, 248, 10, 135, 168, 4, 144, 17, 94, 228, 76, 202, 130, 174, 251, 170, 100, 173, 232, 183, 132, 130, 35, 163, 1, 154, 134, 56, 202, 13, 190, 224, 56, 107, 107, 244, 16, 12, 149, 220, 120, 245, 179, 103, 85, 255, 195, 187, 191, 82, 225, 13, 206, 106, 60, 212, 12, 211, 247, 112, 185, 5, 56, 226, 236, 179, 181, 208, 204, 16, 159, 158, 36, 65, 101, 148, 23, 89, 125, 27, 61, 117, 255, 142, 32, 138, 105, 166, 203, 253, 113, 138, 30, 247, 250, 198, 21, 244, 113, 40, 161, 229, 179, 100, 76, 30, 177, 69, 87, 90, 9, 135, 254, 108, 99, 145, 195, 145, 138, 223, 237, 52, 126, 244, 109, 171, 44, 0, 187, 129, 127, 49, 220, 100, 253, 0, 116, 93, 87, 39, 245, 5, 54, 203, 241, 155, 255, 125, 80, 253, 75, 71, 242, 147, 153, 148, 214, 91, 33, 181, 78, 10, 82, 171, 89, 179, 221, 144, 224, 138, 112, 254, 152, 186, 190, 224, 44, 251, 60, 133, 65, 70, 72, 203, 126, 123, 212, 108, 68, 185, 42, 208, 51, 11, 177, 3, 24, 207, 14, 148, 113, 55, 1, 19, 179, 31, 133, 11, 227, 72, 145, 242, 157, 244, 239, 129, 124, 109, 56, 134, 56, 95, 110, 161, 73, 151, 136, 67, 176, 201, 193, 70, 53, 31, 238, 84, 81, 65, 50, 182, 20, 17, 247, 179, 217, 14, 34, 182, 97, 55, 117, 176, 108, 234, 147, 89, 168, 7, 251, 212, 22, 107, 63, 248, 179, 222, 167, 214, 136, 74, 53, 47, 120, 233, 131, 41, 167, 220, 56, 12, 51, 125, 207, 112, 179, 211, 47, 134, 223, 112, 223, 46, 249, 24, 64, 58, 36, 187, 77, 132, 116, 116, 111, 36, 127, 217, 177, 24, 58, 102, 166, 105, 119, 234, 187, 198, 77, 153, 23, 157, 103, 92, 33, 136, 182, 131, 154, 141, 149, 4, 117, 213, 226, 64, 116, 55, 6, 159, 126, 225]
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
