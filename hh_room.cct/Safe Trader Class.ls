property pState, pTraderPal, pAcceptFlagMe, pAcceptFlagHe, pMyStripItems, pItemListMe, pItemListHe, pTraderWndID, pMaxTradeItms, pItemSlotRect

on construct me
  pState = #closed
  pTraderWndID = getText("trading_title", "Safe Trading")
  pAcceptFlagMe = 0
  pAcceptFlagHe = 0
  pItemListMe = []
  pItemListHe = []
  pMyStripItems = []
  pMaxTradeItms = 0
  pItemSlotRect = rect(0, 0, 32, 32)
  return 1
end

on deconstruct me
  return me.close()
end

on open me, tdata
  getThread(#room).getInterface().pClickAction = "tradeItem"
  if windowExists(pTraderWndID) then
    return 0
  end if
  if tdata.count > 1 then
    if tdata.getPropAt(1) <> getObject(#session).get("user_name") then
      pTraderPal = tdata.getPropAt(1)
    else
      pTraderPal = tdata.getPropAt(2)
    end if
  else
    pTraderPal = tdata.getPropAt(1)
  end if
  if voidp(pTraderPal) or pTraderPal = EMPTY then
    pTraderPal = "He/she"
  end if
  if not createWindow(pTraderWndID, "habbo_basic.window") then
    return 0
  end if
  tWndObj = getWindow(pTraderWndID)
  tWndObj.merge("habbo_trading.window")
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcTrading, me.getID())
  tWndObj.getElement("trading_heoffers_text").setText(pTraderPal && getText("trading_offers", "offers"))
  tWndObj.getElement("trading_agrees_text").setText(pTraderPal && getText("trading_agrees", "agrees"))
  pMaxTradeItms = 0
  repeat while 1
    if not getWindow(pTraderWndID).elementExists("trading_mystuff_" & pMaxTradeItms + 1) then
      exit repeat
    end if
    pMaxTradeItms = pMaxTradeItms + 1
  end repeat
  repeat with i = 1 to pMaxTradeItms
    tWndObj.getElement("trading_mystuff_" & i).draw(rgb(200, 200, 200))
    tWndObj.getElement("trading_herstuff_" & i).draw(rgb(200, 200, 200))
  end repeat
  tWidth = tWndObj.getElement("trading_mystuff_1").getProperty(#width)
  tHeight = tWndObj.getElement("trading_mystuff_1").getProperty(#height)
  pItemSlotRect = rect(0, 0, tWidth, tHeight)
  pState = #open
  me.accept()
  return 1
end

on close me, tdata
  getThread(#room).getInterface().pClickAction = "moveHuman"
  getThread(#room).getInterface().getObjectMover().clear()
  if windowExists(pTraderWndID) then
    pAcceptFlagMe = 0
    pAcceptFlagHe = 0
    pItemListMe = []
    pItemListHe = []
    pMyStripItems = []
    removeWindow(pTraderWndID)
  end if
  pState = #closed
  return 1
end

on accept me, tuser, tValue
  if pState = #closed then
    return 0
  end if
  if not voidp(tuser) and not voidp(tValue) then
    if tuser = pTraderPal then
      pAcceptFlagHe = tValue
    else
      if tuser = getObject(#session).get("user_name") then
        pAcceptFlagMe = tValue
        me.blendLockedSlots(tValue)
      end if
    end if
  end if
  if pAcceptFlagMe then
    tOnOff = "on"
  else
    tOnOff = "off"
  end if
  tImage = member(getmemnum("button.checkbox." & tOnOff)).image
  getWindow(pTraderWndID).getElement("trading_confirm_check").feedImage(tImage)
  if pAcceptFlagHe then
    tOnOff = "on"
    tBlend = 255
  else
    tOnOff = "off"
    tBlend = 128
  end if
  tImageA = member(getmemnum("button.checkbox." & tOnOff)).image
  tImageB = image(tImageA.width, tImageA.height, tImageA.depth, tImageA.paletteRef)
  tImageB.copyPixels(tImageA, tImageA.rect, tImageA.rect, [#blendLevel: tBlend])
  getWindow(pTraderWndID).getElement("trading_buddycheck_image").feedImage(tImageB)
end

on refresh me, tdata
  me.open(tdata)
  pMyStripItems = []
  tWndObj = getWindow(pTraderWndID)
  pItemListMe = tdata[getObject(#session).get("user_name")][#items]
  repeat with i = 1 to pItemListMe.count
    tImage = me.createItemImg(pItemListMe[i])
    tWndObj.getElement("trading_mystuff_" & i).feedImage(tImage)
    tWndObj.getElement("trading_mystuff_" & i).draw(rgb(64, 64, 64))
    pMyStripItems.add(pItemListMe[i][#stripId])
    if i = pMaxTradeItms then
      exit repeat
    end if
  end repeat
  pItemListHe = tdata[pTraderPal][#items]
  repeat with i = 1 to pItemListHe.count
    tImage = me.createItemImg(pItemListHe[i])
    tWndObj.getElement("trading_herstuff_" & i).feedImage(tImage)
    tWndObj.getElement("trading_herstuff_" & i).draw(rgb(64, 64, 64))
    if i = pMaxTradeItms then
      exit repeat
    end if
  end repeat
  me.accept(tdata.getPropAt(1), value(tdata[1][#accept]))
  me.accept(tdata.getPropAt(2), value(tdata[2][#accept]))
end

on complete me, tdata
  return me.close()
end

on isUnderTrade me, tStripID
  return pMyStripItems.getPos(tStripID) > 0
end

on createItemImg me, tProps
  tClass = tProps[#class]
  tColor = tProps[#color]
  tImgProps = [#ink: 8]
  if ilk(tProps[#stripColor], #color) then
    tImgProps[#bgColor] = tProps[#stripColor]
    tImgProps[#ink] = 41
  end if
  if tClass contains "*" then
    tClass = tClass.char[1..offset("*", tClass) - 1]
  end if
  if memberExists(tClass & "_small") then
    tMemStr = tClass & "_small"
  else
    if memberExists(tClass & "_a_0_1_1_0_0") then
      tMemStr = tClass & "_a_0_1_1_0_0"
    else
      if memberExists(tClass & "_a_0_2_2_0_0") then
        tMemStr = tClass & "_a_0_2_2_0_0"
      else
        if memberExists("rightwall" && tClass && tProps[#props]) then
          tMemStr = "rightwall" && tClass && tProps[#props]
        else
          if tClass contains "post.it" then
            tCount = integer(value(tProps[#props]) / (20.0 / 6.0))
            if tCount > 6 then
              tCount = 6
            end if
            if tCount < 1 then
              tCount = 1
            end if
            if memberExists(tClass & "_" & tCount & "_" & "small") then
              tMemStr = tClass & "_" & tCount & "_" & "small"
            else
              return error(me, "Couldn't define member for trade item!" & RETURN & tProps, #createItemImg)
            end if
          else
            return error(me, "Couldn't define member for trade item!" & RETURN & tProps, #createItemImg)
          end if
        end if
      end if
    end if
  end if
  tImage = member(getmemnum(tMemStr)).image
  tImgProps[#maskImage] = tImage.createMatte()
  tNewImg = image(tImage.width, tImage.height, 32)
  tNewImg.copyPixels(tImage, tImage.rect, tImage.rect, tImgProps)
  return me.cropToFit(tNewImg)
end

on cropToFit me, tImage
  tOffset = rect(0, 0, 0, 0)
  if tImage.width < pItemSlotRect.width then
    tOffset[1] = integer((pItemSlotRect.width - tImage.width) / 2)
    tOffset[3] = tOffset[1]
  end if
  if tImage.height < pItemSlotRect.height then
    tOffset[2] = integer((pItemSlotRect.height - tImage.height) / 2)
    tOffset[4] = tOffset[2]
  end if
  tNewImg = image(pItemSlotRect.width, pItemSlotRect.height, 32)
  tNewImg.copyPixels(tImage, tImage.rect + tOffset, tImage.rect)
  return tNewImg
end

on showInfo me, tText
  if pState = #closed then
    return 0
  end if
  if voidp(tText) then
    tText = getText("trading_additems")
  end if
  return getWindow(pTraderWndID).getElement("trading_instructions_text").setText(tText)
end

on blendLockedSlots me, tBoolean
  if pState = #closed then
    return 0
  end if
  if tBoolean then
    repeat with i = 1 to pItemListMe.count
      getWindow(pTraderWndID).getElement("trading_mystuff_" & i).setProperty(#blend, 60)
      if i = pMaxTradeItms then
        exit repeat
      end if
    end repeat
  else
    repeat with i = 1 to pItemListMe.count
      getWindow(pTraderWndID).getElement("trading_mystuff_" & i).setProperty(#blend, 100)
      if i = pMaxTradeItms then
        exit repeat
      end if
    end repeat
  end if
end

on eventProcTrading me, tEvent, tSprID, tParam
  if pState = #closed then
    return 0
  end if
  case tEvent of
    #mouseUp:
      case tSprID of
        "trading_confirm_check":
          if pAcceptFlagMe then
            pAcceptFlagMe = 0
            return getThread(#room).getComponent().getRoomConnection().send(#room, "TRADE_UNACCEPT" & SPACE)
          else
            pAcceptFlagMe = 1
            return getThread(#room).getComponent().getRoomConnection().send(#room, "TRADE_ACCEPT" & SPACE)
          end if
        "close", "trading_cancel":
          getThread(#room).getComponent().getRoomConnection().send(#room, "TRADE_CLOSE" & SPACE)
          return me.close()
      end case
      if tSprID contains "trading_mystuff" then
        tObjMover = getThread(#room).getInterface().getObjectMover()
        if objectp(tObjMover) then
          tClientID = tObjMover.getProperty(#clientID)
          tStripID = tObjMover.getProperty(#stripId)
          if tStripID <> EMPTY then
            if pAcceptFlagMe then
              getThread(#room).getComponent().getRoomConnection().send(#room, "TRADE_UNACCEPT" & SPACE)
            end if
            getThread(#room).getComponent().getRoomConnection().send(#room, "TRADE_ADDITEM" & SPACE & TAB & tStripID)
            return tObjMover.clear()
          end if
        end if
      end if
    #mouseEnter:
      tObjMover = getThread(#room).getInterface().getObjectMover()
      if tObjMover <> 0 then
        tObjMover.moveTrade()
      end if
      case tSprID of
        "trading_confirm_check":
          return me.showInfo(getText("trading_youagree"))
        "close", "trading_cancel":
          return me.showInfo(getText("trading_cancel"))
      end case
      if tSprID contains "trading_mystuff" and not pAcceptFlagMe then
        if integer(tSprID.char[length(tSprID)]) > pItemListMe.count then
          getWindow(pTraderWndID).getElement(tSprID).draw(rgb(128, 128, 128))
        else
          me.showInfo(pItemListMe[integer(tSprID.char[length(tSprID)])][#name])
        end if
      else
        if tSprID contains "trading_herstuff" then
          if integer(tSprID.char[length(tSprID)]) <= pItemListHe.count then
            me.showInfo(pItemListHe[integer(tSprID.char[length(tSprID)])][#name])
          end if
        end if
      end if
    #mouseLeave:
      case tSprID of
        "trading_confirm_check":
          return me.showInfo(VOID)
        "close", "trading_cancel":
          return me.showInfo(VOID)
      end case
      if tSprID contains "trading_mystuff" and not pAcceptFlagMe then
        tObjMover = getThread(#room).getInterface().getObjectMover()
        if tObjMover <> 0 then
          tObjMover.moveTrade()
        end if
        if integer(tSprID.char[length(tSprID)]) <= pItemListMe.count then
          getWindow(pTraderWndID).getElement(tSprID).draw(rgb(64, 64, 64))
        else
          getWindow(pTraderWndID).getElement(tSprID).draw(rgb(200, 200, 200))
        end if
        me.showInfo(VOID)
      else
        if tSprID contains "trading_herstuff" then
          me.showInfo(VOID)
        end if
      end if
  end case
end
