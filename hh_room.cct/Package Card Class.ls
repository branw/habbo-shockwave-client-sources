property pMessage, pPackageID, pCardWndID

on construct me
  pMessage = EMPTY
  pPackageID = EMPTY
  pCardWndID = "Card" && getUniqueID()
  registerMessage(#leaveRoom, me.getID(), #hideCard)
  registerMessage(#changeRoom, me.getID(), #hideCard)
  return 1
end

on deconstruct me
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return 1
end

on define me, tProps
  pPackageID = tProps[#id]
  pMessage = tProps[#msg]
  me.showCard(tProps[#loc] + [0, -220])
  return 1
end

on showCard me, tloc
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  if voidp(tloc) then
    tloc = [100, 100]
  end if
  if tloc[1] > (the stage).rect.width - 260 then
    tloc[1] = (the stage).rect.width - 260
  end if
  if tloc[2] < 2 then
    tloc[2] = 2
  end if
  if not createWindow(pCardWndID, "package_card.window", tloc[1], tloc[2]) then
    return 0
  end if
  tWndObj = getWindow(pCardWndID)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCard, me.getID(), #mouseUp)
  tWndObj.getElement("package_msg").setText(pMessage)
  return 1
end

on hideCard me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  return 1
end

on openPresent me
  return getThread(#room).getComponent().getRoomConnection().send(#room, "PRESENTOPEN /" & pPackageID)
end

on showContent me, tdata
  if not windowExists(pCardWndID) then
    return 0
  end if
  ttype = tdata[#type]
  tCode = tdata[#code]
  tMemNum = VOID
  if ttype starts "credits" then
    tmember = getmemnum("credits_icon")
  else
    if ttype starts "deal" then
      tDealID = ttype.char[6..length(ttype)]
      tMemNum = getmemnum("deal_icon_" & tDealID)
      if tMemNum = 0 then
        if memberExists("poster" && tDealID & "_small") then
          tMemNum = getmemnum("poster" && tDealID & "_small")
        else
          tMemNum = getmemnum("poster_small")
        end if
      end if
    else
      if ttype starts "poster" then
        tMemNum = getmemnum("poster" && tCode.word[tCode.word.count] & "_small")
      else
        if ttype = "null" then
          if memberExists(tCode.word[2] & "_small") then
            tMemNum = getmemnum(tCode.word[2] & "_small")
          end if
        else
          tTryDealName = "deal" && tCode.word[2] & "_small"
          if memberExists(tTryDealName) then
            tMemNum = getmemnum(tTryDealName)
          else
            if memberExists(ttype & "_small") then
              tMemNum = getmemnum(ttype & "_small")
            else
              if ttype contains "*" then
                a = offset("*", ttype)
                tMemNum = getmemnum(ttype.char[1..a - 1] & "_small")
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  if tMemNum = 0 then
    if memberExists("no_icon_small") then
      tImg = member(getmemnum("no_icon_small")).image.duplicate()
    else
      tImg = image(1, 1, 8)
    end if
  else
    tImg = member(tMemNum).image.duplicate()
  end if
  tWndObj = getWindow(pCardWndID)
  tWndObj.getElement("card_icon").hide()
  tWndObj.getElement("small_img").feedImage(tImg)
  tWndObj.getElement("small_img").setProperty(#blend, 100)
  tWndObj.getElement("open_package").hide()
end

on eventProcCard me, tEvent, tElemID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  case tElemID of
    "close":
      return me.hideCard()
    "open_package":
      return me.openPresent()
  end case
end
