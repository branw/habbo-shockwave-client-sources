global gRegistrationManager, gConfirmPopUp

on mouseUp me
  global gGoTo, gLoginName, gLoginPw, gPopUpContext, gPopUpContext2, gForcedCountryReg
  if gPopUpContext2 <> VOID then
    closeNavigator()
  end if
  if gPopUpContext <> VOID then
    closeMessenger()
  end if
  if gConfirmPopUp <> VOID then
    gConfirmPopUp.close()
  end if
  gGoTo = "change"
  gForcedCountryReg = 1
  fuseRetrieveInfo(gLoginName, gLoginPw)
end
