global gRegistrationManager, gCountryPrefix

on startRegistration
  if gCountryPrefix <> "ch" then
    gRegistrationManager = new(script("Registration Manager"), #register)
  else
    go("regist")
  end if
end

on startUpdate tState
  if gCountryPrefix <> "ch" then
    gRegistrationManager = new(script("Registration Manager"), #update, tState)
  else
    go("change1")
  end if
end
