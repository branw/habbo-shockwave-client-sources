on doSpecialCharConversion s
  global gConvList
  if voidp(gConvList) then
    initConversionList()
  end if
  repeat with i = count(gConvList) down to 1
    s = stringReplace(s, getPropAt(gConvList, i), getProp(gConvList, getPropAt(gConvList, i)))
  end repeat
  return s
end

on initConversionList
  global gConvList
  gConvList = [:]
  addProp(gConvList, "&auml;", "Š")
  addProp(gConvList, "&ouml;", "š")
  if not (the platform contains "win") then
    addProp(gConvList, numToChar(228), "Š")
    addProp(gConvList, numToChar(246), "š")
    addProp(gConvList, numToChar(196), "€")
    addProp(gConvList, numToChar(214), "…")
    addProp(gConvList, numToChar(229), "Œ")
    addProp(gConvList, numToChar(197), "")
  end if
  if the platform contains "win" then
    addProp(gConvList, numToChar(138), numToChar(228))
    addProp(gConvList, numToChar(154), numToChar(246))
    addProp(gConvList, numToChar(128), numToChar(196))
    addProp(gConvList, numToChar(133), numToChar(214))
    addProp(gConvList, numToChar(140), numToChar(229))
    addProp(gConvList, numToChar(129), numToChar(197))
  end if
end

on keyValueToPropList s, delim
  oldDelim = the itemDelimiter
  if delim = VOID then
    delim = ","
  end if
  the itemDelimiter = delim
  p = [:]
  repeat with i = 1 to the number of items in s
    pair = item i of s
    addProp(p, char 1 to offset("=", pair) - 1 of pair, char offset("=", pair) + 1 to s.length of pair)
  end repeat
  the itemDelimiter = oldDelim
  return p
end

on charReplace s, c0, c1
  if c0 = c1 then
    return s
  end if
  repeat while offset(c0, s) > 0
    put c1 into char offset(c0, s) of s
  end repeat
  return s
end

on stringReplace input, oldStr, newStr
  s = EMPTY
  repeat while input contains oldStr
    posn = offset(oldStr, input) - 1
    if posn > 0 then
      put char 1 to posn of input after s
    end if
    put newStr after s
    delete char 1 to posn + length(oldStr) of input
  end repeat
  put input after s
  return s
end
