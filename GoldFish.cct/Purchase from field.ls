property theField
global gMyName, gProps

on mouseDown me
  sendEPFuseMsg("GETORDERINFO /" & member(theField).text && gMyName)
  if listp(gProps) then
    setaProp(gProps, #asgift, 0)
  end if
end

on getPropertyDescriptionList me
  return [#theField: [#comment: "Field where to get the code:", #format: #string, #default: EMPTY]]
end
