property spriteNum, pReady, pCountry, pPostCode, pCountriesThatNeedsPostCode
global gMyName

on beginSprite me
  sprite(spriteNum).blend = 50
  member("country_pop_field").text = EMPTY
  member("country_pop_field2").text = EMPTY
  member("postcode_pop_field").text = EMPTY
  pReady = 0
  pCountry = EMPTY
  pPostCode = EMPTY
  pCountriesThatNeedsPostCode = ["uk", "UK", "uK", "Uk", "United Kingdom"]
end

on mouseUp me
  if sprite(spriteNum).blend <> 100 then
    dontPassEvent()
    exit
  end if
  tCountry = member("country_pop_field2").text
  tPostCode = member("postcode_pop_field").text
  if tCountry = EMPTY then
    dontPassEvent()
    exit
  else
    if pCountriesThatNeedsPostCode.getPos(tCountry) <> 0 and tPostCode = EMPTY then
      put "Missing postcode!"
      dontPassEvent()
      exit
    end if
  end if
  if tPostCode <> EMPTY then
    tCodeFound = 0
    repeat with i = 1 to member("PostCodeList").text.line.count
      if tPostCode = member("PostCodeList").text.line[i] then
        tCodeFound = 1
        exit repeat
      end if
    end repeat
    if not tCodeFound then
      put "Invalid postcode!"
      dontPassEvent()
      exit
    end if
  end if
  sendEPFuseMsg("UPDATE_COUNTRY /" & tCountry & "/" & tPostCode)
  pReady = 1
  put "Countrydata added!"
end

on exitFrame me
  tAllOK = 0
  tCountry = member("country_pop_field2").text
  tPostCode = member("postcode_pop_field").text
  if tCountry <> EMPTY then
    tAllOK = 1
    if pCountriesThatNeedsPostCode.getPos(tCountry) <> 0 and tPostCode = EMPTY then
      tAllOK = 0
    end if
  end if
  if tAllOK then
    sprite(spriteNum).blend = 100
  else
    sprite(spriteNum).blend = 50
  end if
  if not pReady then
    go(the frame)
  end if
end
