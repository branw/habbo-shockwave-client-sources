property pAdId, pAdLink

on beginSprite me
  if pAdId > 0 then
    sendEPFuseMsg("ADVIEW" && pAdId)
  end if
end

on mouseUp me
  if pAdId > 0 then
    sendEPFuseMsg("ADCLICK" && pAdId)
  end if
  if pAdLink contains "http:" then
    gotoNetPage(pAdLink, "_new")
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #pAdId, [#comment: "Mainoksen Id-numero (katso Ad-managementistä)", #format: #integer, #default: 0])
  addProp(pList, #pAdLink, [#comment: "http linkki", #format: #string, #default: EMPTY])
  return pList
end
