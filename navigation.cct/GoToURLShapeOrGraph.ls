property theUrl

on mouseUp me
  put theUrl
  JumptoNetPage(theUrl, "_new")
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #theUrl, [#comment: "The url to go", #format: #string, #default: "http://www.sulake.com/"])
  return pList
end
