global gRegistrationManager

on startRegistration
  gRegistrationManager = new(script("Registration Manager"), #register)
end

on startUpdate tState
  gRegistrationManager = new(script("Registration Manager"), #update, tState)
end
