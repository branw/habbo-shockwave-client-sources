global gDoor, NowinUnit, gChosenFlatId, gFlats, gActiveRoomInfoString

on mouseUp me
  if the movieName contains "private" then
    s = NowinUnit & ";" & gDoor & ";" & member("hobba_crymessage_field").text & ";" & gActiveRoomInfoString
  else
    s = NowinUnit & ";" & gDoor & ";" & member("hobba_crymessage_field").text & ";" & gChosenFlatId
  end if
  put "CRYFORHELP /" & s
  sendFuseMsg("CRYFORHELP /" & s)
end
