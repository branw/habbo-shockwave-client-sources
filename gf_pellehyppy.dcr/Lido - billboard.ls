property pAdId1, pAdLink1, pAdId2, pAdLink2
global gChosenUnitPort

on beginSprite me
  global gMyName
  pAdLink1 = stringReplace(pAdLink1, "%username%", urlEncode(gMyName))
  pAdLink2 = stringReplace(pAdLink2, "%username%", urlEncode(gMyName))
  if gChosenUnitPort = 37401 then
    sendEPFuseMsg("ADVIEW" && pAdId1)
  else
    sendEPFuseMsg("ADVIEW" && pAdId2)
  end if
end

on mouseUp me
  if gChosenUnitPort = 37401 then
    if pAdId1 > 1 then
      sendEPFuseMsg("ADCLICK" && pAdId1)
    end if
    if pAdLink1 contains "http:" then
      gotoNetPage(pAdLink1, "_new")
    end if
  else
    if pAdId2 > 1 then
      sendEPFuseMsg("ADCLICK" && pAdId2)
    end if
    if pAdLink2 contains "http:" then
      gotoNetPage(pAdLink2, "_new")
    end if
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #pAdId1, [#comment: "(Lido I) Mainoksen Id-numero (katso Ad-managementistä)", #format: #integer, #default: 0])
  addProp(pList, #pAdLink1, [#comment: "(Lido I) http linkki", #format: #string, #default: EMPTY])
  addProp(pList, #pAdId2, [#comment: "(Lido II) Mainoksen Id-numero (katso Ad-managementistä)", #format: #integer, #default: 0])
  addProp(pList, #pAdLink2, [#comment: "(Lido II) http linkki", #format: #string, #default: EMPTY])
  return pList
end
