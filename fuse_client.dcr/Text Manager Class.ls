property ancestor, pSpecialMarks

on new me
  return me
end

on construct me
  pSpecialMarks = ["\r": RETURN, "\t": TAB, "\s": SPACE, "<BR>": RETURN]
  return 1
end

on get me, tKey, tDefault
  tText = me.pItemList[tKey]
  if voidp(tText) then
    tError = "Text not found:" && tKey
    if not voidp(tDefault) then
      tText = tDefault
      tError = tError & RETURN & "Using given default:" && tDefault
    else
      tText = tKey
    end if
    error(me, tError, #get)
  end if
  return tText
end

on dump me, tField, tDelimiter
  if not memberExists(tField) then
    return error(me, "Field member expected:" && tField, #dump)
  end if
  tStr = field(tField)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = RETURN
  end if
  the itemDelimiter = tDelimiter
  repeat with i = 1 to tStr.item.count
    tPair = tStr.item[i]
    if tPair.word[1].char[1] <> "#" and tPair <> EMPTY then
      the itemDelimiter = "="
      tProp = tPair.item[1].word[1..tPair.item[1].word.count]
      tValue = tPair.item[2..tPair.item.count]
      tValue = tValue.word[1..tValue.word.count]
      if offset("$", tValue) > 0 then
      end if
      repeat with j = 1 to tValue.length
        case charToNum(tValue.char[j]) of
          228:
            put "Š" into char j of tValue
          246:
            put "š" into char j of tValue
        end case
      end repeat
      repeat with k = 1 to pSpecialMarks.count
        tMark = pSpecialMarks.getPropAt(k)
        if tValue contains tMark then
          tValue = replaceChunks(tValue, tMark, pSpecialMarks[k])
        end if
      end repeat
      me.pItemList[tProp] = tValue
    end if
    the itemDelimiter = tDelimiter
  end repeat
  the itemDelimiter = tDelim
  return 1
end
