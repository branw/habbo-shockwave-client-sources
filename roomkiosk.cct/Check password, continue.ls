global gProps

on mouseUp me
  if field("room_password") <> field("room_password_check") and getaProp(gProps, #doorMode) = #password then
    goContext("pw_no_match")
  else
    reserveRoom()
    goContext("confirm")
  end if
end
