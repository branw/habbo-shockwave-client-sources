property ancestor, pConvList, pDigits

on new me
  return me
end

on construct me
  pConvList = me.initConvList()
  pDigits = "0123456789ABCDEF"
  return 1
end

on convertToPropList me, tStr, tDelim
  tOldDelim = the itemDelimiter
  if tDelim = VOID then
    tDelim = ","
  end if
  the itemDelimiter = tDelim
  tProps = [:]
  repeat with i = 1 to tStr.item.count
    tPair = tStr.item[i].word[1..tStr.item[i].word.count]
    tProp = tPair.char[1..offset("=", tPair) - 1]
    tValue = tPair.char[offset("=", tPair) + 1..tStr.length]
    tProps[tProp.word[1..tProp.word.count]] = tValue.word[1..tValue.word.count]
  end repeat
  the itemDelimiter = tOldDelim
  return tProps
end

on convertToLowerCase me, tString
  tValueStr = EMPTY
  repeat with i = 1 to length(tString)
    tChar = tString.char[i]
    tNum = charToNum(tChar)
    if tNum >= 65 and tNum <= 90 then
      tChar = numToChar(tNum + 32)
    end if
    tValueStr = tValueStr & tChar
  end repeat
  return tValueStr
end

on convertToHigherCase me, tString
  tValueStr = EMPTY
  repeat with i = 1 to length(tString)
    tChar = tString.char[i]
    tNum = charToNum(tChar)
    if tNum >= 97 and tNum <= 122 then
      tChar = numToChar(tNum - 32)
    end if
    tValueStr = tValueStr & tChar
  end repeat
  return tValueStr
end

on convertSpecialChars me, tString
  repeat with i = pConvList.count down to 1
    tChunkA = pConvList.getPropAt(i)
    tChunkB = pConvList[tChunkA]
    tTmpStr = tString
    tStr = EMPTY
    repeat while tTmpStr contains tChunkA
      tPos = offset(tChunkA, tTmpStr) - 1
      if tPos > 0 then
        put tTmpStr.char[1..tPos] after tStr
      end if
      put tChunkB after tStr
      delete (tTmpStr).char[1..tPos + length(tChunkA)]
    end repeat
    put tTmpStr after tStr
    tString = tStr
  end repeat
  return tString
end

on convertIntToHex me, tInt
  if tInt <= 0 then
    return "00"
  else
    repeat while tInt > 0
      d = tInt mod 16
      tInt = tInt / 16
      tHexstr = pDigits.char[d + 1] & tHexstr
    end repeat
  end if
  if tHexstr.length mod 2 = 1 then
    tHexstr = "0" & tHexstr
  end if
  return tHexstr
end

on convertHexToInt me, tHex
  tBase = 1
  tValue = 0
  repeat while length(tHex) > 0
    lc = the last char in tHex
    delete char -30000 of tHex
    vl = offset(lc, pDigits) - 1
    tValue = tValue + tBase * vl
    tBase = tBase * 16
  end repeat
  return tValue
end

on replaceChars me, tString, tCharA, tCharB
  if tCharA = tCharB then
    return tString
  end if
  repeat while offset(tCharA, tString) > 0
    put tCharB into char offset(tCharA, tString) of tString
  end repeat
  return tString
end

on replaceChunks me, tString, tChunkA, tChunkB
  tStr = EMPTY
  repeat while tString contains tChunkA
    tPos = offset(tChunkA, tString) - 1
    if tPos > 0 then
      put tString.char[1..tPos] after tStr
    end if
    put tChunkB after tStr
    delete (tString).char[1..tPos + length(tChunkA)]
  end repeat
  put tString after tStr
  return tStr
end

on initConvList me
  if the platform contains "win" then
    tMachineType = ".win"
  else
    tMachineType = ".mac"
  end if
  tConvList = [:]
  tCharList = getVariableValue("char.conversion" & tMachineType, ["&auml;": "Š", "&ouml;": "š"])
  repeat with i = 1 to tCharList.count
    tKey = tCharList.getPropAt(i)
    tVal = tCharList[i]
    if integerp(integer(tKey)) then
      tKey = numToChar(integer(tKey))
    end if
    if integerp(integer(tVal)) then
      tVal = numToChar(integer(tVal))
    end if
    tConvList[tKey] = tVal
  end repeat
  return tConvList
end
