property ancestor, pCatchFlag, pSavedHook, pToolTipAct, pToolTipSpr, pToolTipMem, pToolTipID, pToolTipDel, pCurrCursor, pLastCursor, pDecoder

on new me
  return me
end

on construct me
  pCatchFlag = 0
  pSavedHook = 0
  pToolTipAct = getIntVariable("tooltip.active", 0)
  if pToolTipAct then
    pToolTipMem = member(createMember("ToolTip Text", #field))
    pToolTipMem.boxType = #adjust
    pToolTipMem.wordWrap = 0
    pToolTipMem.rect = rect(0, 0, 10, 20)
    pToolTipMem.border = 1
    pToolTipMem.margin = 4
    pToolTipMem.alignment = "center"
    pToolTipMem.font = getStructVariable("struct.font.tooltip").getaProp(#font)
    pToolTipMem.fontSize = getStructVariable("struct.font.tooltip").getaProp(#fontSize)
    pToolTipSpr = sprite(reserveSprite(me.getID()))
    pToolTipSpr.member = pToolTipMem
    pToolTipSpr.visible = 0
    pToolTipSpr.locZ = 200000000
    pToolTipID = VOID
    pToolTipDel = getIntVariable("tooltip.delay", 2000)
  end if
  pCurrCursor = 0
  pLastCursor = 0
  pDecoder = createObject(#temp, getClassVariable("connection.decoder.class"))
  pDecoder.setKey("sulake1Unique2Key3Generator")
  return 1
end

on deconstruct me
  if not voidp(pToolTipSpr) then
    releaseSprite(pToolTipSpr.spriteNum)
  end if
  if not voidp(pToolTipMem) then
    removeMember(pToolTipMem.name)
  end if
  pDecoder = VOID
  return 1
end

on try me
  pCatchFlag = 0
  pSavedHook = the alertHook
  the alertHook = me
  return 1
end

on catch me
  the alertHook = pSavedHook
  return pCatchFlag
end

on createToolTip me, tText
  if pToolTipAct then
    if voidp(tText) then
      tText = "..."
    end if
    pToolTipSpr.visible = 0
    pToolTipMem.rect = rect(0, 0, length(tText) * 8, 20)
    pToolTipMem.text = tText
    pToolTipID = the milliSeconds
    return me.delay(pToolTipDel, #renderToolTip, pToolTipID)
  end if
end

on removeToolTip me, tNextID
  if pToolTipAct then
    if voidp(tNextID) or pToolTipID = tNextID then
      pToolTipID = VOID
      pToolTipSpr.visible = 0
      return 1
    end if
  end if
end

on renderToolTip me, tNextID
  if pToolTipAct then
    if tNextID <> pToolTipID or voidp(pToolTipID) then
      return 0
    end if
    pToolTipSpr.loc = the mouseLoc + [-2, 15]
    pToolTipSpr.visible = 1
    me.delay(pToolTipDel, #removeToolTip, pToolTipID)
  end if
end

on setCursor me, ttype
  case ttype of
    VOID:
      ttype = 0
    #arrow:
      ttype = 0
    #ibeam:
      ttype = 1
    #crosshair:
      ttype = 2
    #crossbar:
      ttype = 3
    #timer:
      ttype = 4
    #previous:
      ttype = pLastCursor
  end case
  cursor(ttype)
  pLastCursor = pCurrCursor
  pCurrCursor = ttype
  return 1
end

on openNetPage me, tURL_key
  if not stringp(tURL_key) then
    return 0
  end if
  tURL = getText(tURL_key, tURL_key)
  gotoNetPage(tURL, "_new")
  return 1
end

on showLoadingBar me, tLoadID, tProps
  tObj = createObject(#random, getClassVariable("loading.bar.class"))
  if not tObj.define(tLoadID, tProps) then
    removeObject(tObj.getID())
    return error(me, "Couldn't initialize loading bar instance!", #showLoadingBar)
  end if
  return tObj.getID()
end

on getUniqueID me
  return pDecoder.encipher(string(the milliSeconds))
end

on getMachineID me
  me.try()
  tMachineID = getPref(getVariable("pref.value.id"))
  if voidp(tMachineID) then
    tMachineID = me.getUniqueID()
    setPref(getVariable("pref.value.id"), tMachineID)
  end if
  if me.catch() then
    getErrorManager().SendMailAlert("Failed #setPref!", tMachineID, #getMachineID)
  end if
  return tMachineID
end

on secretDecode me, tKey
  tLength = tKey.length
  if tLength mod 2 = 1 then
    tLength = tLength - 1
  end if
  tTable = tKey.char[1..tKey.length / 2]
  tKey = tKey.char[1 + tKey.length / 2..tLength]
  tCheckSum = 0
  repeat with i = 1 to tKey.length
    c = tKey.char[i]
    a = offset(c, tTable) - 1
    if a mod 2 = 0 then
      a = a * 2
    end if
    if (i - 1) mod 3 = 0 then
      a = a * 3
    end if
    if a < 0 then
      a = tKey.length mod 2
    end if
    tCheckSum = tCheckSum + a
  end repeat
  return tCheckSum
end

on readValueFromField me, tField, tDelimiter, tSearchedKey
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
      if tProp = tSearchedKey then
        if not (tValue contains SPACE) and integerp(integer(tValue)) then
          if length(string(integer(tValue))) = length(tValue) then
            tValue = integer(tValue)
          end if
        else
          if floatp(float(tValue)) then
            tValue = float(tValue)
          end if
        end if
        if stringp(tValue) then
          repeat with j = 1 to tValue.length
            case charToNum(tValue.char[j]) of
              228:
                put "�" into char j of tValue
              246:
                put "�" into char j of tValue
            end case
          end repeat
        end if
        the itemDelimiter = tDelim
        return tValue
      end if
    end if
    the itemDelimiter = tDelimiter
  end repeat
  the itemDelimiter = tDelim
  return 0
end

on print me, tObj, tMsg
  tObj = string(tObj)
  tObj = tObj.word[2..tObj.word.count - 2]
  tObj = tObj.char[2..length(tObj)]
  put "Print:" & RETURN & TAB && "Object: " && tObj & RETURN & TAB && "Message:" && tMsg
end

on alertHook me
  pCatchFlag = 1
  the alertHook = pSavedHook
  return 1
end
