property context

on mouseUp me
  global gBirthdayUpdate, gGoTo, gLoginName, gLoginPw, gPopUpContext, gPopUpContext2
  if gPopUpContext2 <> VOID then
    closeNavigator()
  end if
  if gPopUpContext <> VOID then
    closeMessenger()
  end if
  gBirthdayUpdate = 1
  gGoTo = "change"
  fuseRetrieveInfo(gLoginName, gLoginPw)
  context.close()
end
