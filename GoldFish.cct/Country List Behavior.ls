property pField, pChosenLine, pChosenContinent, mode, pCountryMan
global gChosenCountry, gChosenRegion, gCountryListSprite, gRegistrationManager, gChosenContinent

on beginSprite me
  gCountryListSprite = me.spriteNum
  pField = getmemnum("registration_country_list")
  set the textStyle of field pField to "plain"
  put EMPTY into field pField
  if not voidp(gRegistrationManager) then
    pCountryMan = gRegistrationManager.pCountryMan
  else
    pCountryMan = new(script("Country Manager Class"))
  end if
  member(getmemnum("CountrySelection.status")).text = EMPTY
  if gChosenCountry <> VOID and gChosenRegion <> VOID then
    ml = pCountryMan.getRegionOrderNum(gChosenCountry, gChosenRegion)
    if ml > 0 then
      me.refreshRegion(pCountryMan, gChosenCountry)
      me.selectLine(ml)
    end if
  else
    if gChosenCountry <> VOID then
      ml = pCountryMan.getCountryOrderNum(gChosenContinent, gChosenCountry)
      if ml > 0 then
        me.refreshContinent(pCountryMan, gChosenContinent)
        me.selectLine(ml)
      end if
    end if
  end if
end

on mouseDown me
  ml = the mouseLine
  if ml > 0 and ml <= (field(pField)).line.count then
    if line ml of field pField starts "-" then
      return 
    end if
    me.selectLine(ml)
  end if
end

on selectLine me, ml
  set the textStyle of field pField to "plain"
  pChosenLine = ml
  set the textStyle of line ml of field pField to "underline"
  case mode of
    #country:
      gChosenCountry = pCountryMan.getNthCountryNum(gChosenContinent, ml)
    #region:
      gChosenRegion = pCountryMan.getNthRegionNum(gChosenCountry, ml)
  end case
  put gChosenCountry into field "countryname"
end

on refreshContinent me, countryMan, tContinent
  pCountryMan = countryMan
  gChosenContinent = tContinent
  gChosenCountry = VOID
  gChosenRegion = VOID
  s = pCountryMan.getCountryList(tContinent)
  set the textStyle of field pField to "plain"
  put s into field pField
  set the textStyle of field pField to "plain"
  member(pField).scrollTop = 0
  pChosenLine = VOID
  mode = #country
  member(getmemnum("CountrySelection.status")).text = "Choose country:"
end

on endSprite me
  put EMPTY into field pField
end

on refreshRegion me, countryMan, tCountry
  pCountryMan = countryMan
  s = pCountryMan.getRegionList(tCountry)
  gChosenCountry = tCountry
  gChosenRegion = VOID
  set the textStyle of field pField to "plain"
  put s into field pField
  set the textStyle of field pField to "plain"
  member(pField).scrollTop = 0
  pChosenLine = VOID
  mode = #region
  member(getmemnum("CountrySelection.status")).text = "Choose region/state:"
end
