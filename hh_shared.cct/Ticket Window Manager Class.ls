property pWndID, pChosenAmount

on construct me
  pWndID = getText("ph_tickets_title")
  pChosenAmount = 1
  registerMessage(#show_ticketWindow, me.getID(), #showTicketWindow)
  registerMessage(#hide_ticketwindow, me.getID(), #hideTicketWindow)
  registerMessage(#enterRoom, me.getID(), #hideTicketWindow)
  registerMessage(#leaveRoom, me.getID(), #hideTicketWindow)
  registerMessage(#changeRoom, me.getID(), #hideTicketWindow)
  return 1
end

on deconstruct me
  unregisterMessage(#show_ticketWindow, me.getID())
  unregisterMessage(#hide_ticketwindow, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  return 1
end

on showTicketWindow me
  if windowExists(pWndID) then
    return 1
  end if
  createWindow(pWndID, "habbo_basic.window")
  tWndObj = getWindow(pWndID)
  if tWndObj = 0 then
    return error(me, "Cannot open ticket purchase window", #showTicketWindow)
  end if
  if not tWndObj.merge("habbo_ph_tickets.window") then
    return error(me, "Cannot open ticket purchase window", #showTicketWindow)
  end if
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcTicketsWindow, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcTicketsWindow, me.getID(), #keyDown)
  tTickets = getObject(#session).get("user_ph_tickets")
  tText = replaceChunks(getText("ph_tickets_txt"), "\x1", tTickets)
  tWndObj.getElement("ph_tickets_number").setText(string(tTickets))
  tWndObj.getElement("ph_tickets_txt").setText(string(tText))
  tElem = tWndObj.getElement("ph_tickets_namefield")
  if tElem <> 0 then
    tElem.setText(getObject(#session).get("user_name"))
  end if
  return me.setCheckBox(1)
end

on hideTicketWindow me
  if windowExists(pWndID) then
    removeWindow(pWndID)
  end if
  pChosenAmount = 1
  return 1
end

on eventProcTicketsWindow me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    case tSprID of
      "close":
        me.hideTicketWindow()
      "ph_tickets_buy_button":
        tName = getWindow(tWndID).getElement("ph_tickets_namefield").getText()
        if tName = EMPTY or tName = " " then
          tName = getObject(#session).get("user_name")
        end if
        me.buyGameTickets(tName)
        me.hideTicketWindow()
      "tickets_checkbox_1":
        me.setCheckBox(1)
        pChosenAmount = 1
      "tickets_checkbox_2":
        me.setCheckBox(2)
        pChosenAmount = 2
    end case
  end if
end

on setCheckBox me, tNr
  if not windowExists(pWndID) then
    return 0
  end if
  tWndObj = getWindow(pWndID)
  tOnImg = getMember("button.radio.on").image
  tOffImg = getMember("button.radio.off").image
  repeat with i = 1 to 2
    tElem = tWndObj.getElement("tickets_checkbox_" & i)
    if tNr = i then
      tElem.feedImage(tOnImg)
      next repeat
    end if
    tElem.feedImage(tOffImg)
  end repeat
  return 1
end

on buyGameTickets me, tName
  tParams = [#integer: pChosenAmount, #string: tName]
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("BTCKS", tParams)
  end if
  return 1
end
