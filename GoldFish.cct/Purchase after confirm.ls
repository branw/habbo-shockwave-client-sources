global gPurchaseCode, gMyName, gConfirmPopUp, gProps

on mouseUp me
  if not voidp(gPurchaseCode) then
    if getaProp(gProps, #asgift) <> 1 then
      sendEPFuseMsg("PURCHASE /" & gPurchaseCode && gMyName)
    else
      msg = "a2 gift "
      msg = msg & QUOTE
      msg = msg & charReplace(gPurchaseCode, " ", "/")
      msg = msg & QUOTE & ","
      giftMsg = field("greeting_card_field")
      msg = msg & QUOTE & charReplace(giftMsg, " ", "/") & QUOTE
      msg = msg && field("giftto_habboname_field")
      put msg
      sendEPFuseMsg("PURCHASE /" & msg)
    end if
    gPurchaseCode = VOID
  end if
  close(gConfirmPopUp)
end
