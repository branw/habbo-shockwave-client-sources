property pCountries, pContinents, pRegions

on new me
  pCountries = [:]
  pContinents = [:]
  pRegions = [:]
  oldDelim = the itemDelimiter
  the itemDelimiter = ":"
  s = field(getmemnum("ContinentList"))
  repeat with i = 1 to s.line.count
    addProp(pContinents, integer(s.line[i].item[1]), s.line[i].item[2])
  end repeat
  s = field(getmemnum("RegCountryList"))
  repeat with i = 1 to s.line.count
    ln = s.line[i]
    cont = integer(ln.item[2])
    pCont = pCountries.getaProp(cont)
    if pCont = VOID then
      pCont = [:]
      addProp(pCountries, cont, pCont)
    end if
    addProp(pCont, ln.item[1], ln.item[3])
  end repeat
  s = field(getmemnum("RegionList"))
  repeat with i = 1 to s.line.count
    ln = s.line[i]
    country = integer(ln.item[2])
    pCountry = pRegions.getaProp(country)
    if pCountry = VOID then
      pCountry = [:]
      addProp(pRegions, country, pCountry)
    end if
    addProp(pCountry, ln.item[1], ln.item[3])
  end repeat
  the itemDelimiter = oldDelim
  return me
end

on getCountryList me, continent
  s = EMPTY
  l = pCountries.getaProp(continent)
  if l = VOID then
    return EMPTY
  end if
  repeat with ss in l
    if s.length > 0 then
      s = s & RETURN
    end if
    s = s & ss
  end repeat
  return s
end

on getRegionList me, country
  s = EMPTY
  l = pRegions.getaProp(integer(country))
  if l = VOID then
    return EMPTY
  end if
  repeat with ss in l
    if s.length > 0 then
      s = s & RETURN
    end if
    s = s & ss
  end repeat
  return s
end

on getNthCountryNum me, continent, nth
  return pCountries.getaProp(continent).getPropAt(nth)
end

on getNthRegionNum me, country, nth
  return pRegions.getaProp(country).getPropAt(nth)
end

on getCountryOrderNum me, continent, country
  countrylist = pCountries.getaProp(continent)
  if listp(countrylist) then
    repeat with i = 1 to countrylist.count
      if countrylist.getPropAt(i) = country then
        return i
      end if
    end repeat
  end if
end

on getRegionOrderNum me, country, region
  regionList = pRegions.getaProp(country)
  if listp(regionList) then
    repeat with i = 1 to regionList.count
      if regionList.getPropAt(i) = region then
        return i
      end if
    end repeat
  end if
end
