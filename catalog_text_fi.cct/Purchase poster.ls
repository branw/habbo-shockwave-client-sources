property pCode
global gMyName, gProps

on setPosterCode me, tCode
  put tCode
  pCode = tCode
end

on mouseDown me
  if listp(gProps) then
    setaProp(gProps, #asgift, 0)
  end if
  if voidp(pCode) or pCode = EMPTY then
    return 
  end if
  sendEPFuseMsg("GETORDERINFO /" & pCode && gMyName)
end
