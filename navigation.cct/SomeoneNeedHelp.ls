on enterFrame me
  global CryHelp, CryCount
  if CryCount <> 0 and CryHelp <> VOID and CryCount <= count(CryHelp) then
    s = EMPTY
    s = s & CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("cryinguser") & RETURN
    s = s & CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit") & RETURN & RETURN
    s = s & CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryMsg") & RETURN & RETURN
    member("hobba_who_field").text = s
    member("hobba_pickedup_field").text = AddTextToField("CryPickedBy") && CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("PickedCry")
    member("hobba_alerts_field").text = CryCount & "/" & count(CryHelp)
    updateStage()
  end if
end
