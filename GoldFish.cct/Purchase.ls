property code
global gMyName, gProps

on mouseDown me
  sendEPFuseMsg("GETORDERINFO /" & code && gMyName)
  if listp(gProps) then
    setaProp(gProps, #asgift, 0)
  end if
end

on getPropertyDescriptionList me
  return [#code: [#comment: "Purchasing code (such as A1 STP)", #format: #string, #default: "A2 xxx"]]
end
