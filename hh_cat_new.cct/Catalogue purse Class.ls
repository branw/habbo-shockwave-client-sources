on construct me
  me.updatePurseSaldo()
  me.updatePurseTickets()
  me.updatePurseFilm()
  registerMessage(#updateCreditCount, me.getID(), #updatePurseSaldo)
  registerMessage(#updateTicketCount, me.getID(), #updatePurseTickets)
  return 1
end

on deconstruct me
  unregisterMessage(#updateCreditCount, me.getID())
  unregisterMessage(#updateTicketCount, me.getID())
end

on updatePurseSaldo me
  if not threadExists(#catalogue) then
    return 0
  end if
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_amount") then
      if getObject(#session).exists("user_walletbalance") then
        tSaldo = getObject(#session).GET("user_walletbalance")
      else
        tSaldo = "-"
      end if
      tWndObj.getElement("purse_amount").setText(tSaldo)
    end if
  end if
end

on updatePurseTickets me
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_info_tickets") then
      tFieldTxt = getObject(#session).GET("user_ph_tickets") && getText("purse_info_tickets")
      tWndObj.getElement("purse_info_tickets").setText(tFieldTxt)
    end if
    return 1
  end if
end

on updatePurseFilm me
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if objectp(tWndObj) then
    if tWndObj.elementExists("purse_info_film") then
      tFieldTxt = getObject(#session).GET("user_photo_film") && getText("purse_info_film")
      tWndObj.getElement("purse_info_film").setText(tFieldTxt)
    end if
    return 1
  end if
end

on eventProc me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    if tSprID = "close" then
      return 0
    end if
  end if
  if tEvent = #mouseDown then
    tloc = the mouseLoc
    case tSprID of
      "coins_btn":
        executeMessage(#externalLinkClick, tloc)
        openNetPage(getText("url_purselink"))
      "vouchers_btn":
        executeMessage(#externalLinkClick, tloc)
        openNetPage(getText("purse_vouchers_helpurl"))
    end case
    return 0
  end if
  return 1
end
